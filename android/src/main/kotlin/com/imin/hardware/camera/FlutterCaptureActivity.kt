package com.imin.hardware.camera

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import com.imin.scan.CaptureActivity
import com.imin.scan.DecodeConfig
import com.imin.scan.DecodeFormatManager
import com.imin.scan.Result
import com.imin.scan.analyze.MultiFormatAnalyzer

/**
 * Custom CaptureActivity for Flutter integration
 * Handles scan results and returns them to Flutter via Intent
 */
class FlutterCaptureActivity : CaptureActivity() {

    companion object {
        const val SCAN_RESULT = "SCAN_RESULT"
        const val SCAN_FORMAT = "SCAN_FORMAT"
    }

    override fun initCameraScan() {
        super.initCameraScan()
        
        // Initialize decode configuration
        val decodeConfig = DecodeConfig().apply {
            hints = DecodeFormatManager.DEFAULT_HINTS
            isSupportVerticalCode = false
            isSupportLuminanceInvert = false
            areaRectRatio = 0.8f
            isFullAreaScan = false
        }

        // Configure camera scan
        cameraScan.apply {
            setPlayBeep(true)
            setVibrate(false)
            setNeedAutoZoom(true)
            setNeedTouchZoom(true)
            setOnScanResultCallback(this@FlutterCaptureActivity)
            setAnalyzer(MultiFormatAnalyzer(decodeConfig))
            setAnalyzeImage(true)
        }
    }

    override fun onScanResultCallback(result: Result?): Boolean {
        if (result != null) {
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
