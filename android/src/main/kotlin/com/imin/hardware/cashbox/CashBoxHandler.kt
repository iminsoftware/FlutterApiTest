package com.imin.hardware.cashbox

import android.app.Activity
import android.util.Log
import com.imin.library.IminSDKManager
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class CashBoxHandler(private val activity: Activity) {
    companion object {
        private const val TAG = "CashBoxHandler"
    }

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "cashbox.open" -> openCashBox(result)
            "cashbox.getStatus" -> getCashBoxStatus(result)
            "cashbox.setVoltage" -> setVoltage(call, result)
            else -> result.notImplemented()
        }
    }

    private fun openCashBox(result: Result) {
        try {
            IminSDKManager.opencashBox(activity)
            Log.d(TAG, "Cash box opened")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error opening cash box", e)
            result.error("OPEN_FAILED", e.message, null)
        }
    }

    private fun getCashBoxStatus(result: Result) {
        try {
            val isOpen = IminSDKManager.isCashBoxOpen(activity)
            Log.d(TAG, "Cash box status: ${if (isOpen) "open" else "closed"}")
            result.success(isOpen)
        } catch (e: Exception) {
            Log.e(TAG, "Error getting cash box status", e)
            result.error("STATUS_FAILED", e.message, null)
        }
    }

    private fun setVoltage(call: MethodCall, result: Result) {
        try {
            val voltage = call.argument<String>("voltage")
            if (voltage == null) {
                result.error("INVALID_ARGUMENT", "Voltage is required", null)
                return
            }

            // 将电压字符串映射到 SDK 需要的值
            // "9V" -> "1", "12V" -> "2", "24V" -> "3"
            val voltageValue = when (voltage) {
                "9V" -> "1"
                "12V" -> "2"
                "24V" -> "3"
                else -> {
                    result.error("INVALID_VOLTAGE", "Invalid voltage: $voltage. Must be 9V, 12V, or 24V", null)
                    return
                }
            }

            val success = IminSDKManager.setCashBoxKeyValue(activity, voltageValue)
            Log.d(TAG, "Set voltage to $voltage (value: $voltageValue), result: $success")
            result.success(success)
        } catch (e: Exception) {
            Log.e(TAG, "Error setting voltage", e)
            result.error("SET_VOLTAGE_FAILED", e.message, null)
        }
    }

    fun cleanup() {
        // 钱箱不需要特殊清理
        Log.d(TAG, "CashBoxHandler cleanup")
    }
}
