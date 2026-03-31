package com.imin.hardware.rfid

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.imin.rfid.RFIDManager
import com.imin.rfid.ReaderCall
import com.imin.rfid.constant.CMD
import com.imin.rfid.constant.ParamCts
import com.imin.rfid.entity.*
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * RFID Handler - 基于 IminRfidSdk1.0.5.jar 实现
 */
class RfidHandler(
    private val context: Context,
    private val activity: Activity?
) : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val TAG = "RfidHandler"
    }

    private var tagEventSink: EventChannel.EventSink? = null
    private var connectionEventSink: EventChannel.EventSink? = null
    private var batteryEventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var rfidManager: RFIDManager? = null
    @Volatile
    private var isConnected = false
    @Volatile
    private var isReading = false
    private var broadcastReceiver: BroadcastReceiver? = null

    // ReaderCall callback
    private val readerCall = object : ReaderCall() {
        override fun onSuccess(cmd: Byte, data: DataParameter) {
            Log.d(TAG, "onSuccess cmd=$cmd")
            when (cmd) {
                CMD.READ_TAG -> {
                    val tagData = data.getString(ParamCts.TAG_DATA, "")
                    sendTagEvent(mapOf(
                        "type" to "read_success",
                        "data" to tagData,
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                CMD.WRITE_TAG -> {
                    sendTagEvent(mapOf(
                        "type" to "write_success",
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                CMD.LOCK_TAG -> {
                    sendTagEvent(mapOf(
                        "type" to "lock_success",
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                CMD.KILL_TAG -> {
                    sendTagEvent(mapOf(
                        "type" to "kill_success",
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
            }
        }

        override fun onTag(cmd: Byte, state: Byte, data: DataParameter) {
            if (state == ParamCts.FOUND_TAG || state == ParamCts.UPDATE_TAG) {
                val epc = data.getString(ParamCts.TAG_EPC, "")
                val pc = data.getString(ParamCts.TAG_PC, "")
                val rssi = data.getInt(ParamCts.TAG_RSSI, 0)
                val count = data.getInt(ParamCts.TAG_READ_COUNT, 1)
                val freq = data.getInt(ParamCts.TAG_FREQ, 0)
                val tid = data.getString(ParamCts.TAG_DATA, "")

                sendTagEvent(mapOf(
                    "type" to "tag",
                    "epc" to epc,
                    "pc" to pc,
                    "tid" to tid,
                    "rssi" to rssi,
                    "count" to count,
                    "frequency" to freq,
                    "timestamp" to System.currentTimeMillis()
                ))
            }
        }

        override fun onFiled(cmd: Byte, errorCode: Byte, msg: String?) {
            Log.e(TAG, "onFiled cmd=$cmd, errorCode=$errorCode, msg=$msg")
            sendTagEvent(mapOf(
                "type" to "error",
                "cmd" to cmd.toInt(),
                "errorCode" to errorCode.toInt(),
                "message" to (msg ?: "Unknown error"),
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }

    fun handle(call: MethodCall, methodResult: MethodChannel.Result) {
        onMethodCall(call, methodResult)
    }

    override fun onMethodCall(call: MethodCall, methodResult: MethodChannel.Result) {
        Log.d(TAG, "RFID method: ${call.method}")
        try {
            when (call.method) {
                "rfid.connect" -> connect(methodResult)
                "rfid.disconnect" -> disconnect(methodResult)
                "rfid.isConnected" -> methodResult.success(isConnected)
                "rfid.startReading" -> startReading(methodResult)
                "rfid.stopReading" -> stopReading(methodResult)
                "rfid.readTag" -> readTag(call, methodResult)
                "rfid.writeTag" -> writeTag(call, methodResult)
                "rfid.writeEpc" -> writeEpc(call, methodResult)
                "rfid.lockTag" -> lockTag(call, methodResult)
                "rfid.killTag" -> killTag(call, methodResult)
                "rfid.clearTags" -> clearTags(methodResult)
                "rfid.setReadPower" -> setReadPower(call, methodResult)
                "rfid.setFilter" -> setFilter(call, methodResult)
                "rfid.clearFilter" -> clearFilter(methodResult)
                "rfid.setRssiFilter" -> setRssiFilter(call, methodResult)
                "rfid.setGen2Q" -> setGen2Q(call, methodResult)
                "rfid.setSession" -> setSession(call, methodResult)
                "rfid.setTarget" -> setTarget(call, methodResult)
                "rfid.setRfMode" -> setRfMode(call, methodResult)
                "rfid.getBatteryLevel" -> getBatteryLevel(methodResult)
                "rfid.isCharging" -> methodResult.success(false)
                else -> methodResult.notImplemented()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Method call failed: ${call.method}", e)
            methodResult.error("ERROR", e.message, null)
        }
    }

    // ==================== Connection ====================

    private fun connect(result: MethodChannel.Result) {
        try {
            rfidManager = RFIDManager.getInstance()
            rfidManager?.connect(context)

            // Register reader callback
            val helper = rfidManager?.helper
            if (helper != null) {
                helper.registerReaderCall(readerCall)
                isConnected = true
                sendConnectionEvent(true)
                Log.d(TAG, "RFID connected")
                result.success(null)
            } else {
                // Helper may not be available immediately, wait a bit
                mainHandler.postDelayed({
                    val h = rfidManager?.helper
                    if (h != null) {
                        h.registerReaderCall(readerCall)
                        isConnected = true
                        sendConnectionEvent(true)
                        Log.d(TAG, "RFID connected (delayed)")
                        result.success(null)
                    } else {
                        isConnected = false
                        result.error("CONNECT_FAILED", "RFID helper not available", null)
                    }
                }, 1000)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Connect failed", e)
            isConnected = false
            result.error("CONNECT_FAILED", e.message, null)
        }
    }

    private fun disconnect(result: MethodChannel.Result) {
        try {
            if (isReading) {
                rfidManager?.helper?.tagInventoryRawStopReading()
                isReading = false
            }
            rfidManager?.helper?.unregisterReaderCall()
            rfidManager?.disconnect()
            isConnected = false
            sendConnectionEvent(false)
            Log.d(TAG, "RFID disconnected")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Disconnect failed", e)
            result.error("DISCONNECT_FAILED", e.message, null)
        }
    }

    // ==================== Tag Reading ====================

    private fun startReading(result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        try {
            rfidManager?.helper?.tagInventoryRawStartReading()
            isReading = true
            Log.d(TAG, "Start reading")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Start reading failed", e)
            result.error("START_READING_FAILED", e.message, null)
        }
    }

    private fun stopReading(result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        try {
            rfidManager?.helper?.tagInventoryRawStopReading()
            isReading = false
            Log.d(TAG, "Stop reading")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Stop reading failed", e)
            result.error("STOP_READING_FAILED", e.message, null)
        }
    }

    private fun readTag(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val bank = (call.argument<Int>("bank") ?: 1).toByte()
        val address = (call.argument<Int>("address") ?: 2).toByte()
        val length = (call.argument<Int>("length") ?: 6).toByte()
        val password = hexStringToByteArray(call.argument<String>("password") ?: "")
        try {
            rfidManager?.helper?.readTag(bank, address, length, password)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Read tag failed", e)
            result.error("READ_TAG_FAILED", e.message, null)
        }
    }

    private fun clearTags(result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        try {
            rfidManager?.helper?.extendOperation(CMD.CLEAR_TAG, "")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Clear tags failed", e)
            result.error("CLEAR_TAGS_FAILED", e.message, null)
        }
    }

    // ==================== Tag Writing ====================

    private fun writeTag(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val bank = (call.argument<Int>("bank") ?: 1).toByte()
        val address = (call.argument<Int>("address") ?: 2).toByte()
        val data = call.argument<String>("data") ?: ""
        val password = hexStringToByteArray(call.argument<String>("password") ?: "")
        val dataBytes = hexStringToByteArray(data)
        val dataLen = (dataBytes.size / 2).toByte()
        try {
            rfidManager?.helper?.writeTag(password, bank, address, dataLen, dataBytes)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Write tag failed", e)
            result.error("WRITE_TAG_FAILED", e.message, null)
        }
    }

    private fun writeEpc(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val newEpc = call.argument<String>("newEpc") ?: ""
        val password = hexStringToByteArray(call.argument<String>("password") ?: "")
        val epcBytes = hexStringToByteArray(newEpc)
        val wordCount = (epcBytes.size / 2).toByte()
        try {
            // EPC is in bank 1, starting at address 2
            rfidManager?.helper?.writeTag(password, 1, 2, wordCount, epcBytes)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Write EPC failed", e)
            result.error("WRITE_EPC_FAILED", e.message, null)
        }
    }

    // ==================== Tag Operations ====================

    private fun lockTag(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val lockObject = (call.argument<Int>("lockObject") ?: 0).toByte()
        val lockType = (call.argument<Int>("lockType") ?: 0).toByte()
        val password = hexStringToByteArray(call.argument<String>("password") ?: "")
        try {
            rfidManager?.helper?.lockTag(password, lockObject, lockType)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Lock tag failed", e)
            result.error("LOCK_TAG_FAILED", e.message, null)
        }
    }

    private fun killTag(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val password = hexStringToByteArray(call.argument<String>("password") ?: "")
        try {
            rfidManager?.helper?.killTag(password)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Kill tag failed", e)
            result.error("KILL_TAG_FAILED", e.message, null)
        }
    }

    // ==================== Configuration ====================

    private fun setReadPower(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val readPower = call.argument<Int>("readPower") ?: 30
        val writePower = call.argument<Int>("writePower") ?: 30
        try {
            val config = ReadWritePower().apply {
                this.readPower = readPower
                this.writePower = writePower
            }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_READ_WRITE_POWER, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set power failed", e)
            result.error("SET_POWER_FAILED", e.message, null)
        }
    }

    private fun setFilter(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val epc = call.argument<String>("epc") ?: ""
        try {
            val epcBytes = hexStringToByteArray(epc)
            val bitLen = (epcBytes.size * 8).toByte()
            // Filter on EPC bank (1), starting at bit offset 32 (after PC)
            rfidManager?.helper?.setTagInventoryRawFilter(true, 1, 32, epcBytes)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set filter failed", e)
            result.error("SET_FILTER_FAILED", e.message, null)
        }
    }

    private fun clearFilter(result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        try {
            rfidManager?.helper?.extendOperation(CMD.CLEAR_TAG_FILTER, "")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Clear filter failed", e)
            result.error("CLEAR_FILTER_FAILED", e.message, null)
        }
    }

    private fun setRssiFilter(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val enabled = call.argument<Boolean>("enabled") ?: false
        val level = call.argument<Int>("level") ?: -70
        try {
            val config = ReceiveRssiFilter().apply {
                isEnable = enabled
                this.level = level
            }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_RECEIVE_FILTER_RSSI_LEVEl, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set RSSI filter failed", e)
            result.error("SET_RSSI_FILTER_FAILED", e.message, null)
        }
    }

    private fun setGen2Q(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val qValue = call.argument<Int>("qValue") ?: -1
        try {
            val config = Gen2QConfig().apply { value = qValue }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_GEN2_Q_CONFIG, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set Gen2 Q failed", e)
            result.error("SET_GEN2Q_FAILED", e.message, null)
        }
    }

    private fun setSession(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val session = call.argument<Int>("session") ?: 0
        try {
            val config = SessionModeConfig().apply { value = session }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_SESSION_MODE_CONFIG, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set session failed", e)
            result.error("SET_SESSION_FAILED", e.message, null)
        }
    }

    private fun setTarget(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val target = call.argument<Int>("target") ?: 0
        try {
            val config = TargetModeConfig().apply { value = target }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_TARGET_MODE_CONFIG, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set target failed", e)
            result.error("SET_TARGET_FAILED", e.message, null)
        }
    }

    private fun setRfMode(call: MethodCall, result: MethodChannel.Result) {
        if (!checkConnected(result)) return
        val rfMode = call.argument<String>("rfMode") ?: "RF_MODE_1"
        try {
            val config = RfModeConfig().apply { value = rfMode }
            val json = com.google.gson.Gson().toJson(config)
            rfidManager?.helper?.extendOperation(CMD.SET_RFMODE_CONFIG, json)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Set RF mode failed", e)
            result.error("SET_RF_MODE_FAILED", e.message, null)
        }
    }

    private fun getBatteryLevel(result: MethodChannel.Result) {
        // Battery info comes via broadcast, return 0 as default
        result.success(0)
    }

    // ==================== Broadcast Receiver ====================

    fun registerReceiver() {
        try {
            broadcastReceiver = object : BroadcastReceiver() {
                override fun onReceive(context: Context, intent: Intent) {
                    when (intent.action) {
                        ParamCts.BROADCAST_ON_LOST_CONNECT -> {
                            Log.w(TAG, "RFID connection lost")
                            isConnected = false
                            isReading = false
                            sendConnectionEvent(false)
                        }
                        ParamCts.BROADCAST_UN_FOUND_READER -> {
                            Log.w(TAG, "RFID reader not found")
                            isConnected = false
                            sendConnectionEvent(false)
                        }
                        ParamCts.BROADCAST_BATTER_LOW_ELEC -> {
                            Log.d(TAG, "RFID battery low")
                            sendBatteryEvent(mapOf(
                                "level" to 10,
                                "charging" to false
                            ))
                        }
                    }
                }
            }

            val filter = IntentFilter().apply {
                addAction(ParamCts.BROADCAST_ON_LOST_CONNECT)
                addAction(ParamCts.BROADCAST_UN_FOUND_READER)
                addAction(ParamCts.BROADCAST_BATTER_LOW_ELEC)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.registerReceiver(broadcastReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                context.registerReceiver(broadcastReceiver, filter)
            }
            Log.d(TAG, "RFID broadcast receiver registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register receiver", e)
        }
    }

    fun unregisterReceiver() {
        try {
            broadcastReceiver?.let {
                context.unregisterReceiver(it)
                broadcastReceiver = null
            }
            Log.d(TAG, "RFID broadcast receiver unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unregister receiver", e)
        }
    }

    // ==================== EventChannel ====================

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        when (arguments as? String) {
            "tag_stream" -> tagEventSink = events
            "connection_stream" -> connectionEventSink = events
            "battery_stream" -> batteryEventSink = events
        }
    }

    override fun onCancel(arguments: Any?) {
        when (arguments as? String) {
            "tag_stream" -> tagEventSink = null
            "connection_stream" -> connectionEventSink = null
            "battery_stream" -> batteryEventSink = null
        }
    }

    // ==================== Helpers ====================

    private fun checkConnected(result: MethodChannel.Result): Boolean {
        if (!isConnected) {
            result.error("NOT_CONNECTED", "RFID device not connected", null)
            return false
        }
        return true
    }

    private fun sendTagEvent(data: Map<String, Any>) {
        mainHandler.post { tagEventSink?.success(data) }
    }

    private fun sendConnectionEvent(connected: Boolean) {
        mainHandler.post {
            connectionEventSink?.success(mapOf(
                "connected" to connected,
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }

    private fun sendBatteryEvent(data: Map<String, Any>) {
        mainHandler.post { batteryEventSink?.success(data) }
    }

    private fun hexStringToByteArray(hex: String): ByteArray {
        if (hex.isEmpty()) return ByteArray(0)
        val cleanHex = hex.replace(" ", "").replace("0x", "").replace("0X", "")
        if (cleanHex.length % 2 != 0) return ByteArray(0)
        return ByteArray(cleanHex.length / 2) { i ->
            cleanHex.substring(i * 2, i * 2 + 2).toInt(16).toByte()
        }
    }

    fun dispose() {
        try {
            if (isReading) {
                rfidManager?.helper?.tagInventoryRawStopReading()
                isReading = false
            }
            rfidManager?.helper?.unregisterReaderCall()
            rfidManager?.disconnect()
            isConnected = false
            unregisterReceiver()
            tagEventSink = null
            connectionEventSink = null
            batteryEventSink = null
            Log.d(TAG, "RfidHandler disposed")
        } catch (e: Exception) {
            Log.e(TAG, "Dispose failed", e)
        }
    }
}
