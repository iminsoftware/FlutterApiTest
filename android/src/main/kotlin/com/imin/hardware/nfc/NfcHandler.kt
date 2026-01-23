package com.imin.hardware.nfc

import android.app.Activity
import android.app.Application
import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * NFC Handler for iMin devices
 * 
 * Based on IMinApiTest NfcActivity implementation
 * Uses Android native NFC API (not IminSDKManager)
 */
class NfcHandler(
    private val activity: Activity,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler, Application.ActivityLifecycleCallbacks {
    
    companion object {
        private const val TAG = "NfcHandler"
    }

    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var intentFilters: Array<IntentFilter>? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isListening = false

    init {
        // Initialize NFC
        initNfc()
        
        // Set event stream handler
        eventChannel.setStreamHandler(this)
        
        // Register lifecycle callbacks to manage foreground dispatch
        activity.application.registerActivityLifecycleCallbacks(this)
        
        Log.d(TAG, "NfcHandler initialized")
    }

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "nfc.isAvailable" -> checkNfcAvailable(result)
            "nfc.isEnabled" -> checkNfcEnabled(result)
            "nfc.openSettings" -> openNfcSettings(result)
            else -> result.notImplemented()
        }
    }

    private fun initNfc() {
        try {
            // Get NFC adapter
            nfcAdapter = NfcAdapter.getDefaultAdapter(activity)
            
            if (nfcAdapter == null) {
                Log.w(TAG, "NFC not available on this device")
                return
            }

            // Create pending intent (same as IMinApiTest)
            val intent = Intent(activity, activity.javaClass).apply {
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }

            pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.getActivity(
                    activity,
                    0,
                    intent,
                    PendingIntent.FLAG_MUTABLE
                )
            } else {
                PendingIntent.getActivity(activity, 0, intent, 0)
            }

            // Create intent filters (same as IMinApiTest)
            val ndefFilter = IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED).apply {
                try {
                    addDataType("*/*")
                } catch (e: Exception) {
                    Log.e(TAG, "Error adding data type", e)
                }
            }
            val tagFilter = IntentFilter(NfcAdapter.ACTION_TAG_DISCOVERED)
            intentFilters = arrayOf(ndefFilter, tagFilter)

            Log.d(TAG, "NFC initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing NFC", e)
        }
    }

    private fun checkNfcAvailable(result: Result) {
        try {
            val isAvailable = nfcAdapter != null
            Log.d(TAG, "NFC available: $isAvailable")
            result.success(isAvailable)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking NFC availability", e)
            result.error("CHECK_FAILED", e.message, null)
        }
    }

    private fun checkNfcEnabled(result: Result) {
        try {
            val isEnabled = nfcAdapter?.isEnabled ?: false
            Log.d(TAG, "NFC enabled: $isEnabled")
            result.success(isEnabled)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking NFC status", e)
            result.error("CHECK_FAILED", e.message, null)
        }
    }

    private fun openNfcSettings(result: Result) {
        try {
            val intent = Intent(Settings.ACTION_NFC_SETTINGS)
            activity.startActivity(intent)
            Log.d(TAG, "Opened NFC settings")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening NFC settings", e)
            result.error("OPEN_SETTINGS_FAILED", e.message, null)
        }
    }

    /**
     * Handle new NFC intent (called from Plugin's onNewIntentListener)
     * This is equivalent to Activity's onNewIntent method in IMinApiTest
     */
    fun handleNewIntent(intent: Intent) {
        if (!isListening) {
            Log.d(TAG, "Not listening, ignoring NFC intent")
            return
        }

        val action = intent.action
        Log.d(TAG, "Received NFC intent: $action")

        if (action == NfcAdapter.ACTION_TAG_DISCOVERED || 
            action == NfcAdapter.ACTION_NDEF_DISCOVERED) {
            try {
                // Read NFC data (same as IMinApiTest)
                val nfcId = readNFCId(intent)
                val content = readNFCFromTag(intent)
                
                Log.d(TAG, "NFC ID: $nfcId, Content: $content")
                
                if (nfcId.isNotEmpty()) {
                    val nfcData = mapOf(
                        "id" to nfcId,
                        "content" to content,
                        "technology" to (intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)?.techList?.joinToString(", ") ?: ""),
                        "timestamp" to System.currentTimeMillis()
                    )
                    
                    // Send to Flutter via EventChannel
                    eventSink?.success(nfcData)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error reading NFC data", e)
                eventSink?.error("READ_ERROR", e.message, null)
            }
        }
    }

    /**
     * Read NFC ID (same as IMinApiTest NfcUtils.readNFCId)
     */
    private fun readNFCId(intent: Intent): String {
        val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
        if (tag == null) {
            return ""
        }
        return byteArrayToHexString(tag.id)
    }

    /**
     * Read NFC content (same as IMinApiTest NfcUtils.readNFCFromTag)
     */
    private fun readNFCFromTag(intent: Intent): String {
        try {
            val rawArray = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            if (rawArray != null && rawArray.isNotEmpty()) {
                val ndefMsg = rawArray[0] as NdefMessage
                val ndefRecord = ndefMsg.records[0]
                return String(ndefRecord.payload, Charsets.UTF_8)
            }
        } catch (e: Exception) {
            Log.w(TAG, "Error reading NFC content", e)
        }
        return ""
    }

    /**
     * Convert byte array to hex string (same as IMinApiTest NfcUtils.ByteArrayToHexString)
     */
    private fun byteArrayToHexString(inarray: ByteArray): String {
        val hex = arrayOf("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")
        val out = StringBuilder()
        
        for (byte in inarray) {
            val value = byte.toInt() and 0xff
            val i = (value shr 4) and 0x0f
            out.append(hex[i])
            val j = value and 0x0f
            out.append(hex[j])
        }
        
        return out.toString()
    }

    /**
     * Enable foreground dispatch (called in Activity's onResume)
     * Same as IMinApiTest: NfcUtils.mNfcAdapter.enableForegroundDispatch(...)
     */
    private fun enableForegroundDispatch() {
        try {
            if (nfcAdapter != null && pendingIntent != null && intentFilters != null && isListening) {
                nfcAdapter?.enableForegroundDispatch(activity, pendingIntent, intentFilters, null)
                Log.d(TAG, "NFC foreground dispatch enabled")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error enabling foreground dispatch", e)
        }
    }

    /**
     * Disable foreground dispatch (called in Activity's onPause)
     * Same as IMinApiTest: NfcUtils.mNfcAdapter.disableForegroundDispatch(this)
     */
    private fun disableForegroundDispatch() {
        try {
            nfcAdapter?.disableForegroundDispatch(activity)
            Log.d(TAG, "NFC foreground dispatch disabled")
        } catch (e: Exception) {
            Log.e(TAG, "Error disabling foreground dispatch", e)
        }
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        isListening = true
        Log.d(TAG, "Started listening for NFC tags")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        isListening = false
        Log.d(TAG, "Stopped listening for NFC tags")
    }

    // ActivityLifecycleCallbacks implementation (only onResume/onPause needed)
    override fun onActivityResumed(activity: Activity) {
        if (activity == this.activity) {
            // Same as IMinApiTest onResume
            enableForegroundDispatch()
        }
    }

    override fun onActivityPaused(activity: Activity) {
        if (activity == this.activity) {
            // Same as IMinApiTest onPause
            disableForegroundDispatch()
        }
    }

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}
    override fun onActivityStarted(activity: Activity) {}
    override fun onActivityStopped(activity: Activity) {}
    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}

    fun cleanup() {
        try {
            disableForegroundDispatch()
            activity.application.unregisterActivityLifecycleCallbacks(this)
            eventChannel.setStreamHandler(null)
            eventSink = null
            isListening = false
            Log.d(TAG, "NfcHandler cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}
