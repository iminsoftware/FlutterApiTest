import 'package:flutter/services.dart';

/// iMin Display API
///
/// Controls the secondary display on iMin POS devices.
class IminDisplay {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Check if secondary display is available
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('display.isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw DisplayException(
        'Failed to check display availability: ${e.message}',
      );
    }
  }

  /// Enable secondary display
  ///
  /// Returns true if display was successfully enabled
  static Future<bool> enable() async {
    try {
      final result = await _channel.invokeMethod<bool>('display.enable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw DisplayException('Failed to enable display: ${e.message}');
    }
  }

  /// Disable secondary display
  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('display.disable');
    } on PlatformException catch (e) {
      throw DisplayException('Failed to disable display: ${e.message}');
    }
  }

  /// Show text on secondary display
  ///
  /// [text] - The text to display
  static Future<void> showText(String text) async {
    try {
      await _channel.invokeMethod('display.showText', {'text': text});
    } on PlatformException catch (e) {
      throw DisplayException('Failed to show text: ${e.message}');
    }
  }

  /// Show image on secondary display
  ///
  /// [imagePath] - Path to the image file (asset or file path)
  static Future<void> showImage(String imagePath) async {
    try {
      await _channel.invokeMethod('display.showImage', {'path': imagePath});
    } on PlatformException catch (e) {
      throw DisplayException('Failed to show image: ${e.message}');
    }
  }

  /// Play video on secondary display
  ///
  /// [videoPath] - Path to the video file (asset or file path)
  static Future<void> playVideo(String videoPath) async {
    try {
      await _channel.invokeMethod('display.playVideo', {'path': videoPath});
    } on PlatformException catch (e) {
      throw DisplayException('Failed to play video: ${e.message}');
    }
  }

  /// Clear secondary display content
  static Future<void> clear() async {
    try {
      await _channel.invokeMethod('display.clear');
    } on PlatformException catch (e) {
      throw DisplayException('Failed to clear display: ${e.message}');
    }
  }
}

/// Exception thrown when display operations fail
class DisplayException implements Exception {
  final String message;

  DisplayException(this.message);

  @override
  String toString() => 'DisplayException: $message';
}
