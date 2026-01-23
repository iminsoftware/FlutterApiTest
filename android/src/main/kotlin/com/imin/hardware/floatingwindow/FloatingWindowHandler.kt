package com.imin.hardware.floatingwindow

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FloatingWindowHandler(private val activity: Activity) {
    
    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "floatingWindow.show" -> show(result)
            "floatingWindow.hide" -> hide(result)
            "floatingWindow.isShowing" -> isShowing(result)
            "floatingWindow.updateText" -> updateText(call, result)
            "floatingWindow.setPosition" -> setPosition(call, result)
            else -> result.notImplemented()
        }
    }

    private fun show(result: MethodChannel.Result) {
        try {
            // Check for overlay permission on Android M and above
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (!Settings.canDrawOverlays(activity)) {
                    result.error(
                        "PERMISSION_DENIED",
                        "Overlay permission not granted. Please enable it in settings.",
                        null
                    )
                    return
                }
            }

            val intent = Intent(activity, FloatingWindowService::class.java)
            intent.action = FloatingWindowService.ACTION_SHOW
            activity.startService(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to show floating window: ${e.message}", null)
        }
    }

    private fun hide(result: MethodChannel.Result) {
        try {
            val intent = Intent(activity, FloatingWindowService::class.java)
            intent.action = FloatingWindowService.ACTION_HIDE
            activity.startService(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to hide floating window: ${e.message}", null)
        }
    }

    private fun isShowing(result: MethodChannel.Result) {
        try {
            result.success(FloatingWindowService.isShowing)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to check floating window status: ${e.message}", null)
        }
    }

    private fun updateText(call: MethodCall, result: MethodChannel.Result) {
        try {
            val text = call.argument<String>("text")
            if (text == null) {
                result.error("INVALID_ARGUMENT", "Text parameter is required", null)
                return
            }

            val intent = Intent(activity, FloatingWindowService::class.java)
            intent.action = FloatingWindowService.ACTION_UPDATE_TEXT
            intent.putExtra("text", text)
            activity.startService(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to update text: ${e.message}", null)
        }
    }

    private fun setPosition(call: MethodCall, result: MethodChannel.Result) {
        try {
            val x = call.argument<Int>("x")
            val y = call.argument<Int>("y")
            
            if (x == null || y == null) {
                result.error("INVALID_ARGUMENT", "x and y parameters are required", null)
                return
            }

            val intent = Intent(activity, FloatingWindowService::class.java)
            intent.action = FloatingWindowService.ACTION_SET_POSITION
            intent.putExtra("x", x)
            intent.putExtra("y", y)
            activity.startService(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("ERROR", "Failed to set position: ${e.message}", null)
        }
    }

    fun cleanup() {
        // Cleanup if needed
    }
}
