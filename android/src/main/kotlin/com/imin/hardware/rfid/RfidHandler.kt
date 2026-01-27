package com.imin.hardware.rfid

import android.app.Activity
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * RFID 功能处理器 - 基础实现
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

    fun handle(call: MethodCall, methodResult: MethodChannel.Result) {
        onMethodCall(call, methodResult)
    }

    override fun onMethodCall(call: MethodCall, methodResult: MethodChannel.Result) {
        Log.d(TAG, "RFID method: ${call.method}")
        // 基础实现 - 返回未实现，等待真机测试时完善
        methodResult.notImplemented()
    }

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

    fun registerReceiver() {
        Log.d(TAG, "RFID receiver registered")
    }

    fun unregisterReceiver() {
        Log.d(TAG, "RFID receiver unregistered")
    }

    fun dispose() {
        tagEventSink = null
        connectionEventSink = null
        batteryEventSink = null
    }
}
