import 'package:flutter/services.dart';

/// iMin Light Control API
///
/// Controls USB LED indicator lights on iMin POS devices.
/// Supports red and green lights for visual feedback.
///
/// Supported devices: Crane 1, M2-Pro
class IminLight {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Connect to the light device
  ///
  /// Must be called before controlling lights.
  /// Returns true if the device was connected successfully.
  ///
  /// Note: This will request USB permissions if not already granted.
  static Future<bool> connect() async {
    try {
      final result = await _channel.invokeMethod<bool>('light.connect');
      return result ?? false;
    } on PlatformException catch (e) {
      throw LightException('Failed to connect light device: ${e.message}');
    }
  }

  /// Turn on the green light
  ///
  /// Typically used to indicate success or ready state.
  /// Returns true if the command was sent successfully.
  static Future<bool> turnOnGreen() async {
    try {
      final result = await _channel.invokeMethod<bool>('light.turnOnGreen');
      return result ?? false;
    } on PlatformException catch (e) {
      throw LightException('Failed to turn on green light: ${e.message}');
    }
  }

  /// Turn on the red light
  ///
  /// Typically used to indicate error or busy state.
  /// Returns true if the command was sent successfully.
  static Future<bool> turnOnRed() async {
    try {
      final result = await _channel.invokeMethod<bool>('light.turnOnRed');
      return result ?? false;
    } on PlatformException catch (e) {
      throw LightException('Failed to turn on red light: ${e.message}');
    }
  }

  /// Turn off all lights
  ///
  /// Returns true if the command was sent successfully.
  static Future<bool> turnOff() async {
    try {
      final result = await _channel.invokeMethod<bool>('light.turnOff');
      return result ?? false;
    } on PlatformException catch (e) {
      throw LightException('Failed to turn off light: ${e.message}');
    }
  }

  /// Disconnect from the light device
  ///
  /// Should be called when done using the lights.
  /// Returns true if the device was disconnected successfully.
  static Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('light.disconnect');
      return result ?? false;
    } on PlatformException catch (e) {
      throw LightException('Failed to disconnect light device: ${e.message}');
    }
  }
}

/// Exception thrown when light operations fail
class LightException implements Exception {
  final String message;

  LightException(this.message);

  @override
  String toString() => 'LightException: $message';
}
