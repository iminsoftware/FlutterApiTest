package com.imin.hardware.segment

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.hardware.usb.UsbDevice
import android.hardware.usb.UsbManager
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class SegmentHandler(private val activity: Activity) {
    private val TAG = "SegmentHandler"
    private val ACTION_USB_PERMISSION = "com.imin.hardware.USB_PERMISSION"
    
    // iMin 数码管设备 PID/VID
    private val SEGMENT_PID = 8455
    private val SEGMENT_VID = 16701
    
    private var usbCommunication: UsbCommunication? = null
    private var screenDevice: UsbDevice? = null
    private var permissionCallback: Result? = null
    
    private val usbReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (ACTION_USB_PERMISSION == action) {
                synchronized(this) {
                    val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE, UsbDevice::class.java)
                    } else {
                        @Suppress("DEPRECATION")
                        intent.getParcelableExtra(UsbManager.EXTRA_DEVICE)
                    }
                    
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        device?.let {
                            Log.d(TAG, "USB permission granted")
                            permissionCallback?.success(true)
                        }
                    } else {
                        Log.d(TAG, "USB permission denied")
                        permissionCallback?.error("PERMISSION_DENIED", "USB permission denied", null)
                    }
                    permissionCallback = null
                }
            }
        }
    }
    
    init {
        usbCommunication = UsbCommunication(activity)
        
        // 注册 USB 权限广播接收器
        // 必须使用 RECEIVER_EXPORTED，因为 USB 权限广播由系统 UsbManager 发送
        val filter = IntentFilter(ACTION_USB_PERMISSION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(usbReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            activity.registerReceiver(usbReceiver, filter)
        }
    }
    
    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "segment.findDevice" -> findDevice(result)
            "segment.requestPermission" -> requestPermission(result)
            "segment.connect" -> connect(result)
            "segment.sendData" -> {
                val data = call.argument<String>("data") ?: ""
                val align = call.argument<String>("align") ?: "right"
                sendData(data, align, result)
            }
            "segment.clear" -> clear(result)
            "segment.full" -> full(result)
            "segment.disconnect" -> disconnect(result)
            else -> result.notImplemented()
        }
    }
    
    private fun findDevice(result: Result) {
        try {
            val usbManager = activity.getSystemService(Context.USB_SERVICE) as UsbManager
            val deviceList = usbManager.deviceList
            
            for (device in deviceList.values) {
                if (device.productId == SEGMENT_PID && device.vendorId == SEGMENT_VID) {
                    screenDevice = device
                    Log.d(TAG, "Found segment device: PID=$SEGMENT_PID, VID=$SEGMENT_VID")
                    result.success(mapOf(
                        "found" to true,
                        "productId" to device.productId,
                        "vendorId" to device.vendorId,
                        "deviceName" to device.deviceName
                    ))
                    return
                }
            }
            
            result.success(mapOf("found" to false))
        } catch (e: Exception) {
            Log.e(TAG, "Error finding device", e)
            result.error("FIND_ERROR", e.message, null)
        }
    }
    
    private fun requestPermission(result: Result) {
        try {
            val device = screenDevice
            if (device == null) {
                result.error("NO_DEVICE", "No device found. Call findDevice first.", null)
                return
            }
            
            val usbManager = activity.getSystemService(Context.USB_SERVICE) as UsbManager
            
            if (usbManager.hasPermission(device)) {
                result.success(true)
                return
            }
            
            permissionCallback = result
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.FLAG_MUTABLE
            } else {
                0
            }
            val pendingIntent = PendingIntent.getBroadcast(
                activity, 
                0, 
                Intent(ACTION_USB_PERMISSION), 
                flags
            )
            usbManager.requestPermission(device, pendingIntent)
        } catch (e: Exception) {
            Log.e(TAG, "Error requesting permission", e)
            result.error("PERMISSION_ERROR", e.message, null)
        }
    }
    
    private fun connect(result: Result) {
        try {
            val device = screenDevice
            if (device == null) {
                result.error("NO_DEVICE", "No device found. Call findDevice first.", null)
                return
            }
            
            val connected = usbCommunication?.connectToDevice(device) ?: false
            if (connected) {
                usbCommunication?.startRead()
                Log.d(TAG, "Connected to segment device")
                result.success(true)
            } else {
                result.error("CONNECT_FAILED", "Failed to connect to device", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting", e)
            result.error("CONNECT_ERROR", e.message, null)
        }
    }
    
    private fun sendData(data: String, align: String, result: Result) {
        try {
            val cmd: Byte = when (align) {
                "left" -> 0x01
                "right" -> 0x00
                else -> 0x00
            }
            
            val success = usbCommunication?.sendData(cmd, data) ?: false
            if (success) {
                val receivedData = usbCommunication?.receiveData()
                if (receivedData != null) {
                    val valid = usbCommunication?.parseReceivedData(receivedData) ?: false
                    Log.d(TAG, "Data sent: $data, align: $align, valid: $valid")
                }
                result.success(true)
            } else {
                result.error("SEND_FAILED", "Failed to send data", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error sending data", e)
            result.error("SEND_ERROR", e.message, null)
        }
    }
    
    private fun clear(result: Result) {
        try {
            val success = usbCommunication?.sendData(0x03, "") ?: false
            if (success) {
                usbCommunication?.receiveData()
                Log.d(TAG, "Display cleared")
                result.success(true)
            } else {
                result.error("CLEAR_FAILED", "Failed to clear display", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing display", e)
            result.error("CLEAR_ERROR", e.message, null)
        }
    }
    
    private fun full(result: Result) {
        try {
            val success = usbCommunication?.sendData(0x04, "") ?: false
            if (success) {
                usbCommunication?.receiveData()
                Log.d(TAG, "Display set to full")
                result.success(true)
            } else {
                result.error("FULL_FAILED", "Failed to set display to full", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error setting display to full", e)
            result.error("FULL_ERROR", e.message, null)
        }
    }
    
    private fun disconnect(result: Result) {
        try {
            usbCommunication?.closeConnection()
            screenDevice = null
            Log.d(TAG, "Disconnected from segment device")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting", e)
            result.error("DISCONNECT_ERROR", e.message, null)
        }
    }
    
    fun cleanup() {
        try {
            activity.unregisterReceiver(usbReceiver)
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering receiver", e)
        }
        usbCommunication?.closeConnection()
        usbCommunication = null
        screenDevice = null
    }
}
