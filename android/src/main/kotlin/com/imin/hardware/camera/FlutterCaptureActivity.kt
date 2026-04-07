package com.imin.hardware.camera

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.imin.scan.CaptureActivity
import com.imin.scan.DecodeConfig
import com.imin.scan.DecodeFormatManager
import com.imin.scan.Result
import com.imin.scan.analyze.MultiFormatAnalyzer
import com.imin.zxing.BarcodeFormat

/**
 * Custom CaptureActivity for Flutter integration
 * Handles scan results and returns them to Flutter via Intent
 */
class FlutterCaptureActivity : CaptureActivity() {

    companion object {
        const val SCAN_RESULT = "SCAN_RESULT"
        const val SCAN_FORMAT = "SCAN_FORMAT"
    }

    private var useFlash = false
    private var beepEnabled = true
    private var formats: List<String>? = null
    private var timeout: Int = 0
    private var timeoutRunnable: Runnable? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        // Read parameters before super.onCreate (which calls initUI -> initCameraScan)
        useFlash = intent.getBooleanExtra("useFlash", false)
        beepEnabled = intent.getBooleanExtra("beepEnabled", true)
        formats = intent.getStringArrayListExtra("formats")
        timeout = intent.getIntExtra("timeout", 0)
        super.onCreate(savedInstanceState)

        // Set up timeout if specified (timeout > 0 means auto-cancel after N milliseconds)
        if (timeout > 0) {
            timeoutRunnable = Runnable {
                // Timeout reached, cancel scan
                setResult(Activity.RESULT_CANCELED)
                finish()
            }
            window.decorView.postDelayed(timeoutRunnable!!, timeout.toLong())
        }
    }

    override fun onDestroy() {
        // Cancel timeout if activity is finishing before timeout
        timeoutRunnable?.let { window.decorView.removeCallbacks(it) }
        timeoutRunnable = null
        super.onDestroy()
    }

    override fun initCameraScan() {
        super.initCameraScan()
        
        // Build decode hints based on requested formats
        val hints = if (formats != null && formats!!.isNotEmpty()) {
            val barcodeFormats = formats!!.mapNotNull { name ->
                try {
                    BarcodeFormat.valueOf(name)
                } catch (e: IllegalArgumentException) {
                    null
                }
            }.toTypedArray()
            if (barcodeFormats.isNotEmpty()) {
                DecodeFormatManager.createDecodeHints(*barcodeFormats)
            } else {
                DecodeFormatManager.DEFAULT_HINTS
            }
        } else {
            DecodeFormatManager.DEFAULT_HINTS
        }

        // Initialize decode configuration
        val decodeConfig = DecodeConfig().apply {
            setHints(hints)
            isSupportVerticalCode = false
            isSupportLuminanceInvert = false
            areaRectRatio = 0.8f
            isFullAreaScan = false
        }

        // Configure camera scan
        cameraScan.apply {
            setPlayBeep(beepEnabled)
            setVibrate(false)
            setNeedAutoZoom(true)
            setNeedTouchZoom(true)
            setOnScanResultCallback(this@FlutterCaptureActivity)
            setAnalyzer(MultiFormatAnalyzer(decodeConfig))
            setAnalyzeImage(true)
        }

        // Bind flashlight view so it can be shown/hidden by ambient light sensor
        // and make it always visible for user to toggle manually
        if (ivFlashlight != null) {
            cameraScan.bindFlashlightView(ivFlashlight)
            // Make flashlight button always visible so user can toggle it
            ivFlashlight.visibility = android.view.View.VISIBLE
        }

        // If useFlash is requested, enable torch after camera is ready
        if (useFlash) {
            // Poll until camera is available, then enable torch
            val handler = android.os.Handler(android.os.Looper.getMainLooper())
            var attempts = 0
            val maxAttempts = 20 // 20 * 100ms = 2 seconds max wait
            val checkCamera = object : Runnable {
                override fun run() {
                    attempts++
                    if (cameraScan.camera != null && cameraScan.hasFlashUnit()) {
                        cameraScan.enableTorch(true)
                        ivFlashlight?.isSelected = true
                    } else if (attempts < maxAttempts) {
                        handler.postDelayed(this, 100)
                    }
                }
            }
            handler.postDelayed(checkCamera, 200)
        }
    }

    private var hasResult = false

    override fun onScanResultCallback(result: Result?): Boolean {
        if (result != null && !hasResult) {
            hasResult = true

            // Stop image analysis immediately to prevent duplicate results.
            cameraScan.setAnalyzeImage(false)

            // Return result to Flutter
            val intent = Intent().apply {
                putExtra(SCAN_RESULT, result.text)
                putExtra(SCAN_FORMAT, result.barcodeFormat.name)
            }
            setResult(Activity.RESULT_OK, intent)
            finish()
            return true
        }
        return false
    }
}
