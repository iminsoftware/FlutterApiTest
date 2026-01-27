import 'package:flutter/services.dart';

/// iMin Hardware Serial Port API
///
/// Provides serial port communication capabilities on iMin POS devices.
/// Uses NeoStra SerialPort SDK for serial communication.
///
/// Supported devices: All iMin devices with serial ports
///
/// **Usage Example:**
/// ```dart
/// // Open serial port
/// await IminSerial.open(path: '/dev/ttyS4', baudRate: 115200);
///
/// // Listen for incoming data
/// IminSerial.dataStream.listen((data) {
///   print('Received: ${data.data}');
/// });
///
/// // Write data
/// await IminSerial.write(Uint8List.fromList([0x01, 0x02, 0x03]));
///
/// // Close port
/// await IminSerial.close();
/// ```
class IminSerial {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');
  static const EventChannel _eventChannel =
      EventChannel('imin_hardware_plugin/serial');

  /// Open serial port
  ///
  /// Parameters:
  /// - [path]: Serial port device path (e.g., "/dev/ttyS4")
  /// - [baudRate]: Baud rate (default: 115200)
  ///
  /// Common baud rates: 9600, 19200, 38400, 57600, 115200
  ///
  /// Returns true if port opened successfully.
  static Future<bool> open({
    required String path,
    int baudRate = 115200,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('serial.open', {
        'path': path,
        'baudRate': baudRate,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw SerialException('Failed to open serial port: ${e.message}');
    }
  }

  /// Close serial port
  ///
  /// Returns true if port closed successfully.
  static Future<bool> close() async {
    try {
      final result = await _channel.invokeMethod<bool>('serial.close');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SerialException('Failed to close serial port: ${e.message}');
    }
  }

  /// Write data to serial port
  ///
  /// Parameters:
  /// - [data]: Byte array to write
  ///
  /// Returns true if data written successfully.
  static Future<bool> write(Uint8List data) async {
    try {
      final result = await _channel.invokeMethod<bool>('serial.write', {
        'data': data,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw SerialException('Failed to write to serial port: ${e.message}');
    }
  }

  /// Check if serial port is open
  ///
  /// Returns true if port is open.
  static Future<bool> isOpen() async {
    try {
      final result = await _channel.invokeMethod<bool>('serial.isOpen');
      return result ?? false;
    } on PlatformException catch (e) {
      throw SerialException('Failed to check serial port status: ${e.message}');
    }
  }

  /// Stream of serial port data
  ///
  /// Listen to this stream to receive data from the serial port.
  ///
  /// Must call [open] before listening to this stream.
  ///
  /// Example:
  /// ```dart
  /// await IminSerial.open(path: '/dev/ttyS4');
  ///
  /// IminSerial.dataStream.listen((data) {
  ///   print('Received ${data.data.length} bytes');
  ///   print('Data: ${data.data}');
  ///   print('Timestamp: ${data.timestamp}');
  /// });
  /// ```
  static Stream<SerialData> get dataStream {
    return _eventChannel.receiveBroadcastStream().map((data) {
      if (data is! Map) {
        throw SerialException('Invalid serial data format');
      }

      final map = Map<String, dynamic>.from(data);
      return SerialData.fromMap(map);
    });
  }
}

/// Serial port data event
class SerialData {
  /// Received data as byte list
  final List<int> data;

  /// Timestamp when data was received
  final DateTime timestamp;

  SerialData({
    required this.data,
    required this.timestamp,
  });

  factory SerialData.fromMap(Map<String, dynamic> map) {
    return SerialData(
      data: (map['data'] as List<dynamic>?)?.cast<int>() ?? [],
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Convert data to Uint8List
  Uint8List get bytes => Uint8List.fromList(data);

  /// Convert data to string (UTF-8)
  String get text => String.fromCharCodes(data);

  @override
  String toString() {
    return 'SerialData(bytes: ${data.length}, timestamp: $timestamp)';
  }
}

/// Exception thrown when serial port operations fail
class SerialException implements Exception {
  final String message;

  SerialException(this.message);

  @override
  String toString() => 'SerialException: $message';
}
