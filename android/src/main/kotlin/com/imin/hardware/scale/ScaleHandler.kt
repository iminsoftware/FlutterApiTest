package com.imin.hardware.scale

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import com.neostra.electronic.Electronic
import com.neostra.electronic.ElectronicCallback
import com.neostra.serialport.SerialPort
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

class ScaleHandler(private val activity: Activity) : ElectronicCallback {
    private val TAG = "ScaleHandler"
    private var electronic: Electronic? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    
    private val SCALE_UNSTABLE = "55"
    private val SCALE_STABLE = "53"
    private val SCALE_OVER_WEIGHT = "46"

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "scale.connect" -> {
                val devicePath = call.argument<String>("devicePath")
                connect(devicePath, result)
            }
            "scale.disconnect" -> disconnect(result)
            "scale.tare" -> tare(result)
            "scale.zero" -> zero(result)
            else -> result.notImplemented()
        }
    }

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    private fun connect(devicePath: String?, result: Result) {
        // 在后台线程执行连接操作
        Thread {
            try {
                // 先断开已有连接
                electronic?.closeElectronic()
                electronic = null
                
                var devPath = devicePath ?: "/dev/ttyS4"
                
                Log.d(TAG, "Connecting to scale: $devPath")
                
                // 如果是 USB 设备，需要测试哪个端口可用
                if (devPath.contains("ttyUSB")) {
                    var initOk = false
                    for (i in 0..9) {
                        val usbTty = "$devPath$i"
                        Log.d(TAG, "Testing USB port: $usbTty")
                        try {
                            val serialPort = SerialPort(File(usbTty), 9600, 0)
                            initOk = true
                            Log.d(TAG, "USB port available: $usbTty")
                            SystemClock.sleep(50)
                            serialPort.close()
                            SystemClock.sleep(50)
                            devPath = usbTty
                            break
                        } catch (e: Exception) {
                            Log.d(TAG, "USB port $usbTty not available: ${e.message}")
                        }
                    }
                    if (!initOk) {
                        mainHandler.post {
                            result.error("USB_NOT_FOUND", "No available USB serial port found", null)
                        }
                        return@Thread
                    }
                }
                
                // 延迟一下再初始化
                SystemClock.sleep(200)
                
                electronic = Electronic.Builder()
                    .setDevicePath(devPath)
                    .setReceiveCallback(this)
                    .builder()
                
                Log.d(TAG, "Scale connected: $devPath")
                mainHandler.post {
                    result.success(true)
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to connect scale", e)
                electronic = null
                mainHandler.post {
                    result.error("CONNECT_FAILED", e.message, null)
                }
            }
        }.start()
    }

    private fun disconnect(result: Result) {
        try {
            electronic?.closeElectronic()
            electronic = null
            Log.d(TAG, "Scale disconnected")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to disconnect scale", e)
            result.error("DISCONNECT_FAILED", e.message, null)
        }
    }

    private fun tare(result: Result) {
        try {
            electronic?.removePeel()
            Log.d(TAG, "Tare executed")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to tare", e)
            result.error("TARE_FAILED", e.message, null)
        }
    }

    private fun zero(result: Result) {
        try {
            electronic?.turnZero()
            Log.d(TAG, "Zero executed")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to zero", e)
            result.error("ZERO_FAILED", e.message, null)
        }
    }

    override fun electronicStatus(weight: String?, weightStatus: String?) {
        if (weight == null || weightStatus == null) return
        
        val status = when (weightStatus) {
            SCALE_STABLE -> "stable"
            SCALE_UNSTABLE -> "unstable"
            SCALE_OVER_WEIGHT -> "overweight"
            else -> "unknown"
        }
        
        val data = mapOf(
            "weight" to weight,
            "status" to status
        )
        
        mainHandler.post {
            eventSink?.success(data)
        }
    }

    fun cleanup() {
        electronic?.closeElectronic()
        electronic = null
        eventSink = null
    }
}
