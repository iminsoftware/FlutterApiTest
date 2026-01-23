package com.imin.hardware.msr

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel.Result

/**
 * MSR (Magnetic Stripe Reader) Handler for iMin devices
 * 
 * Based on IMinApiTest MsrActivity implementation
 * 
 * Note: MSR devices typically work as keyboard input devices.
 * They automatically input card data when a card is swiped.
 * This handler provides utility methods for MSR functionality.
 */
class MsrHandler(
    private val context: Context,
    private val eventChannel: EventChannel
) : EventChannel.StreamHandler {
    
    companion object {
        private const val TAG = "MsrHandler"
    }

    private var eventSink: EventChannel.EventSink? = null

    init {
        // Set event stream handler
        eventChannel.setStreamHandler(this)
        Log.d(TAG, "MsrHandler initialized")
    }

    fun handle(call: MethodCall, result: Result) {
        when (call.method) {
            "msr.isAvailable" -> checkAvailability(result)
            else -> result.notImplemented()
        }
    }

    /**
     * Check if MSR device is available
     * 
     * Note: MSR devices work as keyboard input, so this method
     * returns true by default. Actual availability depends on
     * hardware connection.
     */
    private fun checkAvailability(result: Result) {
        try {
            // MSR devices typically work as keyboard input devices
            // No special API needed to check availability
            Log.d(TAG, "MSR availability check")
            result.success(true)
        } catch (e: Exception) {
            Log.e(TAG, "Error checking MSR availability", e)
            result.error("CHECK_FAILED", e.message, null)
        }
    }

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Log.d(TAG, "Event stream listener attached")
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        Log.d(TAG, "Event stream listener detached")
    }

    fun cleanup() {
        try {
            eventChannel.setStreamHandler(null)
            eventSink = null
            Log.d(TAG, "MsrHandler cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during cleanup", e)
        }
    }
}
