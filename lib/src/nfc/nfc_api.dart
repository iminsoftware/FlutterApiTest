import 'package:flutter/services.dart';

/// iMin NFC Reader API
///
/// Provides NFC tag reading capabilities on iMin POS devices.
/// Supports reading NFC ID (card number) and NDEF message content.
///
/// Supported devices: Crane 1, Swan 1, Swan 2, Swift 1, Swift 2, Swift 2 Ultra,
/// Lark 1, Falcon 2, M2-Pro
class IminNfc {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');
  static const EventChannel _eventChannel =
      EventChannel('imin_hardware_plugin/nfc');

  /// Check if NFC is available on this device
  ///
  /// Returns true if the device has NFC hardware.
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('nfc.isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      throw NfcException('Failed to check NFC availability: ${e.message}');
    }
  }

  /// Check if NFC is enabled
  ///
  /// Returns true if NFC is turned on in device settings.
  static Future<bool> isEnabled() async {
    try {
      final result = await _channel.invokeMethod<bool>('nfc.isEnabled');
      return result ?? false;
    } on PlatformException catch (e) {
      throw NfcException('Failed to check NFC status: ${e.message}');
    }
  }

  /// Open NFC settings page
  ///
  /// Navigates the user to the system NFC settings page
  /// where they can enable NFC.
  static Future<void> openSettings() async {
    try {
      await _channel.invokeMethod('nfc.openSettings');
    } on PlatformException catch (e) {
      throw NfcException('Failed to open NFC settings: ${e.message}');
    }
  }

  /// Stream of NFC tags
  ///
  /// Listen to this stream to receive NFC tag data when a card is scanned.
  /// The stream will emit [NfcTag] objects containing the tag information.
  ///
  /// Example:
  /// ```dart
  /// IminNfc.tagStream.listen((tag) {
  ///   print('NFC ID: ${tag.id}');
  ///   print('Content: ${tag.content}');
  /// });
  /// ```
  static Stream<NfcTag> get tagStream {
    return _eventChannel.receiveBroadcastStream().map((data) {
      if (data is Map) {
        return NfcTag.fromMap(Map<String, dynamic>.from(data));
      }
      throw NfcException('Invalid NFC tag data format');
    });
  }
}

/// Represents an NFC tag that was scanned
class NfcTag {
  /// NFC tag ID (card number) in hexadecimal format
  final String id;

  /// NDEF message content (if available)
  final String content;

  /// NFC technology type (e.g., "NfcA", "IsoDep", "Ndef")
  final String technology;

  /// Timestamp when the tag was read
  final DateTime timestamp;

  NfcTag({
    required this.id,
    required this.content,
    required this.technology,
    required this.timestamp,
  });

  /// Create NfcTag from map data
  factory NfcTag.fromMap(Map<String, dynamic> map) {
    return NfcTag(
      id: map['id'] as String? ?? '',
      content: map['content'] as String? ?? '',
      technology: map['technology'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Convert to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'technology': technology,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Format NFC ID with spaces for better readability
  /// Example: "1234567890ABCDEF" -> "1234 5678 90AB CDEF"
  String get formattedId {
    if (id.isEmpty) return '';

    final buffer = StringBuffer();
    for (int i = 0; i < id.length; i++) {
      buffer.write(id[i]);
      if ((i + 1) % 4 == 0 && i != id.length - 1) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  @override
  String toString() {
    return 'NfcTag(id: $id, content: $content, technology: $technology, timestamp: $timestamp)';
  }
}

/// Exception thrown when NFC operations fail
class NfcException implements Exception {
  final String message;

  NfcException(this.message);

  @override
  String toString() => 'NfcException: $message';
}
