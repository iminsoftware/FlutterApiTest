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
import com.imin.hardware.scale.ScaleNewHandler
import com.imin.hardware.serial.SerialHandler
import com.imin.hardware.rfid.RfidHandler
import com.imin.hardware.segment.SegmentHandler
import com.imin.hardware.floatingwindow.FloatingWindowHandler
import com.imin.hardware.camera.CameraScanHandler
import com.imin.hardware.device.DeviceInfoHandler

/** IminHardwarePlugin */
class IminHardwarePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  private lateinit var channel: MethodChannel
  private lateinit var nfcEventChannel: EventChannel
  private lateinit var scannerEventChannel: EventChannel
  private lateinit var msrEventChannel: EventChannel
  private lateinit var scaleEventChannel: EventChannel
  private lateinit var scaleNewEventChannel: EventChannel
  private lateinit var serialEventChannel: EventChannel
  private lateinit var rfidTagEventChannel: EventChannel
  private lateinit var rfidConnectionEventChannel: EventChannel
  private lateinit var rfidBatteryEventChannel: EventChannel
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
  private var scaleNewHandler: ScaleNewHandler? = null
  private var serialHandler: SerialHandler? = null
  private var rfidHandler: RfidHandler? = null
  private var segmentHandler: SegmentHandler? = null
  private var floatingWindowHandler: FloatingWindowHandler? = null
  private var cameraScanHandler: CameraScanHandler? = null
  private var deviceInfoHandler: DeviceInfoHandler? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin")
    channel.setMethodCallHandler(this)
    
    // Create EventChannels
    nfcEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/nfc")
    scannerEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/scanner")
    msrEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/msr")
    scaleEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/scale")
    scaleNewEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/scale_new")
    serialEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/serial")
    rfidTagEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/rfid_tag")
    rfidConnectionEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/rfid_connection")
    rfidBatteryEventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "imin_hardware_plugin/rfid_battery")
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
      call.method.startsWith("scaleNew.") -> scaleNewHandler?.handle(call, result)
      call.method.startsWith("serial.") -> serialHandler?.handle(call, result)
      call.method.startsWith("rfid.") -> rfidHandler?.handle(call, result)
      call.method.startsWith("segment.") -> segmentHandler?.handle(call, result)
      call.method.startsWith("floatingWindow.") -> floatingWindowHandler?.handle(call, result)
      call.method.startsWith("cameraScan.") -> cameraScanHandler?.handle(call, result)
      call.method.startsWith("device.") -> deviceInfoHandler?.onMethodCall(call, result)
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
    
    // Initialize Scale New Handler (Android 13+)
    scaleNewHandler = ScaleNewHandler(activity.applicationContext, scaleNewEventChannel)
    scaleNewEventChannel.setStreamHandler(scaleNewHandler)
    
    // Initialize RFID Handler with EventChannels
    rfidHandler = RfidHandler(activity.applicationContext, activity)
    rfidTagEventChannel.setStreamHandler(rfidHandler)
    rfidConnectionEventChannel.setStreamHandler(rfidHandler)
    rfidBatteryEventChannel.setStreamHandler(rfidHandler)
    rfidHandler?.registerReceiver()
    
    segmentHandler = SegmentHandler(activity)
    floatingWindowHandler = FloatingWindowHandler(activity)
    cameraScanHandler = CameraScanHandler(activity)
    deviceInfoHandler = DeviceInfoHandler()
    
    // Register activity result listener for camera scan
    binding.addActivityResultListener(cameraScanHandler!!)
  }

  private fun cleanupHandlers() {
    displayHandler?.cleanup()
    cashBoxHandler?.cleanup()
    lightHandler?.cleanup()
    nfcHandler?.cleanup()
    scannerHandler?.cleanup()
    msrHandler?.cleanup()
    scaleHandler?.cleanup()
    scaleNewHandler?.cleanup()
    serialHandler?.cleanup()
    rfidHandler?.dispose()
    segmentHandler?.cleanup()
    floatingWindowHandler?.cleanup()
    cameraScanHandler?.cleanup()
    
    displayHandler = null
    cashBoxHandler = null
    lightHandler = null
    nfcHandler = null
    scannerHandler = null
    msrHandler = null
    scaleHandler = null
    scaleNewHandler = null
    serialHandler = null
    rfidHandler = null
    segmentHandler = null
    floatingWindowHandler = null
    cameraScanHandler = null
    deviceInfoHandler = null
  }
}
