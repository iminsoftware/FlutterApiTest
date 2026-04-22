package com.imin.hardware.camera

import android.app.Activity
import android.content.Intent
import com.imin.scan.ScanUtils
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * Camera Scan Handler
 * Handles camera-based barcode/QR code scanning using scanlibrary
 * Supports single scan (FlutterCaptureActivity) and multi scan (FlutterMultiCaptureActivity)
 */
class CameraScanHandler(
    private val activity: Activity
) : PluginRegistry.ActivityResultListener {

    companion object {
        private const val REQUEST_CODE_SCAN = 0x1001
        private const val REQUEST_CODE_SCAN_MULTI = 0x1002
    }

    private var pendingResult: MethodChannel.Result? = null
    private var isMultiMode = false

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        val method = call.method.removePrefix("cameraScan.")
        when (method) {
            "scan" -> startScan(call, result)
            "scanMulti" -> startScanMulti(call, result)
            "isMLKitAvailable" -> isMLKitAvailable(result)
            else -> result.notImplemented()
        }
    }

    // ==================== 单码扫描（原有逻辑） ====================

    private fun startScan(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "Camera scan is already active", null)
            return
        }
        try {
            pendingResult = result
            isMultiMode = false
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

    // ==================== 多码/多角度扫描（新增） ====================

    private fun startScanMulti(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "Camera scan is already active", null)
            return
        }
        try {
            pendingResult = result
            isMultiMode = true
            val intent = Intent(activity, FlutterMultiCaptureActivity::class.java).apply {
                // 基础参数
                putExtra(FlutterMultiCaptureActivity.EXTRA_USE_FLASH, call.argument<Boolean>("useFlash") ?: false)
                putExtra(FlutterMultiCaptureActivity.EXTRA_BEEP_ENABLED, call.argument<Boolean>("beepEnabled") ?: true)
                putExtra(FlutterMultiCaptureActivity.EXTRA_TIMEOUT, call.argument<Int>("timeout") ?: 0)

                // 格式
                val formats = call.argument<List<String>>("formats")
                if (formats != null && formats.isNotEmpty()) {
                    putExtra(FlutterMultiCaptureActivity.EXTRA_FORMATS, formats.toTypedArray())
                }

                // 多码/多角度参数
                putExtra(FlutterMultiCaptureActivity.EXTRA_SUPPORT_MULTI_BARCODE,
                    call.argument<Boolean>("supportMultiBarcode") ?: true)
                putExtra(FlutterMultiCaptureActivity.EXTRA_SUPPORT_MULTI_ANGLE,
                    call.argument<Boolean>("supportMultiAngle") ?: true)
                putExtra(FlutterMultiCaptureActivity.EXTRA_DECODE_ENGINE,
                    call.argument<Int>("decodeEngine") ?: ScanUtils.ENGINE_MLKIT)
                putExtra(FlutterMultiCaptureActivity.EXTRA_FULL_AREA_SCAN,
                    call.argument<Boolean>("fullAreaScan") ?: true)
                putExtra(FlutterMultiCaptureActivity.EXTRA_AREA_RECT_RATIO,
                    (call.argument<Double>("areaRectRatio") ?: 0.8).toFloat())
            }
            activity.startActivityForResult(intent, REQUEST_CODE_SCAN_MULTI)
        } catch (e: Exception) {
            pendingResult = null
            isMultiMode = false
            result.error("ERROR", "Failed to start multi camera scan: ${e.message}", null)
        }
    }

    // ==================== ML Kit 可用性检测 ====================

    private fun isMLKitAvailable(result: MethodChannel.Result) {
        result.success(ScanUtils.isMLKitAvailable())
    }

    // ==================== Activity 结果回调 ====================

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_SCAN) {
            handleSingleScanResult(resultCode, data)
            return true
        } else if (requestCode == REQUEST_CODE_SCAN_MULTI) {
            handleMultiScanResult(resultCode, data)
            return true
        }
        return false
    }

    private fun handleSingleScanResult(resultCode: Int, data: Intent?) {
        val result = pendingResult
        pendingResult = null
        isMultiMode = false
        if (result == null) return

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
            Activity.RESULT_CANCELED -> result.error("CANCELED", "Scan was canceled", null)
            else -> result.error("ERROR", "Unknown result code: $resultCode", null)
        }
    }

    private fun handleMultiScanResult(resultCode: Int, data: Intent?) {
        val result = pendingResult
        pendingResult = null
        isMultiMode = false
        if (result == null) return

        when (resultCode) {
            Activity.RESULT_OK -> {
                val results = data?.getStringArrayExtra(FlutterMultiCaptureActivity.SCAN_RESULTS)
                val formats = data?.getStringArrayExtra(FlutterMultiCaptureActivity.SCAN_FORMATS)

                if (results != null && results.isNotEmpty()) {
                    val list = results.mapIndexed { index, code ->
                        mapOf(
                            "code" to code,
                            "format" to (formats?.getOrNull(index) ?: "UNKNOWN")
                        )
                    }
                    result.success(list)
                } else {
                    // fallback: 尝试读取单条码结果
                    val scanResult = data?.getStringExtra(FlutterMultiCaptureActivity.SCAN_RESULT)
                    val scanFormat = data?.getStringExtra(FlutterMultiCaptureActivity.SCAN_FORMAT)
                    if (scanResult != null) {
                        result.success(listOf(mapOf(
                            "code" to scanResult,
                            "format" to (scanFormat ?: "UNKNOWN")
                        )))
                    } else {
                        result.error("NO_DATA", "No scan result returned", null)
                    }
                }
            }
            Activity.RESULT_CANCELED -> result.error("CANCELED", "Scan was canceled", null)
            else -> result.error("ERROR", "Unknown result code: $resultCode", null)
        }
    }

    fun cleanup() {
        pendingResult?.error("CANCELED", "Handler cleanup", null)
        pendingResult = null
    }
}
