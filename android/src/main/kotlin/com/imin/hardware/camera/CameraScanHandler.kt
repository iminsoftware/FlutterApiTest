package com.imin.hardware.camera

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * Camera Scan Handler
 * Handles camera-based barcode/QR code scanning using scanlibrary
 */
class CameraScanHandler(
    private val activity: Activity
) : PluginRegistry.ActivityResultListener {

    companion object {
        private const val REQUEST_CODE_SCAN = 0x1001
    }

    private var pendingResult: MethodChannel.Result? = null

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        // 去掉 "cameraScan." 前缀
        val method = call.method.removePrefix("cameraScan.")
        
        when (method) {
            "scan" -> startScan(call, result)
            else -> result.notImplemented()
        }
    }

    private fun startScan(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "Camera scan is already active", null)
            return
        }

        try {
            pendingResult = result
            
            // Start FlutterCaptureActivity with parameters
            val intent = Intent(activity, FlutterCaptureActivity::class.java).apply {
                putExtra("useFlash", call.argument<Boolean>("useFlash") ?: false)
                putExtra("beepEnabled", call.argument<Boolean>("beepEnabled") ?: true)
                putExtra("timeout", call.argument<Int>("timeout") ?: 0)
                val formats = call.argument<List<String>>("formats")
                if (formats != null && formats.isNotEmpty()) {
                    putExtra("formats", ArrayList(formats))
                }
            }
            activity.startActivityForResult(intent, REQUEST_CODE_SCAN)
        } catch (e: Exception) {
            pendingResult = null
            result.error("ERROR", "Failed to start camera scan: ${e.message}", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_SCAN) {
            val result = pendingResult
            pendingResult = null

            if (result == null) {
                return true
            }

            when (resultCode) {
                Activity.RESULT_OK -> {
                    val scanResult = data?.getStringExtra(FlutterCaptureActivity.SCAN_RESULT)
                    val scanFormat = data?.getStringExtra(FlutterCaptureActivity.SCAN_FORMAT)
                    
                    if (scanResult != null) {
                        result.success(mapOf(
                            "code" to scanResult,
                            "format" to (scanFormat ?: "UNKNOWN"),
                            "rawBytes" to null
                        ))
                    } else {
                        result.error("NO_DATA", "No scan result returned", null)
                    }
                }
                Activity.RESULT_CANCELED -> {
                    result.error("CANCELED", "Scan was canceled", null)
                }
                else -> {
                    result.error("ERROR", "Unknown result code: $resultCode", null)
                }
            }
            return true
        }
        return false
    }

    fun cleanup() {
        pendingResult?.error("CANCELED", "Handler cleanup", null)
        pendingResult = null
    }
}
