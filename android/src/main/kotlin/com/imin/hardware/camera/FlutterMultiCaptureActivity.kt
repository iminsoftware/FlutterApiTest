package com.imin.hardware.camera

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.imin.scan.CaptureActivity
import com.imin.scan.DecodeConfig
import com.imin.scan.DecodeFormatManager
import com.imin.scan.Result
import com.imin.scan.ScanUtils
import com.imin.scan.analyze.MultiFormatAnalyzer
import com.imin.zxing.BarcodeFormat
import com.imin.zxing.DecodeHintType
import java.util.EnumMap

/**
 * 多条码/多角度扫码 Activity
 *
 * 走 ML Kit + ScanUtils 链路，支持：
 * - 多条码同时识别
 * - 多角度识别（ML Kit 原生支持任意角度）
 * - 自动降级到 ZXing
 */
class FlutterMultiCaptureActivity : CaptureActivity() {

    companion object {
        private const val TAG = "FlutterMultiCapture"

        const val SCAN_RESULT = "SCAN_RESULT"
        const val SCAN_FORMAT = "SCAN_FORMAT"
        const val SCAN_RESULTS = "SCAN_RESULTS"
        const val SCAN_FORMATS = "SCAN_FORMATS"
        const val SCAN_COUNT = "SCAN_COUNT"

        const val EXTRA_FORMATS = "formats"
        const val EXTRA_USE_FLASH = "useFlash"
        const val EXTRA_BEEP_ENABLED = "beepEnabled"
        const val EXTRA_TIMEOUT = "timeout"
        const val EXTRA_SUPPORT_MULTI_BARCODE = "supportMultiBarcode"
        const val EXTRA_SUPPORT_MULTI_ANGLE = "supportMultiAngle"
        const val EXTRA_DECODE_ENGINE = "decodeEngine"
        const val EXTRA_FULL_AREA_SCAN = "fullAreaScan"
        const val EXTRA_AREA_RECT_RATIO = "areaRectRatio"
    }

    private var timeoutHandler: Handler? = null
    private var timeoutRunnable: Runnable? = null
    private var hasResult = false
    private var supportMultiBarcode = false

    override fun initCameraScan() {
        super.initCameraScan()

        val intent = getIntent()

        // 解析格式参数
        val formats = intent.getStringArrayExtra(EXTRA_FORMATS)
        val hints: Map<DecodeHintType, Any> = if (formats != null && formats.isNotEmpty()) {
            val barcodeFormats = formats.mapNotNull { fmt ->
                try { BarcodeFormat.valueOf(fmt) } catch (e: IllegalArgumentException) { null }
            }
            if (barcodeFormats.isNotEmpty()) {
                EnumMap<DecodeHintType, Any>(DecodeHintType::class.java).apply {
                    put(DecodeHintType.POSSIBLE_FORMATS, barcodeFormats)
                    put(DecodeHintType.TRY_HARDER, true)
                    put(DecodeHintType.CHARACTER_SET, "UTF-8")
                }
            } else {
                DecodeFormatManager.ALL_HINTS
            }
        } else {
            DecodeFormatManager.ALL_HINTS
        }

        // 解析参数
        val beepEnabled = intent.getBooleanExtra(EXTRA_BEEP_ENABLED, true)
        val useFlash = intent.getBooleanExtra(EXTRA_USE_FLASH, false)
        val timeout = intent.getIntExtra(EXTRA_TIMEOUT, 0)
        supportMultiBarcode = intent.getBooleanExtra(EXTRA_SUPPORT_MULTI_BARCODE, false)
        val supportMultiAngle = intent.getBooleanExtra(EXTRA_SUPPORT_MULTI_ANGLE, true)
        val decodeEngine = intent.getIntExtra(EXTRA_DECODE_ENGINE, ScanUtils.ENGINE_MLKIT)
        val fullAreaScan = intent.getBooleanExtra(EXTRA_FULL_AREA_SCAN, true)
        val areaRectRatio = intent.getFloatExtra(EXTRA_AREA_RECT_RATIO, 0.8f)

        // 配置解码
        val decodeConfig = DecodeConfig().apply {
            setHints(hints)
            isSupportVerticalCode = supportMultiAngle
            isSupportLuminanceInvert = false
            setAreaRectRatio(areaRectRatio)
            isFullAreaScan = fullAreaScan
        }

        // 配置相机扫描
        cameraScan.apply {
            setPlayBeep(beepEnabled)
            setVibrate(false)
            setNeedAutoZoom(true)
            setNeedTouchZoom(true)
            setOnScanResultCallback(this@FlutterMultiCaptureActivity)
            setAnalyzer(MultiFormatAnalyzer(decodeConfig))
            setAnalyzeImage(true)
        }

        // 闪光灯按钮
        if (ivFlashlight != null) {
            cameraScan.bindFlashlightView(ivFlashlight)
            ivFlashlight.visibility = android.view.View.VISIBLE
        }

        if (useFlash) {
            cameraScan.enableTorch(true)
        }

        // 超时处理
        if (timeout > 0) {
            timeoutHandler = Handler(Looper.getMainLooper())
            timeoutRunnable = Runnable {
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
            timeoutHandler?.postDelayed(timeoutRunnable!!, timeout.toLong())
        }

        Log.i(TAG, "initCameraScan: engine=$decodeEngine multiBarcode=$supportMultiBarcode multiAngle=$supportMultiAngle fullArea=$fullAreaScan")
    }

    override fun onScanResultCallback(result: Result?): Boolean {
        if (result != null && !hasResult) {
            hasResult = true
            cameraScan.setAnalyzeImage(false)
            cancelTimeout()

            val data = Intent()
            if (supportMultiBarcode) {
                // 多条码模式：CameraX + ZXing 链路一次只返回一个结果
                // 包装成数组格式返回，保持接口一致性
                data.putExtra(SCAN_RESULTS, arrayOf(result.text))
                data.putExtra(SCAN_FORMATS, arrayOf(result.barcodeFormat.name))
                data.putExtra(SCAN_COUNT, 1)
            } else {
                data.putExtra(SCAN_RESULT, result.text)
                data.putExtra(SCAN_FORMAT, result.barcodeFormat.name)
            }
            setResult(Activity.RESULT_OK, data)
            finish()
            return true
        }
        return false
    }

    private fun cancelTimeout() {
        timeoutRunnable?.let { timeoutHandler?.removeCallbacks(it) }
        timeoutRunnable = null
    }

    override fun onDestroy() {
        cancelTimeout()
        super.onDestroy()
    }
}
