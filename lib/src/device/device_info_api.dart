import 'package:flutter/services.dart';

/// 设备信息
class DeviceInfo {
  /// 品牌
  final String brand;

  /// 型号
  final String model;

  /// 序列号
  final String serialNumber;

  /// 设备名称
  final String deviceName;

  DeviceInfo({
    required this.brand,
    required this.model,
    required this.serialNumber,
    required this.deviceName,
  });

  factory DeviceInfo.fromMap(Map<dynamic, dynamic> map) {
    return DeviceInfo(
      brand: map['brand'] as String? ?? 'Unknown',
      model: map['model'] as String? ?? 'Unknown',
      serialNumber: map['serialNumber'] as String? ?? 'Unknown',
      deviceName: map['deviceName'] as String? ?? 'Unknown',
    );
  }

  @override
  String toString() {
    return 'DeviceInfo(brand: $brand, model: $model, serialNumber: $serialNumber, deviceName: $deviceName)';
  }
}

/// 设备信息 API
class IminDeviceInfo {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');

  /// 获取品牌
  static Future<String> getBrand() async {
    try {
      final result = await _channel.invokeMethod<String>('device.getBrand');
      return result ?? 'iMin';
    } catch (e) {
      return 'iMin';
    }
  }

  /// 获取型号
  static Future<String> getModel() async {
    try {
      final result = await _channel.invokeMethod<String>('device.getModel');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 获取序列号
  static Future<String> getSerialNumber() async {
    try {
      final result =
          await _channel.invokeMethod<String>('device.getSerialNumber');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 获取设备名称
  static Future<String> getDeviceName() async {
    try {
      final result =
          await _channel.invokeMethod<String>('device.getDeviceName');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 获取完整设备信息
  static Future<DeviceInfo> getDeviceInfo() async {
    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('device.getDeviceInfo');
      if (result != null) {
        return DeviceInfo.fromMap(result);
      }
      return DeviceInfo(
        brand: 'iMin',
        model: 'Unknown',
        serialNumber: 'Unknown',
        deviceName: 'Unknown',
      );
    } catch (e) {
      return DeviceInfo(
        brand: 'iMin',
        model: 'Unknown',
        serialNumber: 'Unknown',
        deviceName: 'Unknown',
      );
    }
  }

  /// 获取 Android SDK 版本号
  ///
  /// 返回值示例：
  /// - Android 11 = 30
  /// - Android 13 = 33
  /// - Android 14 = 34
  static Future<int> getAndroidVersion() async {
    try {
      final result =
          await _channel.invokeMethod<int>('device.getAndroidVersion');
      return result ?? 30; // 默认返回 Android 11
    } catch (e) {
      return 30; // 默认返回 Android 11
    }
  }

  /// 获取 Android 版本名称
  ///
  /// 返回值示例：
  /// - "11"
  /// - "13"
  /// - "14"
  static Future<String> getAndroidVersionName() async {
    try {
      final result =
          await _channel.invokeMethod<String>('device.getAndroidVersionName');
      return result ?? '11';
    } catch (e) {
      return '11';
    }
  }
}
