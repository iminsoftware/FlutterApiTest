import 'package:flutter/services.dart';

enum ScaleStatus {
  stable,
  unstable,
  overweight,
  unknown,
}

class ScaleData {
  final String weight;
  final ScaleStatus status;

  ScaleData({
    required this.weight,
    required this.status,
  });

  factory ScaleData.fromMap(Map<String, dynamic> map) {
    return ScaleData(
      weight: map['weight'] as String,
      status: _parseStatus(map['status'] as String),
    );
  }

  static ScaleStatus _parseStatus(String status) {
    switch (status) {
      case 'stable':
        return ScaleStatus.stable;
      case 'unstable':
        return ScaleStatus.unstable;
      case 'overweight':
        return ScaleStatus.overweight;
      default:
        return ScaleStatus.unknown;
    }
  }
}


class IminScale {
  static const MethodChannel _channel = MethodChannel('com.imin.hardware');
  static const EventChannel _eventChannel =
      EventChannel('com.imin.hardware/scale');

  static Future<bool> connect({
    String devicePath = '/dev/ttyS4',
    int baudRate = 9600,
  }) async {
    try {
      final result = await _channel.invokeMethod('scale.connect', {
        'devicePath': devicePath,
        'baudRate': baudRate,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod('scale.disconnect');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> tare() async {
    try {
      final result = await _channel.invokeMethod('scale.tare');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> zero() async {
    try {
      final result = await _channel.invokeMethod('scale.zero');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  static Stream<ScaleData> get weightStream {
    return _eventChannel.receiveBroadcastStream().map((data) {
      return ScaleData.fromMap(Map<String, dynamic>.from(data));
    });
  }
}
