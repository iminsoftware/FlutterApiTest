package com.imin.hardware.light

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
import com.imin.library.IminSDKManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class LightHandler(private val activity: Activity) {
    companion object {
        private const val TAG = "LightHandler"
        private const val ACTION_USB_PERMISSION = "android.permission.USB_PERMISSION"
        private const val ACTION_USB_DEVICE_ATTACHED = "android.hardware.usb.action.USB_DEVICE_ATTACHED"
        private const val ACTION_USB_DEVICE_DETACHED = "android.hardware.usb.action.USB_DEVICE_DETACHED"
    }

    private val usbManager: UsbManager = activity.getSystemService(Context.USB_SERVICE) as UsbManager
    private var usbDevice: UsbDevice? = null
    private var isReceiverRegistered = false

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "light.connect" -> connectDevice(result)
            "light.turnOnGreen" -> turnOnGreen(result)
            "light.turnOnRed" -> turnOnRed(result)
            "light.turnOff" -> turnOff(result)
            "light.disconnect" -> disconnectDevice(result)
            else -> result.notImplemented()
        }
    }

    private fun connectDevice(result: Result) {
        try {
            // 获取灯光设备
            usbDevice = IminSDKManager.getLightDevice(activity)
            
            if (usbDevice == null) {
                Log.w(TAG, "Light device not found")
                result.success(false)
                return
            }

            // 请求权限并连接
            val hasPermission = requestPermission(usbDevice!!)
            if (hasPermission) {
                val isConnected = IminSDKManager.connectLightDevice(activity)
                Log.d(TAG, "Light device connected: $isConnected")
                result.success(isConnected)
            } else {
                Log.d(TAG, "Waiting for USB permission...")
                // 权限请求已发送，等待广播接收器处理
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error connecting light device", e)
            result.error("CONNECT_FAILED", e.message, null)
        }
    }

    private fun turnOnGreen(result: Result) {
        try {
            IminSDKManager.turnOnGreenLight(activity)
            Log.d(TAG, "Green light turned on")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error turning on green light", e)
            result.error("GREEN_LIGHT_FAILED", e.message, null)
        }
    }

    private fun turnOnRed(result: Result) {
        try {
            IminSDKManager.turnOnRedLight(activity)
            Log.d(TAG, "Red light turned on")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error turning on red light", e)
            result.error("RED_LIGHT_FAILED", e.message, null)
        }
    }

    private fun turnOff(result: Result) {
        try {
            IminSDKManager.turnOffLight(activity)
            Log.d(TAG, "Light turned off")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error turning off light", e)
            result.error("TURN_OFF_FAILED", e.message, null)
        }
    }

    private fun disconnectDevice(result: Result) {
        try {
            IminSDKManager.disconnectLightDevice(activity)
            Log.d(TAG, "Light device disconnected")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error disconnecting light device", e)
            result.error("DISCONNECT_FAILED", e.message, null)
        }
    }

    private fun requestPermission(device: UsbDevice): Boolean {
        Log.d(TAG, "Requesting USB permission for light device")
        
        if (usbManager.hasPermission(device)) {
            Log.d(TAG, "USB permission already granted")
            return true
        }

        // 注册广播接收器
        if (!isReceiverRegistered) {
            val intentFilter = IntentFilter().apply {
                addAction(ACTION_USB_PERMISSION)
                addAction(ACTION_USB_DEVICE_ATTACHED)
                addAction(ACTION_USB_DEVICE_DETACHED)
            }
            activity.registerReceiver(usbDeviceReceiver, intentFilter)
            isReceiverRegistered = true
            Log.d(TAG, "USB receiver registered")
        }

        // 请求权限
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.getBroadcast(
                activity,
                0,
                Intent(ACTION_USB_PERMISSION),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            PendingIntent.getBroadcast(activity, 0, Intent(ACTION_USB_PERMISSION), 0)
        }

        usbManager.requestPermission(device, pendingIntent)
        return false
    }

    private val usbDeviceReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            Log.d(TAG, "USB broadcast received: $action")

            when (action) {
                ACTION_USB_PERMISSION -> {
                    val device = intent.getParcelableExtra<UsbDevice>(UsbManager.EXTRA_DEVICE)
                    if (device != null) {
                        val isConnected = IminSDKManager.connectLightDevice(activity)
                        Log.d(TAG, "USB permission granted, connected: $isConnected")
                    }
                }
                ACTION_USB_DEVICE_ATTACHED -> {
                    Log.d(TAG, "USB device attached")
                }
                ACTION_USB_DEVICE_DETACHED -> {
                    Log.d(TAG, "USB device detached")
                }
            }
        }
    }

    fun cleanup() {
        try {
            if (isReceiverRegistered) {
                activity.unregisterReceiver(usbDeviceReceiver)
                isReceiverRegistered = false
                Log.d(TAG, "USB receiver unregistered")
            }
            IminSDKManager.disconnectLightDevice(activity)
            Log.d(TAG, "LightHandler cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}
