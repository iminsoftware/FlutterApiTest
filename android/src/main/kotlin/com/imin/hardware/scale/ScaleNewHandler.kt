package com.imin.hardware.scale

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.RemoteException
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

// 导入真实的SDK类
import com.imin.scalelibrary.ScaleManager
import com.imin.scalelibrary.ScaleResult

/**
 * 电子秤处理器 (Android 13+ 新版 SDK)
 * 
 * 使用 iMinEscale_SDK.jar - 真实实现
 * 
 * 优化点:
 * 1. 统一异常处理
 * 2. 添加服务状态检查
 * 3. 自动重连机制
 * 4. 线程安全
 */
class ScaleNewHandler(
    private val context: Context,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "ScaleNewHandler"
        private const val ERROR_NOT_CONNECTED = "NOT_CONNECTED"
        private const val ERROR_SERVICE_UNAVAILABLE = "SERVICE_UNAVAILABLE"
        private const val RECONNECT_DELAY_MS = 2000L
        private const val MAX_RECONNECT_ATTEMPTS = 3  // 最多重连3次
        private const val MAX_RECONNECT_DELAY_MS = 10000L  // 最大延迟10秒
    }
    
    private var eventSink: EventChannel.EventSink? = null
    
    @Volatile
    private var isConnected = false
    
    @Volatile
    private var isGettingData = false
    
    private val mainHandler = Handler(Looper.getMainLooper())
    
    // 轮询相关
    private var pollingRunnable: Runnable? = null
    private val POLLING_INTERVAL_MS = 1000L // 每秒轮询一次
    
    // 重连相关
    private var reconnectAttempts = 0
    private var reconnectRunnable: Runnable? = null
    
    // 真实的SDK实例 - 使用 lazy 初始化
    private val scaleManager: ScaleManager by lazy {
        ScaleManager.getInstance(context)
    }
    
    // 服务连接回调 - 复用实例
    private val serviceConnection = object : ScaleManager.ScaleServiceConnection {
        override fun onServiceConnected() {
            Log.d(TAG, "Scale service connected")
            isConnected = true
            reconnectAttempts = 0  // 重置重连次数
            
            sendEvent(mapOf(
                "type" to "connection",
                "connected" to true,
                "timestamp" to System.currentTimeMillis()
            ))
            
            // ✅ 关键：在服务连接成功后，如果需要自动开始获取数据
            if (autoStartGetData) {
                Log.d(TAG, "Auto starting getData after service connected...")
                mainHandler.postDelayed({
                    try {
                        startGetDataInternal()
                    } catch (e: Exception) {
                        Log.e(TAG, "Auto start getData failed", e)
                    }
                }, 500) // 延迟 500ms 确保服务完全就绪
            }
        }
        
        override fun onServiceDisconnect() {
            Log.w(TAG, "Scale service disconnected")
            isConnected = false
            isGettingData = false
            sendEvent(mapOf(
                "type" to "connection",
                "connected" to false,
                "timestamp" to System.currentTimeMillis()
            ))
            // 自动重连（带限制）
            scheduleReconnect()
        }
    }
    
    @Volatile
    private var autoStartGetData = false
    
    // 内部方法：实际开始获取数据
    private fun startGetDataInternal() {
        try {
            Log.d(TAG, "Starting data acquisition (internal)...")
            
            // 尝试先调用 reqWeightOutPut 启动数据输出
            try {
                scaleManager.reqWeightOutPut()
                Log.d(TAG, "reqWeightOutPut() called")
            } catch (e: Exception) {
                Log.w(TAG, "reqWeightOutPut() failed: ${e.message}")
            }
            
            // 调用 getData - 只使用 ScaleResult（根据官方示例）
            Log.d(TAG, "Calling getData with ScaleResult callback...")
            scaleManager.getData(scaleResultCallback)
            Log.d(TAG, "getData() called successfully")
            
            isGettingData = true
            
            // 启动轮询（持续请求数据）
            startPolling()
        } catch (e: Exception) {
            Log.e(TAG, "startGetDataInternal failed", e)
            throw e
        }
    }
    
    /**
     * 开始轮询 - 持续请求重量数据
     */
    private fun startPolling() {
        stopPolling()
        Log.d(TAG, "Starting polling...")
        pollingRunnable = object : Runnable {
            override fun run() {
                if (isGettingData && isConnected) {
                    try {
                        scaleManager.reqWeightOutPut()
                        Log.d(TAG, "⏱️ Polling: reqWeightOutPut() called")
                    } catch (e: Exception) {
                        Log.e(TAG, "Polling failed", e)
                    }
                    mainHandler.postDelayed(this, POLLING_INTERVAL_MS)
                }
            }
        }
        mainHandler.postDelayed(pollingRunnable!!, POLLING_INTERVAL_MS)
    }
    
    /**
     * 停止轮询
     */
    private fun stopPolling() {
        pollingRunnable?.let {
            mainHandler.removeCallbacks(it)
            pollingRunnable = null
            Log.d(TAG, "Polling stopped")
        }
    }
    
    // 称重数据回调 - 复用实例 (使用 ScaleResult - 根据官方示例)
    private val scaleResultCallback = object : ScaleResult() {
        @Throws(RemoteException::class)
        override fun getResult(net: Int, tare: Int, isStable: Boolean) {
            Log.d(TAG, "📊 Callback: getResult - net=$net, tare=$tare, isStable=$isStable")
            sendEvent(mapOf(
                "type" to "weight",
                "net" to net,
                "tare" to tare,
                "isStable" to isStable,
                "timestamp" to System.currentTimeMillis()
            ))
        }
        
        @Throws(RemoteException::class)
        override fun getStatus(
            isLightWeight: Boolean,
            overload: Boolean,
            clearZeroErr: Boolean,
            calibrationErr: Boolean
        ) {
            Log.d(TAG, "📊 Callback: getStatus - isLightWeight=$isLightWeight, overload=$overload")
            sendEvent(mapOf(
                "type" to "status",
                "isLightWeight" to isLightWeight,
                "overload" to overload,
                "clearZeroErr" to clearZeroErr,
                "calibrationErr" to calibrationErr,
                "timestamp" to System.currentTimeMillis()
            ))
        }
        
        override fun getPrice(
            net: Int,
            tare: Int,
            unit: Int,
            unitPrice: String?,
            totalPrice: String?,
            isStable: Boolean,
            isLightWeight: Boolean
        ) {
            Log.d(TAG, "📊 Callback: getPrice - net=$net, unitPrice=$unitPrice, totalPrice=$totalPrice")
            sendEvent(mapOf(
                "type" to "price",
                "net" to net,
                "tare" to tare,
                "unit" to unit,
                "unitPrice" to (unitPrice ?: "0"),
                "totalPrice" to (totalPrice ?: "0"),
                "isStable" to isStable,
                "isLightWeight" to isLightWeight,
                "timestamp" to System.currentTimeMillis()
            ))
        }
        
        override fun error(errorCode: Int) {
            Log.e(TAG, "❌ Callback: error - errorCode=$errorCode")
            sendEvent(mapOf(
                "type" to "error",
                "errorCode" to errorCode,
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }
    
    // ==================== 辅助方法 ====================
    
    /**
     * 发送事件到 Flutter
     */
    private fun sendEvent(data: Map<String, Any>) {
        mainHandler.post {
            eventSink?.success(data)
        }
    }
    
    /**
     * 检查服务连接状态
     */
    private fun checkConnection(result: MethodChannel.Result): Boolean {
        if (!isConnected) {
            result.error(ERROR_NOT_CONNECTED, "Scale service not connected", null)
            return false
        }
        return true
    }
    
    /**
     * 安全执行 ScaleManager 操作
     */
    private inline fun <T> safeExecute(
        result: MethodChannel.Result,
        defaultValue: T? = null,
        checkConnection: Boolean = true,
        block: (ScaleManager) -> T
    ) {
        try {
            if (checkConnection && !isConnected) {
                if (defaultValue != null) {
                    result.success(defaultValue)
                } else {
                    result.error(ERROR_NOT_CONNECTED, "Scale service not connected", null)
                }
                return
            }
            
            val value = block(scaleManager)
            result.success(value)
        } catch (e: RemoteException) {
            Log.e(TAG, "RemoteException", e)
            if (defaultValue != null) {
                result.success(defaultValue)
            } else {
                result.error(ERROR_SERVICE_UNAVAILABLE, "Service call failed: ${e.message}", null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Unexpected error", e)
            if (defaultValue != null) {
                result.success(defaultValue)
            } else {
                result.error("ERROR", "Unexpected error: ${e.message}", null)
            }
        }
    }
    
    /**
     * 自动重连（带限制和指数退避）
     */
    private fun scheduleReconnect() {
        // 取消之前的重连任务
        reconnectRunnable?.let {
            mainHandler.removeCallbacks(it)
        }
        
        if (reconnectAttempts >= MAX_RECONNECT_ATTEMPTS) {
            Log.e(TAG, "Max reconnect attempts ($MAX_RECONNECT_ATTEMPTS) reached, giving up")
            sendEvent(mapOf(
                "type" to "error",
                "errorCode" to -999,
                "message" to "Max reconnect attempts reached",
                "timestamp" to System.currentTimeMillis()
            ))
            return
        }
        
        reconnectAttempts++
        
        // 指数退避：2秒、4秒、8秒，最多10秒
        val delay = minOf(
            RECONNECT_DELAY_MS * (1 shl (reconnectAttempts - 1)),
            MAX_RECONNECT_DELAY_MS
        )
        
        Log.d(TAG, "Scheduling reconnect attempt $reconnectAttempts/$MAX_RECONNECT_ATTEMPTS in ${delay}ms")
        
        reconnectRunnable = Runnable {
            if (!isConnected) {
                Log.d(TAG, "Attempting to reconnect (attempt $reconnectAttempts)...")
                try {
                    scaleManager.connectService(serviceConnection)
                } catch (e: Exception) {
                    Log.e(TAG, "Reconnect attempt $reconnectAttempts failed", e)
                    // 如果还有重连次数，继续尝试
                    if (reconnectAttempts < MAX_RECONNECT_ATTEMPTS) {
                        scheduleReconnect()
                    }
                }
            }
        }
        
        mainHandler.postDelayed(reconnectRunnable!!, delay)
    }
    
    /**
     * 取消重连
     */
    private fun cancelReconnect() {
        reconnectRunnable?.let {
            mainHandler.removeCallbacks(it)
            reconnectRunnable = null
        }
        reconnectAttempts = 0
        Log.d(TAG, "Reconnect cancelled")
    }
    
    // ==================== 方法处理 ====================
    
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
                "scaleNew.reqWeightOutPut" -> reqWeightOutPut(result)
                "scaleNew.stopWeightOutput" -> stopWeightOutput(result)
                "scaleNew.testCallback" -> testCallback(result)
                "scaleNew.diagnose" -> diagnose(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Method call failed: ${call.method}", e)
            result.error("ERROR", "Method call failed: ${e.message}", null)
        }
    }
    
    // ==================== 服务连接 ====================
    
    private fun connectService(result: MethodChannel.Result) {
        try {
            Log.d(TAG, "Connecting to scale service...")
            // 重置重连计数
            reconnectAttempts = 0
            cancelReconnect()
            
            scaleManager.connectService(serviceConnection)
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Connect service failed", e)
            result.error("CONNECT_FAILED", e.message, null)
        }
    }
    
    // ==================== 数据获取 ====================
    
    private fun getData(result: MethodChannel.Result) {
        try {
            if (!isConnected) {
                // 如果还没连接，先连接服务，连接成功后自动开始获取数据
                Log.d(TAG, "Service not connected, connecting first...")
                autoStartGetData = true
                scaleManager.connectService(serviceConnection)
                result.success(true)
                return
            }
            
            // 如果已连接，直接开始获取数据
            startGetDataInternal()
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Get data failed - RemoteException", e)
            e.printStackTrace()
            result.error("GET_DATA_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Get data failed - Exception", e)
            e.printStackTrace()
            result.error("GET_DATA_FAILED", e.message, null)
        }
    }
    
    private fun cancelGetData(result: MethodChannel.Result) {
        try {
            // 停止轮询
            stopPolling()
            
            // 停止数据输出
            try {
                scaleManager.stopWeightOutput()
                Log.d(TAG, "stopWeightOutput() called")
            } catch (e: Exception) {
                Log.w(TAG, "stopWeightOutput() failed: ${e.message}")
            }
            
            // 取消获取数据
            scaleManager.cancelGetData()
            isGettingData = false
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Cancel get data failed - RemoteException", e)
            result.error("CANCEL_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Cancel get data failed", e)
            result.error("CANCEL_FAILED", e.message, null)
        }
    }
    
    // ==================== 版本信息 ====================
    
    private fun getServiceVersion(result: MethodChannel.Result) {
        safeExecute(result, "Unknown", checkConnection = false) {
            it.serviceVersion ?: "Unknown"
        }
    }
    
    private fun getFirmwareVersion(result: MethodChannel.Result) {
        safeExecute(result, "Unknown") {
            it.firmwareVersion ?: "Unknown"
        }
    }
    
    // ==================== 称重操作 ====================
    
    private fun zero(result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        try {
            scaleManager.zero()  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Zero failed - RemoteException", e)
            result.error("ZERO_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Zero failed", e)
            result.error("ZERO_FAILED", e.message, null)
        }
    }
    
    private fun tare(result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        try {
            scaleManager.tare()  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Tare failed - RemoteException", e)
            result.error("TARE_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Tare failed", e)
            result.error("TARE_FAILED", e.message, null)
        }
    }
    
    private fun digitalTare(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        val weight = call.argument<Int>("weight") ?: 0
        try {
            scaleManager.digitalTare(weight)  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Digital tare failed - RemoteException", e)
            result.error("DIGITAL_TARE_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Digital tare failed", e)
            result.error("DIGITAL_TARE_FAILED", e.message, null)
        }
    }
    
    // ==================== 价格计算 ====================
    
    private fun setUnitPrice(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        val price = call.argument<String>("price") ?: "0"
        try {
            scaleManager.setUnitPrice(price)  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Set unit price failed - RemoteException", e)
            result.error("SET_UNIT_PRICE_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Set unit price failed", e)
            result.error("SET_UNIT_PRICE_FAILED", e.message, null)
        }
    }
    
    private fun getUnitPrice(result: MethodChannel.Result) {
        safeExecute(result, "0") {
            it.unitPrice ?: "0"
        }
    }
    
    private fun setUnit(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        val unit = call.argument<Int>("unit") ?: 0
        try {
            scaleManager.setUnit(unit)  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Set unit failed - RemoteException", e)
            result.error("SET_UNIT_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Set unit failed", e)
            result.error("SET_UNIT_FAILED", e.message, null)
        }
    }
    
    private fun getUnit(result: MethodChannel.Result) {
        safeExecute(result, 0) {
            it.unit
        }
    }
    
    // ==================== 设备信息 ====================
    
    private fun readAcceleData(result: MethodChannel.Result) {
        safeExecute(result, listOf(0, 0, 0)) {
            it.readAcceleData()?.toList() ?: listOf(0, 0, 0)
        }
    }
    
    private fun readSealState(result: MethodChannel.Result) {
        safeExecute(result, 0) {
            it.stealStatus
        }
    }
    
    private fun getCalStatus(result: MethodChannel.Result) {
        safeExecute(result, 0) {
            it.calStatus
        }
    }
    
    private fun getCalInfo(result: MethodChannel.Result) {
        safeExecute(result, emptyList<List<Int>>()) {
            it.calInfo?.map { arr -> arr.toList() } ?: emptyList()
        }
    }
    
    // ==================== 系统设置 ====================
    
    private fun restart(result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        try {
            scaleManager.restart()  // void 方法
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "Restart failed - RemoteException", e)
            result.error("RESTART_FAILED", "Service call failed: ${e.message}", null)
        } catch (e: Exception) {
            Log.e(TAG, "Restart failed", e)
            result.error("RESTART_FAILED", e.message, null)
        }
    }
    
    private fun getCityAccelerations(result: MethodChannel.Result) {
        safeExecute(result, emptyList<String>()) {
            it.cityAccelerations ?: emptyList()
        }
    }
    
    private fun setGravityAcceleration(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        val index = call.argument<Int>("index") ?: 0
        safeExecute(result, false) {
            val returnCode = it.setGravityAcceleration(index)
            returnCode == 0  // 0 表示成功
        }
    }
    
    // ==================== 测试和调试方法 ====================
    
    private fun reqWeightOutPut(result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        try {
            Log.d(TAG, "Calling reqWeightOutPut()...")
            scaleManager.reqWeightOutPut()
            Log.d(TAG, "reqWeightOutPut() success")
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "reqWeightOutPut failed", e)
            result.error("REQ_WEIGHT_OUTPUT_FAILED", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "reqWeightOutPut failed", e)
            result.error("REQ_WEIGHT_OUTPUT_FAILED", e.message, null)
        }
    }
    
    private fun stopWeightOutput(result: MethodChannel.Result) {
        if (!checkConnection(result)) return
        try {
            Log.d(TAG, "Calling stopWeightOutput()...")
            scaleManager.stopWeightOutput()
            Log.d(TAG, "stopWeightOutput() success")
            result.success(true)
        } catch (e: RemoteException) {
            Log.e(TAG, "stopWeightOutput failed", e)
            result.error("STOP_WEIGHT_OUTPUT_FAILED", e.message, null)
        } catch (e: Exception) {
            Log.e(TAG, "stopWeightOutput failed", e)
            result.error("STOP_WEIGHT_OUTPUT_FAILED", e.message, null)
        }
    }
    
    private fun testCallback(result: MethodChannel.Result) {
        Log.d(TAG, "🧪 Testing callbacks manually...")
        try {
            // 测试 ScaleResult 回调
            Log.d(TAG, "🧪 Testing ScaleResult callbacks...")
            scaleResultCallback.getResult(1234, 567, true)
            scaleResultCallback.getStatus(false, false, false, false)
            scaleResultCallback.getPrice(1234, 567, 0, "10.5", "12.95", true, false)
            
            Log.d(TAG, "🧪 All test callbacks triggered")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "🧪 Test callback failed", e)
            result.error("TEST_FAILED", e.message, null)
        }
    }
    
    private fun diagnose(result: MethodChannel.Result) {
        Log.d(TAG, "🔍 Running diagnostics...")
        val diagnostics = mutableMapOf<String, Any>()
        
        try {
            // 1. 检查连接状态
            diagnostics["isConnected"] = isConnected
            diagnostics["isGettingData"] = isGettingData
            
            // 2. 检查服务版本
            try {
                val serviceVersion = scaleManager.serviceVersion
                diagnostics["serviceVersion"] = serviceVersion ?: "null"
                Log.d(TAG, "🔍 Service version: $serviceVersion")
                
                if (serviceVersion == null || serviceVersion.isEmpty()) {
                    Log.e(TAG, "🔍 ❌ Service version is null/empty - IScaleService may be null!")
                    diagnostics["serviceVersionError"] = "IScaleService is null - service not properly bound"
                }
            } catch (e: Exception) {
                Log.e(TAG, "🔍 Service version error", e)
                diagnostics["serviceVersion"] = "error: ${e.message}"
            }
            
            // 3. 检查固件版本
            try {
                val firmwareVersion = scaleManager.firmwareVersion
                diagnostics["firmwareVersion"] = firmwareVersion ?: "null"
                Log.d(TAG, "🔍 Firmware version: $firmwareVersion")
                
                if (firmwareVersion == null || firmwareVersion.isEmpty()) {
                    Log.e(TAG, "🔍 ❌ Firmware version is null/empty - Scale hardware may not be connected!")
                    diagnostics["firmwareVersionError"] = "Scale hardware not connected or not supported"
                }
            } catch (e: Exception) {
                Log.e(TAG, "🔍 Firmware version error", e)
                diagnostics["firmwareVersion"] = "error: ${e.message}"
            }
            
            // 4. 检查单价
            try {
                val unitPrice = scaleManager.unitPrice
                diagnostics["unitPrice"] = unitPrice ?: "null"
                Log.d(TAG, "🔍 Unit price: $unitPrice")
            } catch (e: Exception) {
                diagnostics["unitPrice"] = "error: ${e.message}"
            }
            
            // 5. 检查单位
            try {
                val unit = scaleManager.unit
                diagnostics["unit"] = unit
                Log.d(TAG, "🔍 Unit: $unit")
            } catch (e: Exception) {
                diagnostics["unit"] = "error: ${e.message}"
            }
            
            // 6. 检查电子秤序列号
            try {
                val serial = scaleManager.eScaleSerial
                diagnostics["serial"] = serial ?: "null"
                Log.d(TAG, "🔍 Serial: $serial")
                
                if (serial == null || serial.isEmpty()) {
                    Log.e(TAG, "🔍 ❌ Serial is null/empty - Scale hardware NOT connected!")
                    diagnostics["hardwareStatus"] = "NOT_CONNECTED"
                } else {
                    diagnostics["hardwareStatus"] = "CONNECTED"
                }
            } catch (e: Exception) {
                Log.e(TAG, "🔍 Serial error", e)
                diagnostics["serial"] = "error: ${e.message}"
                diagnostics["hardwareStatus"] = "ERROR"
            }
            
            // 7. 检查电子秤状态
            try {
                val status = scaleManager.scaleStatus
                diagnostics["scaleStatus"] = status
                Log.d(TAG, "🔍 Scale status: $status")
            } catch (e: Exception) {
                diagnostics["scaleStatus"] = "error: ${e.message}"
            }
            
            // 8. 检查最大重量
            try {
                val maxKg = scaleManager.maxKg
                diagnostics["maxKg"] = maxKg
                Log.d(TAG, "🔍 Max kg: $maxKg")
            } catch (e: Exception) {
                diagnostics["maxKg"] = "error: ${e.message}"
            }
            
            // 9. 总结
            val summary = when {
                diagnostics["serviceVersion"] == "null" || diagnostics["serviceVersion"] == "" -> 
                    "❌ 电子秤服务未正确连接 (IScaleService is null)"
                diagnostics["serial"] == "null" || diagnostics["serial"] == "" -> 
                    "❌ 电子秤硬件未连接或不支持"
                else -> 
                    "✅ 电子秤服务和硬件都已连接"
            }
            diagnostics["summary"] = summary
            Log.d(TAG, "🔍 Summary: $summary")
            
            Log.d(TAG, "🔍 Diagnostics complete: $diagnostics")
            result.success(diagnostics)
        } catch (e: Exception) {
            Log.e(TAG, "🔍 Diagnostics failed", e)
            result.error("DIAGNOSE_FAILED", e.message, null)
        }
    }
    
    // ==================== EventChannel 处理 ====================
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "EventChannel listener attached")
    }
    
    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "EventChannel listener cancelled")
    }
    
    // ==================== 清理资源 ====================
    
    fun cleanup() {
        try {
            // 停止轮询
            stopPolling()
            
            // 取消重连
            cancelReconnect()
            
            mainHandler.removeCallbacksAndMessages(null)
            
            if (isGettingData) {
                scaleManager.cancelGetData()
                isGettingData = false
            }
            
            if (isConnected) {
                scaleManager.disconnectService()
                isConnected = false
            }
            
            eventSink = null
            Log.d(TAG, "Cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Cleanup failed", e)
        }
    }
}
