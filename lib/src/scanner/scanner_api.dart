import 'package:flutter/services.dart';

/// iMin Hardware Scanner API
///
/// Provides hardware scanner (scan head) capabilities on iMin POS devices.
/// Uses BroadcastReceiver to receive scan results from the hardware scanner.
///
/// Supported devices: Crane 1, Swan 2, Swift 1, Swift 2 Ultra, Lark 1,
/// Falcon 2, M2-Pro
///
/// Note: This is for hardware scan heads, not camera-based scanning.
/// For camera scanning, see [IminCameraScan].
class IminScanner {
  static const MethodChannel _channel = MethodChannel('com.imin.hardware');
  static const EventChannel _eventChannel =
      EventChannel('com.imin.hardware/scanner');

  /// Configure custom broadcast parameters (optional)
  ///
  /// Allows customization of broadcast action and extra keys for
  /// compatibility with different scanner models.
  ///
  /// Parameters:
  /// - [action]: Custom broadcast action (default: "com.imin.scanner.api.RESULT_ACTION")
  /// - [dataKey]: Custom string data key (default: "decode_data_str")
  /// - [byteDataKey]: Custom byte data key (default: "decode_data")
  ///
  /// Must be called before [startListening].
  ///
  /// Example:
  /// ```dart
  /// await IminScanner.configure(
  ///   action: 'com.custom.scanner.SCAN',
  ///   dataKey: 'scan_data',
  /// );
  /// ```
  static Future<void> configure({
    String? action,
    String? dataKey,
    String? byteDataKey,
  }) async {
    try {
      await _channel.invokeMethod('scanner.configure', {
        if (action != null) 'action': action,
        if (dataKey != null) 'dataKey': dataKey,
        if (byteDataKey != null) 'byteDataKey': byteDataKey,
      });
    } on PlatformException catch (e) {
      throw ScannerException('Failed to configure scanner: ${e.message}');
    }
  }

  /// Start listening for scanner broadcasts
  ///
  /// Registers a BroadcastReceiver to receive scan results from the
  /// hardware scanner. Must be called before scanning.
  ///
  /// Returns true if started successfully, false if already listening.
  static Future<bool> startListening() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('scanner.startListening');
      return result ?? false;
    } on PlatformException catch (e) {
      throw ScannerException('Failed to start scanner listener: ${e.message}');
    }
  }

  /// Stop listening for scanner broadcasts
  ///
  /// Unregisters the BroadcastReceiver. Should be called when scanner
  /// is no longer needed to free resources.
  ///
  /// Returns true if stopped successfully, false if not listening.
  static Future<bool> stopListening() async {
    try {
      final result = await _channel.invokeMethod<bool>('scanner.stopListening');
      return result ?? false;
    } on PlatformException catch (e) {
      throw ScannerException('Failed to stop scanner listener: ${e.message}');
    }
  }

  /// Check if scanner device is connected
  ///
  /// Returns true if a hardware scanner is connected via USB.
  static Future<bool> isConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('scanner.isConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      throw ScannerException(
          'Failed to check scanner connection: ${e.message}');
    }
  }

  /// Stream of scanner events
  ///
  /// Listen to this stream to receive scanner events including:
  /// - Scan results when a barcode/QR code is scanned
  /// - Device connection/disconnection events
  /// - Connection status updates
  ///
  /// Must call [startListening] before listening to this stream.
  ///
  /// Example:
  /// ```dart
  /// await IminScanner.startListening();
  ///
  /// IminScanner.scanStream.listen((event) {
  ///   if (event is ScanResult) {
  ///     print('Scanned: ${event.data}');
  ///     print('Type: ${event.labelType}');
  ///   } else if (event is ScannerConnected) {
  ///     print('Scanner connected');
  ///   } else if (event is ScannerDisconnected) {
  ///     print('Scanner disconnected');
  ///   }
  /// });
  /// ```
  static Stream<ScannerEvent> get scanStream {
    return _eventChannel.receiveBroadcastStream().map((data) {
      if (data is! Map) {
        throw ScannerException('Invalid scanner event data format');
      }

      final map = Map<String, dynamic>.from(data);
      final eventType = map['event'] as String?;

      switch (eventType) {
        case 'scanResult':
          return ScanResult.fromMap(map);
        case 'connected':
          return ScannerConnected.fromMap(map);
        case 'disconnected':
          return ScannerDisconnected.fromMap(map);
        case 'connectionStatus':
          return ScannerConnectionStatus.fromMap(map);
        default:
          throw ScannerException('Unknown event type: $eventType');
      }
    });
  }
}

/// Base class for scanner events
abstract class ScannerEvent {
  /// Timestamp when the event occurred
  final DateTime timestamp;

  ScannerEvent({required this.timestamp});
}

/// Scan result event
///
/// Emitted when a barcode/QR code is successfully scanned.
class ScanResult extends ScannerEvent {
  /// Scanned data as string
  final String data;

  /// Label type (barcode format)
  /// Examples: "QR_CODE", "EAN_13", "CODE_128", etc.
  final String labelType;

  /// Raw byte data (if available)
  final List<int>? rawData;

  ScanResult({
    required this.data,
    required this.labelType,
    this.rawData,
    required DateTime timestamp,
  }) : super(timestamp: timestamp);

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      data: map['data'] as String? ?? '',
      labelType: map['labelType'] as String? ?? '',
      rawData: (map['rawData'] as List<dynamic>?)?.cast<int>(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'ScanResult(data: $data, labelType: $labelType, timestamp: $timestamp)';
  }
}

/// Scanner connected event
///
/// Emitted when a hardware scanner is connected via USB.
class ScannerConnected extends ScannerEvent {
  ScannerConnected({required DateTime timestamp}) : super(timestamp: timestamp);

  factory ScannerConnected.fromMap(Map<String, dynamic> map) {
    return ScannerConnected(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() => 'ScannerConnected(timestamp: $timestamp)';
}

/// Scanner disconnected event
///
/// Emitted when a hardware scanner is disconnected.
class ScannerDisconnected extends ScannerEvent {
  ScannerDisconnected({required DateTime timestamp})
      : super(timestamp: timestamp);

  factory ScannerDisconnected.fromMap(Map<String, dynamic> map) {
    return ScannerDisconnected(
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() => 'ScannerDisconnected(timestamp: $timestamp)';
}

/// Scanner connection status event
///
/// Emitted in response to a connection status query.
class ScannerConnectionStatus extends ScannerEvent {
  /// Whether the scanner is connected
  final bool connected;

  ScannerConnectionStatus({
    required this.connected,
    required DateTime timestamp,
  }) : super(timestamp: timestamp);

  factory ScannerConnectionStatus.fromMap(Map<String, dynamic> map) {
    return ScannerConnectionStatus(
      connected: map['connected'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() =>
      'ScannerConnectionStatus(connected: $connected, timestamp: $timestamp)';
}

/// Exception thrown when scanner operations fail
class ScannerException implements Exception {
  final String message;

  ScannerException(this.message);

  @override
  String toString() => 'ScannerException: $message';
}
