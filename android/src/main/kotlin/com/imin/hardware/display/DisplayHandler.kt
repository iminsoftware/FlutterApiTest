package com.imin.hardware.display

import android.app.Activity
import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Build
import android.util.Log
import android.view.Display
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

class DisplayHandler(private val activity: Activity) {
    companion object {
        private const val TAG = "DisplayHandler"
    }

    private var presentation: DifferentDisplay? = null

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "display.isAvailable" -> checkAvailable(result)
            "display.enable" -> enableDisplay(result)
            "display.disable" -> disableDisplay(result)
            "display.showText" -> showText(call, result)
            "display.showImage" -> showImage(call, result)
            "display.playVideo" -> playVideo(call, result)
            "display.clear" -> clearDisplay(result)
            else -> result.notImplemented()
        }
    }

    private fun checkAvailable(result: Result) {
        try {
            val display = getPresentationDisplay()
            result.success(display != null)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking display availability", e)
            result.success(false)
        }
    }

    private fun enableDisplay(result: Result) {
        try {
            if (presentation != null) {
                result.success(true)
                return
            }

            val display = getPresentationDisplay()
            if (display == null) {
                result.error("NO_DISPLAY", "Secondary display not found", null)
                return
            }

            presentation = DifferentDisplay(activity, display)
            presentation?.show()
            
            Log.d(TAG, "Secondary display enabled")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error enabling display", e)
            result.error("ENABLE_FAILED", e.message, null)
        }
    }

    private fun disableDisplay(result: Result) {
        try {
            presentation?.cancel()
            presentation = null
            Log.d(TAG, "Secondary display disabled")
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error disabling display", e)
            result.error("DISABLE_FAILED", e.message, null)
        }
    }

    private fun showText(call: MethodCall, result: Result) {
        try {
            if (presentation == null) {
                result.error("NO_DISPLAY", "Display not enabled", null)
                return
            }

            val text = call.argument<String>("text")
            if (text == null) {
                result.error("INVALID_ARGUMENT", "Text is required", null)
                return
            }

            presentation?.showText(text)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing text", e)
            result.error("SHOW_TEXT_FAILED", e.message, null)
        }
    }

    private fun showImage(call: MethodCall, result: Result) {
        try {
            if (presentation == null) {
                result.error("NO_DISPLAY", "Display not enabled", null)
                return
            }

            val assetPath = call.argument<String>("path")
            if (assetPath == null) {
                result.error("INVALID_ARGUMENT", "Image path is required", null)
                return
            }

            Log.d(TAG, "Received asset path from Flutter: $assetPath")
            
            // 直接使用 Flutter asset 路径，格式: flutter_assets/assets/images/xxx.png
            val flutterAssetPath = "flutter_assets/$assetPath"
            
            Log.d(TAG, "Converted to Android asset path: $flutterAssetPath")
            
            presentation?.showImage(activity, flutterAssetPath)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error showing image", e)
            result.error("SHOW_IMAGE_FAILED", e.message, null)
        }
    }

    private fun playVideo(call: MethodCall, result: Result) {
        try {
            if (presentation == null) {
                result.error("NO_DISPLAY", "Display not enabled", null)
                return
            }

            val assetPath = call.argument<String>("path")
            if (assetPath == null) {
                result.error("INVALID_ARGUMENT", "Video path is required", null)
                return
            }

            Log.d(TAG, "Received video path from Flutter: $assetPath")
            
            // 直接使用 Flutter asset 路径，格式: flutter_assets/assets/videos/xxx.mp4
            val flutterAssetPath = "flutter_assets/$assetPath"
            
            Log.d(TAG, "Converted to Android asset path: $flutterAssetPath")

            presentation?.playVideo(activity, flutterAssetPath)
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error playing video", e)
            result.error("PLAY_VIDEO_FAILED", e.message, null)
        }
    }

    private fun clearDisplay(result: Result) {
        try {
            if (presentation == null) {
                result.error("NO_DISPLAY", "Display not enabled", null)
                return
            }

            presentation?.clear()
            result.success(null)
        } catch (e: Exception) {
            Log.e(TAG, "Error clearing display", e)
            result.error("CLEAR_FAILED", e.message, null)
        }
    }

    private fun getPresentationDisplay(): Display? {
        val displayManager = activity.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
        val displays = displayManager.getDisplays(DisplayManager.DISPLAY_CATEGORY_PRESENTATION)
        
        displays?.forEach { display ->
            Log.d(TAG, "Found display: $display, Flags: ${display.flags}")
            
            if ((display.flags and Display.FLAG_SECURE) != 0 &&
                (display.flags and Display.FLAG_PRESENTATION) != 0) {
                Log.d(TAG, "Selected presentation display: $display")
                return display
            }
        }
        
        return null
    }

    fun cleanup() {
        try {
            presentation?.cancel()
            presentation = null
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}
