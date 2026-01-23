package com.imin.hardware.rfid

import android.app.Activity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class RfidHandler(private val activity: Activity) {
    fun handle(call: MethodCall, result: Result) {
        result.error("NOT_IMPLEMENTED", "RFID feature not implemented yet", null)
    }
    fun cleanup() {}
}
