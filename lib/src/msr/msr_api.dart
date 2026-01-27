import 'package:flutter/services.dart';

/// iMin Hardware MSR (Magnetic Stripe Reader) API
///
/// Provides magnetic stripe card reading capabilities on iMin POS devices.
///
/// **Important Note:**
/// MSR devices typically work as keyboard input devices. When a card is swiped,
/// the data is automatically input as keyboard text. This means:
/// - No special API calls are needed to read card data
/// - Card data appears in focused text input fields automatically
/// - The data format depends on the card and MSR device configuration
///
/// Supported devices: Crane 1, Swan 2, M2-Pro
///
/// **Usage Example:**
/// ```dart
/// // Simply use a TextField to receive MSR input
/// TextField(
///   controller: _msrController,
///   decoration: InputDecoration(
///     labelText: 'Swipe card here',
///     hintText: 'Card data will appear automatically',
///   ),
///   onSubmitted: (value) {
///     // Process card data
///     print('Card data: $value');
///   },
/// )
/// ```
class IminMsr {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Check if MSR device is available
  ///
  /// Returns true if MSR functionality is available.
  ///
  /// Note: This method returns true by default since MSR devices
  /// work as keyboard input. Actual availability depends on hardware.
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('msr.isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw MsrException('Failed to check MSR availability: ${e.message}');
    }
  }
}

/// Exception thrown when MSR operations fail
class MsrException implements Exception {
  final String message;

  MsrException(this.message);

  @override
  String toString() => 'MsrException: $message';
}
