import 'package:flutter/services.dart';

/// Floating Window API for iMin devices
///
/// Provides functionality to show/hide a floating window overlay
class FloatingWindowApi {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Show the floating window
  ///
  /// Returns true if the window was shown successfully
  /// Throws PlatformException if permission is not granted
  static Future<bool> show() async {
    try {
      final result = await _channel.invokeMethod<bool>('floatingWindow.show');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to show floating window: ${e.message}');
    }
  }

  /// Hide the floating window
  ///
  /// Returns true if the window was hidden successfully
  static Future<bool> hide() async {
    try {
      final result = await _channel.invokeMethod<bool>('floatingWindow.hide');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to hide floating window: ${e.message}');
    }
  }

  /// Check if the floating window is currently visible
  static Future<bool> isShowing() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('floatingWindow.isShowing');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to check floating window status: ${e.message}');
    }
  }

  /// Update the floating window text
  ///
  /// [text] The text to display in the floating window
  static Future<bool> updateText(String text) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'floatingWindow.updateText',
        {'text': text},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to update floating window text: ${e.message}');
    }
  }

  /// Set the floating window position
  ///
  /// [x] X coordinate (pixels from left)
  /// [y] Y coordinate (pixels from top)
  static Future<bool> setPosition(int x, int y) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'floatingWindow.setPosition',
        {'x': x, 'y': y},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to set floating window position: ${e.message}');
    }
  }
}
