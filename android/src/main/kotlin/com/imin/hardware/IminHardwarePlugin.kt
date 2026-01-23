package com.imin.hardware

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import com.imin.hardware.display.DisplayHandler
import com.imin.hardware.cashbox.CashBoxHandler
import com.imin.hardware.light.LightHandler
import com.imin.hardware.nfc.NfcHandler
import com.imin.hardware.scanner.ScannerHandler
import com.imin.hardware.msr.MsrHandler
import com.imin.hardware.scale.ScaleHandler
import com.imin.hardware.serial.SerialHandler
import com.imin.hardware.rfid.RfidHandler
import com.imin.hardware.segment.SegmentHandler
import com.imin.hardware.floatingwindow.FloatingWindowHandler

/** IminHardwarePlugin */
class IminHardwarePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var nfcEventChannel: EventChannel
  private lateinit var scannerEventChannel: EventChannel
  private lateinit var msrEventChannel: EventChannel
  private lateinit var scaleEventChannel: EventChannel
  private lateinit var serialEventChannel: EventChannel
  private var activity: Activity? = null
  private var activityBinding: ActivityPluginBinding? = null
  
  // Handlers for different hardware features
  private var displayHandler: DisplayHandler? = null
  private var cashBoxHandler: CashBoxHandler? = null
  private var lightHandler: LightHandler? = null
  private var nfcHandler: NfcHandler? = null
  private var scannerHandler: ScannerHandler? = null
  private var msrHandler: MsrHandler? = null
  private var scaleHandler: ScaleHandler? = null
  private var serialHandler: SerialHandler? = null
  private var rfidHandler: RfidHandler? = null
  private var segmentHandler: SegmentHandler? = null
  private var floatingWindowHandler: FloatingWindowHandler? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware")
    channel.setMethodCallHandler(this)
    
    // Create EventChannels
    nfcEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware/nfc")
    scannerEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware/scanner")
    msrEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware/msr")
    scaleEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware/scale")
    serialEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "com.imin.hardware/serial")
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (activity == null) {
      result.error("NO_ACTIVITY", "Activity not available", null)
      return
    }

    when {
      call.method.startsWith("display.") -> displayHandler?.handle(call, result)
      call.method.startsWith("cashbox.") -> cashBoxHandler?.handle(call, result)
      call.method.startsWith("light.") -> lightHandler?.handle(call, result)
      call.method.startsWith("nfc.") -> nfcHandler?.handle(call, result)
      call.method.startsWith("scanner.") -> scannerHandler?.handle(call, result)
      call.method.startsWith("msr.") -> msrHandler?.handle(call, result)
      call.method.startsWith("scale.") -> scaleHandler?.handle(call, result)
      call.method.startsWith("serial.") -> serialHandler?.handle(call, result)
      call.method.startsWith("rfid.") -> rfidHandler?.handle(call, result)
      call.method.startsWith("segment.") -> segmentHandler?.handle(call, result)
      call.method.startsWith("floatingWindow.") -> floatingWindowHandler?.handle(call, result)
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    initializeHandlers(binding)
    
    // Register onNewIntent listener for NFC
    binding.addOnNewIntentListener { intent ->
      nfcHandler?.handleNewIntent(intent)
      false  // Return false to allow other listeners to handle the intent
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    cleanupHandlers()
    activityBinding = null
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    initializeHandlers(binding)
    
    // Re-register onNewIntent listener
    binding.addOnNewIntentListener { intent ->
      nfcHandler?.handleNewIntent(intent)
      false
    }
  }

  override fun onDetachedFromActivity() {
    cleanupHandlers()
    activityBinding = null
    activity = null
  }

  private fun initializeHandlers(binding: ActivityPluginBinding) {
    val activity = binding.activity
    displayHandler = DisplayHandler(activity)
    cashBoxHandler = CashBoxHandler(activity)
    lightHandler = LightHandler(activity)
    nfcHandler = NfcHandler(activity, nfcEventChannel)
    scannerHandler = ScannerHandler(activity.applicationContext, scannerEventChannel)
    msrHandler = MsrHandler(activity.applicationContext, msrEventChannel)
    serialHandler = SerialHandler(activity.applicationContext, serialEventChannel)
    scaleHandler = ScaleHandler(activity)
    scaleEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
      override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        scaleHandler?.setEventSink(events)
      }
      override fun onCancel(arguments: Any?) {
        scaleHandler?.setEventSink(null)
      }
    })
    rfidHandler = RfidHandler(activity)
    segmentHandler = SegmentHandler(activity)
    floatingWindowHandler = FloatingWindowHandler(activity)
  }

  private fun cleanupHandlers() {
    displayHandler?.cleanup()
    cashBoxHandler?.cleanup()
    lightHandler?.cleanup()
    nfcHandler?.cleanup()
    scannerHandler?.cleanup()
    msrHandler?.cleanup()
    scaleHandler?.cleanup()
    serialHandler?.cleanup()
    rfidHandler?.cleanup()
    segmentHandler?.cleanup()
    floatingWindowHandler?.cleanup()
    
    displayHandler = null
    cashBoxHandler = null
    lightHandler = null
    nfcHandler = null
    scannerHandler = null
    msrHandler = null
    scaleHandler = null
    serialHandler = null
    rfidHandler = null
    segmentHandler = null
    floatingWindowHandler = null
  }
}
