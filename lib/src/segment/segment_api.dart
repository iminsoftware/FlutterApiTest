import 'package:flutter/services.dart';

/// iMin 数码管显示 API
///
/// 用于控制 iMin 设备的数码管显示屏
class IminSegment {
  static const MethodChannel _channel = MethodChannel('com.imin.hardware');

  /// 查找数码管设备
  ///
  /// 返回设备信息，包括：
  /// - found: 是否找到设备
  /// - productId: 产品 ID
  /// - vendorId: 厂商 ID
  /// - deviceName: 设备名称
  static Future<Map<String, dynamic>> findDevice() async {
    try {
      final result = await _channel.invokeMethod('segment.findDevice');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('Failed to find segment device: $e');
    }
  }

  /// 请求 USB 权限
  ///
  /// 在连接设备前必须先请求权限
  /// 返回 true 表示权限已授予
  static Future<bool> requestPermission() async {
    try {
      final result = await _channel.invokeMethod('segment.requestPermission');
      return result == true;
    } catch (e) {
      throw Exception('Failed to request USB permission: $e');
    }
  }

  /// 连接到数码管设备
  ///
  /// 在调用此方法前，必须先调用 [findDevice] 和 [requestPermission]
  /// 返回 true 表示连接成功
  static Future<bool> connect() async {
    try {
      final result = await _channel.invokeMethod('segment.connect');
      return result == true;
    } catch (e) {
      throw Exception('Failed to connect to segment device: $e');
    }
  }

  /// 发送数据到数码管显示
  ///
  /// [data] 要显示的数据（最多 9 个字符）
  /// [align] 对齐方式：'left' 左对齐，'right' 右对齐（默认）
  static Future<void> sendData(String data, {String align = 'right'}) async {
    try {
      await _channel.invokeMethod('segment.sendData', {
        'data': data,
        'align': align,
      });
    } catch (e) {
      throw Exception('Failed to send data to segment display: $e');
    }
  }

  /// 清空数码管显示
  static Future<void> clear() async {
    try {
      await _channel.invokeMethod('segment.clear');
    } catch (e) {
      throw Exception('Failed to clear segment display: $e');
    }
  }

  /// 数码管全亮显示（测试用）
  static Future<void> full() async {
    try {
      await _channel.invokeMethod('segment.full');
    } catch (e) {
      throw Exception('Failed to set segment display to full: $e');
    }
  }

  /// 断开与数码管设备的连接
  static Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('segment.disconnect');
    } catch (e) {
      throw Exception('Failed to disconnect from segment device: $e');
    }
  }
}
