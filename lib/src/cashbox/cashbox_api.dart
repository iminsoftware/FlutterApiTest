import 'package:flutter/services.dart';

/// iMin Cash Box API
///
/// Controls the cash drawer on iMin POS devices.
class IminCashBox {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// Open the cash box
  ///
  /// Triggers the cash drawer to open physically.
  /// Returns true if the command was sent successfully.
  static Future<bool> open() async {
    try {
      final result = await _channel.invokeMethod<bool>('cashbox.open');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CashBoxException('Failed to open cash box: ${e.message}');
    }
  }

  /// Get cash box status
  ///
  /// Returns true if the cash box is currently open, false if closed.
  static Future<bool> getStatus() async {
    try {
      final result = await _channel.invokeMethod<bool>('cashbox.getStatus');
      return result ?? false;
    } on PlatformException catch (e) {
      throw CashBoxException('Failed to get cash box status: ${e.message}');
    }
  }

  /// Set cash box voltage
  ///
  /// [voltage] - The voltage setting for the cash box
  /// Returns true if the voltage was set successfully.
  static Future<bool> setVoltage(CashBoxVoltage voltage) async {
    try {
      final voltageStr = voltage.toString().split('.').last;
      final result = await _channel.invokeMethod<bool>(
        'cashbox.setVoltage',
        {'voltage': voltageStr},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      throw CashBoxException('Failed to set voltage: ${e.message}');
    }
  }
}

/// Cash box voltage options
enum CashBoxVoltage {
  /// 9 Volts
  v9('9V'),

  /// 12 Volts
  v12('12V'),

  /// 24 Volts
  v24('24V');

  final String value;
  const CashBoxVoltage(this.value);

  @override
  String toString() => value;
}

/// Exception thrown when cash box operations fail
class CashBoxException implements Exception {
  final String message;

  CashBoxException(this.message);

  @override
  String toString() => 'CashBoxException: $message';
}
