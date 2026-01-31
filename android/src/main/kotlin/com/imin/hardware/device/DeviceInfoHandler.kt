package com.imin.hardware.device

import android.os.Build
import android.util.Log
import com.imin.library.SystemPropManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 设备信息处理器
 */
class DeviceInfoHandler : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "DeviceInfoHandler"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "device.getBrand" -> {
                try {
                    val brand = SystemPropManager.getBrand()
                    result.success(brand ?: "Unknown")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get brand", e)
                    result.success("iMin")
                }
            }
            "device.getModel" -> {
                try {
                    val model = SystemPropManager.getModel()
                    result.success(model ?: "Unknown")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get model", e)
                    result.success("Unknown")
                }
            }
            "device.getSerialNumber" -> {
                try {
                    val sn = SystemPropManager.getSn()
                    result.success(sn ?: "Unknown")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get serial number", e)
                    result.success("Unknown")
                }
            }
            "device.getDeviceName" -> {
                try {
                    val deviceName = SystemPropManager.getSystemProperties("persist.sys.device")
                    result.success(deviceName ?: "Unknown")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get device name", e)
                    result.success("Unknown")
                }
            }
            "device.getDeviceInfo" -> {
                try {
                    val brand = SystemPropManager.getBrand() ?: "iMin"
                    val model = SystemPropManager.getModel() ?: "Unknown"
                    val sn = SystemPropManager.getSn() ?: "Unknown"
                    val deviceName = SystemPropManager.getSystemProperties("persist.sys.device") ?: "Unknown"
                    
                    val info = mapOf(
                        "brand" to brand,
                        "model" to model,
                        "serialNumber" to sn,
                        "deviceName" to deviceName
                    )
                    result.success(info)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get device info", e)
                    result.success(mapOf(
                        "brand" to "iMin",
                        "model" to "Unknown",
                        "serialNumber" to "Unknown",
                        "deviceName" to "Unknown"
                    ))
                }
            }
            "device.getAndroidVersion" -> {
                try {
                    // 返回 Android SDK 版本号
                    // Android 11 = API 30
                    // Android 13 = API 33
                    val sdkInt = Build.VERSION.SDK_INT
                    result.success(sdkInt)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get Android version", e)
                    result.error("ERROR", "Failed to get Android version: ${e.message}", null)
                }
            }
            "device.getAndroidVersionName" -> {
                try {
                    // 返回 Android 版本名称，如 "11", "13"
                    val versionName = Build.VERSION.RELEASE
                    result.success(versionName)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to get Android version name", e)
                    result.error("ERROR", "Failed to get Android version name: ${e.message}", null)
                }
            }
            else -> result.notImplemented()
        }
    }
}
