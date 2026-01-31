package com.imin.hardware.scale

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * 电子秤处理器 (Android 13+ 新版 SDK)
 * 
 * 使用 iMinEscale_SDK.jar
 * 
 * 注意：此为 Mock 实现版本，用于编译通过
 * 在真机测试时，需要根据实际 SDK API 调整实现
 */
class ScaleNewHandler(
    private val context: Context,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "ScaleNewHandler"
    }
    
    private var eventSink: EventChannel.EventSink? = null
    private var isConnected = false
    private var isGettingData = false
    
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "scaleNew.connectService" -> connectService(result)
                "scaleNew.getData" -> getData(result)
                "scaleNew.cancelGetData" -> cancelGetData(result)
                "scaleNew.getServiceVersion" -> getServiceVersion(result)
                "scaleNew.getFirmwareVersion" -> getFirmwareVersion(result)
                "scaleNew.zero" -> zero(result)
                "scaleNew.tare" -> tare(result)
                "scaleNew.digitalTare" -> digitalTare(call, result)
                "scaleNew.setUnitPrice" -> setUnitPrice(call, result)
                "scaleNew.getUnitPrice" -> getUnitPrice(result)
                "scaleNew.setUnit" -> setUnit(call, result)
                "scaleNew.getUnit" -> getUnit(result)
                "scaleNew.readAcceleData" -> readAcceleData(result)
                "scaleNew.readSealState" -> readSealState(result)
                "scaleNew.getCalStatus" -> getCalStatus(result)
                "scaleNew.getCalInfo" -> getCalInfo(result)
                "scaleNew.restart" -> restart(result)
                "scaleNew.getCityAccelerations" -> getCityAccelerations(result)
                "scaleNew.setGravityAcceleration" -> setGravityAcceleration(call, result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Method call failed: ${call.method}", e)
            result.error("ERROR", "Method call failed: ${e.message}", null)
        }
    }
    
    private fun connectService(result: MethodChannel.Result) {
        try {
            Log.w(TAG, "Mock: connectService called")
            isConnected = true
            eventSink?.success(mapOf(
                "type" to "connection",
                "connected" to true,
                "timestamp" to System.currentTimeMillis()
            ))
            result.success(true)
        } catch (e: Exception) {
            result.error("CONNECT_FAILED", e.message, null)
        }
    }
    
    private fun getData(result: MethodChannel.Result) {
        try {
            if (!isConnected) {
                result.error("NOT_CONNECTED", "Service not connected", null)
                return
            }
            Log.w(TAG, "Mock: getData called")
            isGettingData = true
            
            // 启动模拟数据推送
            startMockDataPush()
            
            result.success(true)
        } catch (e: Exception) {
            result.error("GET_DATA_FAILED", e.message, null)
        }
    }
    
    // 模拟数据推送（用于测试）
    private fun startMockDataPush() {
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(object : Runnable {
            private var count = 0
            private var currentWeight = 0 // 当前稳定重量
            private var targetWeight = 1234 // 目标重量（模拟放上物品）
            private var isStabilizing = true // 是否正在稳定中
            
            override fun run() {
                if (!isGettingData || eventSink == null) return
                
                // 模拟称重过程
                if (isStabilizing) {
                    // 正在稳定：重量逐渐接近目标值
                    val diff = targetWeight - currentWeight
                    if (kotlin.math.abs(diff) > 10) {
                        currentWeight += (diff * 0.3).toInt() // 逐渐接近
                    } else {
                        currentWeight = targetWeight // 达到目标
                        isStabilizing = false // 稳定了
                        Log.d(TAG, "Mock: 称重已稳定在 ${currentWeight}g")
                    }
                } else {
                    // 已稳定：保持固定重量，不再波动
                    currentWeight = targetWeight
                }
                
                // 判断是否稳定
                val mockStable = !isStabilizing
                
                // 推送称重数据
                eventSink?.success(mapOf(
                    "type" to "weight",
                    "net" to currentWeight,
                    "tare" to 0,
                    "isStable" to mockStable,
                    "timestamp" to System.currentTimeMillis()
                ))
                
                // 模拟状态数据（每5秒）
                if (count % 5 == 0) {
                    eventSink?.success(mapOf(
                        "type" to "status",
                        "isLightWeight" to false,
                        "overload" to false,
                        "clearZeroErr" to false,
                        "calibrationErr" to false,
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                
                // 模拟计价数据（稳定时才推送）
                if (mockStable && count % 3 == 0) {
                    eventSink?.success(mapOf(
                        "type" to "price",
                        "net" to currentWeight,
                        "tare" to 0,
                        "unit" to 0,
                        "unitPrice" to "12.50",
                        "totalPrice" to String.format("%.2f", currentWeight / 1000.0 * 12.50),
                        "isStable" to true,
                        "isLightWeight" to false,
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                
                count++
                
                // 每秒推送一次
                android.os.Handler(android.os.Looper.getMainLooper()).postDelayed(this, 1000)
            }
        }, 1000)
    }
    
    private fun cancelGetData(result: MethodChannel.Result) {
        try {
            Log.w(TAG, "Mock: cancelGetData called")
            isGettingData = false
            result.success(true)
        } catch (e: Exception) {
            result.error("CANCEL_FAILED", e.message, null)
        }
    }
    
    private fun getServiceVersion(result: MethodChannel.Result) {
        result.success("1.0.0.13 (Mock)")
    }
    
    private fun getFirmwareVersion(result: MethodChannel.Result) {
        result.success("10034 (Mock)")
    }
    
    private fun zero(result: MethodChannel.Result) {
        Log.w(TAG, "Mock: zero called")
        result.success(true)
    }
    
    private fun tare(result: MethodChannel.Result) {
        Log.w(TAG, "Mock: tare called")
        result.success(true)
    }
    
    private fun digitalTare(call: MethodCall, result: MethodChannel.Result) {
        val weight = call.argument<Int>("weight")
        Log.w(TAG, "Mock: digitalTare called with weight: $weight")
        result.success(true)
    }
    
    private fun setUnitPrice(call: MethodCall, result: MethodChannel.Result) {
        val price = call.argument<String>("price")
        Log.w(TAG, "Mock: setUnitPrice called with price: $price")
        result.success(true)
    }
    
    private fun getUnitPrice(result: MethodChannel.Result) {
        result.success("0")
    }
    
    private fun setUnit(call: MethodCall, result: MethodChannel.Result) {
        val unit = call.argument<Int>("unit")
        Log.w(TAG, "Mock: setUnit called with unit: $unit")
        result.success(true)
    }
    
    private fun getUnit(result: MethodChannel.Result) {
        result.success(0)
    }
    
    private fun readAcceleData(result: MethodChannel.Result) {
        result.success(listOf(0, 0, 0))
    }
    
    private fun readSealState(result: MethodChannel.Result) {
        result.success(0)
    }
    
    private fun getCalStatus(result: MethodChannel.Result) {
        result.success(0)
    }
    
    private fun getCalInfo(result: MethodChannel.Result) {
        result.success(emptyList<List<Int>>())
    }
    
    private fun restart(result: MethodChannel.Result) {
        Log.w(TAG, "Mock: restart called")
        result.success(true)
    }
    
    private fun getCityAccelerations(result: MethodChannel.Result) {
        result.success(emptyList<String>())
    }
    
    private fun setGravityAcceleration(call: MethodCall, result: MethodChannel.Result) {
        val index = call.argument<Int>("index")
        Log.w(TAG, "Mock: setGravityAcceleration called with index: $index")
        result.success(true)
    }
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "EventChannel listener attached")
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "EventChannel listener cancelled")
    }
    
    fun cleanup() {
        isGettingData = false
        isConnected = false
        eventSink = null
    }
}
