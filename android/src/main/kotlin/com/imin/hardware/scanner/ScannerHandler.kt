package com.imin.hardware.scanner

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Scanner Handler for iMin devices
 * 
 * Based on IMinApiTest ScannerActivity implementation
 * Uses BroadcastReceiver to receive scan results from hardware scanner
 */
class ScannerHandler(
    private val context: Context,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "ScannerHandler"
        
        // Broadcast actions
        private const val DEVICE_CONNECTION = "com.imin.scanner.api.DEVICE_CONNECTION"
        private const val DEVICE_DISCONNECTION = "com.imin.scanner.api.DEVICE_DISCONNECTION"
        private const val DEFAULT_RESULT_ACTION = "com.imin.scanner.api.RESULT_ACTION"
        private const val CONNECTION_BACK_ACTION = "com.imin.scanner.api.CONNECTION_RESULT"
        private const val CONNECTION_STATUS_ACTION = "com.imin.scanner.api.DEVICE_IS_CONNECTION"
        
        // Intent extras
        private const val LABEL_TYPE = "com.imin.scanner.api.label_type"
        private const val DEFAULT_EXTRA_DECODE_DATA = "decode_data"
        private const val DEFAULT_EXTRA_DECODE_DATA_STR = "decode_data_str"
        private const val CONNECTION_TYPE = "com.imin.scanner.api.status"
        
        // System property for scanner status
        private const val SCANNER_STATUS_PROPERTY = "persist.sys.imin.scanner.status"
    }

    private var scannerReceiver: BroadcastReceiver? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isListening = false
    
    // Configurable broadcast parameters
    private var resultAction = DEFAULT_RESULT_ACTION
    private var dataKey = DEFAULT_EXTRA_DECODE_DATA_STR
    private var byteDataKey = DEFAULT_EXTRA_DECODE_DATA

    init {
        // Set event stream handler
        eventChannel.setStreamHandler(this)
        Log.d(TAG, "ScannerHandler initialized")
    }

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "scanner.configure" -> configure(call, result)
            "scanner.startListening" -> startListening(result)
            "scanner.stopListening" -> stopListening(result)
            "scanner.isConnected" -> checkConnection(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Configure custom broadcast parameters
     * Allows flexibility for different scanner models
     */
    private fun configure(call: MethodCall, result: Result) {
        try {
            val action = call.argument<String>("action")
            val data = call.argument<String>("dataKey")
            val byteData = call.argument<String>("byteDataKey")
            
            if (isListening) {
                result.error("ALREADY_LISTENING", "Cannot configure while listening. Stop listening first.", null)
                return
            }
            
            action?.let { resultAction = it }
            data?.let { dataKey = it }
            byteData?.let { byteDataKey = it }
            
            Log.d(TAG, "Configured: action=$resultAction, dataKey=$dataKey, byteDataKey=$byteDataKey")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error configuring scanner", e)
            result.error("CONFIGURE_FAILED", e.message, null)
        }
    }

    /**
     * Start listening for scanner broadcasts
     * Same as IMinApiTest registerScannerBroadcast()
     */
    private fun startListening(result: Result) {
        try {
            if (isListening) {
                Log.w(TAG, "Already listening")
                result.success(false)
                return
            }
            
            // Create intent filter (same as IMinApiTest)
            val intentFilter = IntentFilter().apply {
                addAction(DEVICE_CONNECTION)
                addAction(DEVICE_DISCONNECTION)
                addAction(resultAction)
                addAction(CONNECTION_BACK_ACTION)
            }
            
            // Create broadcast receiver
            scannerReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    handleBroadcast(intent)
                }
            }
            
            // Register receiver
            context.registerReceiver(scannerReceiver, intentFilter)
            isListening = true
            
            Log.d(TAG, "Started listening for scanner broadcasts")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error starting scanner listener", e)
            result.error("START_FAILED", e.message, null)
        }
    }

    /**
     * Stop listening for scanner broadcasts
     * Same as IMinApiTest unRegisterScannerBroadcast()
     */
    private fun stopListening(result: Result) {
        try {
            if (!isListening) {
                Log.w(TAG, "Not listening")
                result.success(false)
                return
            }
            
            scannerReceiver?.let {
                context.unregisterReceiver(it)
                scannerReceiver = null
            }
            
            isListening = false
            Log.d(TAG, "Stopped listening for scanner broadcasts")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error stopping scanner listener", e)
            result.error("STOP_FAILED", e.message, null)
        }
    }

    /**
     * Check if scanner device is connected
     * Same as IMinApiTest getScannerStatus()
     */
    private fun checkConnection(result: Result) {
        try {
            // Method 1: Query via SystemProperties (synchronous)
            val status = getSystemProperty(SCANNER_STATUS_PROPERTY, "0")
            val isConnected = status == "1"
            
            Log.d(TAG, "Scanner connection status: $isConnected")
            result.success(isConnected)
            
            // Method 2: Query via broadcast (asynchronous, result comes via CONNECTION_BACK_ACTION)
            // Uncomment if needed:
            // context.sendBroadcast(Intent(CONNECTION_STATUS_ACTION))
        } catch (e: Exception) {
            Log.e(TAG, "Error checking scanner connection", e)
            result.error("CHECK_FAILED", e.message, null)
        }
    }

    /**
     * Handle incoming broadcast
     * Same as IMinApiTest ScannerReceiver.onReceive()
     */
    private fun handleBroadcast(intent: Intent) {
        val action = intent.action ?: return
        
        Log.d(TAG, "Received broadcast: $action")
        
        when (action) {
            DEVICE_CONNECTION -> {
                // Scanner connected
                Log.d(TAG, "Scanner device connected")
                eventSink?.success(mapOf(
                    "event" to "connected",
                    "timestamp" to System.currentTimeMillis()
                ))
            }
            
            DEVICE_DISCONNECTION -> {
                // Scanner disconnected
                Log.d(TAG, "Scanner device disconnected")
                eventSink?.success(mapOf(
                    "event" to "disconnected",
                    "timestamp" to System.currentTimeMillis()
                ))
            }
            
            resultAction -> {
                // Scan result (same as IMinApiTest)
                try {
                    val strData = intent.getStringExtra(dataKey)
                    val byteData = intent.getByteArrayExtra(byteDataKey)
                    val labelType = intent.getStringExtra(LABEL_TYPE)
                    
                    Log.d(TAG, "Scan result - String: $strData, LabelType: $labelType")
                    
                    val scanData = mutableMapOf<String, Any?>(
                        "event" to "scanResult",
                        "data" to (strData ?: ""),
                        "labelType" to (labelType ?: ""),
                        "timestamp" to System.currentTimeMillis()
                    )
                    
                    // Include raw byte data if available
                    byteData?.let {
                        scanData["rawData"] = it.toList()
                    }
                    
                    eventSink?.success(scanData)
                } catch (e: Exception) {
                    Log.e(TAG, "Error parsing scan result", e)
                    eventSink?.error("PARSE_ERROR", e.message, null)
                }
            }
            
            CONNECTION_BACK_ACTION -> {
                // Connection status response (from broadcast query)
                val type = intent.getIntExtra(CONNECTION_TYPE, 0)
                val isConnected = type == 1
                
                Log.d(TAG, "Scanner connection status (broadcast): $isConnected")
                eventSink?.success(mapOf(
                    "event" to "connectionStatus",
                    "connected" to isConnected,
                    "timestamp" to System.currentTimeMillis()
                ))
            }
        }
    }

    /**
     * Get system property value
     * Same as IMinApiTest reflection method
     */
    private fun getSystemProperty(key: String, defaultValue: String): String {
        return try {
            val c = Class.forName("android.os.SystemProperties")
            val get = c.getMethod("get", String::class.java, String::class.java)
            get.invoke(c, key, defaultValue) as String
        } catch (e: Exception) {
            Log.w(TAG, "Error reading system property: $key", e)
            defaultValue
        }
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "Event stream listener attached")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "Event stream listener detached")
    }

    fun cleanup() {
        try {
            if (isListening) {
                scannerReceiver?.let {
                    context.unregisterReceiver(it)
                }
            }
            eventChannel.setStreamHandler(null)
            scannerReceiver = null
            eventSink = null
            isListening = false
            Log.d(TAG, "ScannerHandler cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}
