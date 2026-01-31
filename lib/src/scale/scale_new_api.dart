import 'package:flutter/services.dart';

/// 称重数据
class ScaleWeightData {
  /// 净重 (kg)
  final double net;

  /// 皮重 (kg)
  final double tare;

  /// 是否稳定
  final bool isStable;

  /// 时间戳
  final DateTime timestamp;

  ScaleWeightData({
    required this.net,
    required this.tare,
    required this.isStable,
    required this.timestamp,
  });

  factory ScaleWeightData.fromMap(Map<dynamic, dynamic> map) {
    return ScaleWeightData(
      net: (map['net'] as int) / 1000.0, // 克转千克
      tare: (map['tare'] as int) / 1000.0,
      isStable: map['isStable'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'ScaleWeightData(net: ${net.toStringAsFixed(3)}kg, tare: ${tare.toStringAsFixed(3)}kg, isStable: $isStable)';
  }
}

/// 称重状态
class ScaleStatusData {
  /// 是否过轻
  final bool isLightWeight;

  /// 是否过载
  final bool overload;

  /// 清零错误
  final bool clearZeroErr;

  /// 标定错误
  final bool calibrationErr;

  /// 时间戳
  final DateTime timestamp;

  ScaleStatusData({
    required this.isLightWeight,
    required this.overload,
    required this.clearZeroErr,
    required this.calibrationErr,
    required this.timestamp,
  });

  factory ScaleStatusData.fromMap(Map<dynamic, dynamic> map) {
    return ScaleStatusData(
      isLightWeight: map['isLightWeight'] as bool? ?? false,
      overload: map['overload'] as bool? ?? false,
      clearZeroErr: map['clearZeroErr'] as bool? ?? false,
      calibrationErr: map['calibrationErr'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 是否有错误
  bool get hasError => clearZeroErr || calibrationErr;

  /// 是否有警告
  bool get hasWarning => isLightWeight || overload;

  @override
  String toString() {
    return 'ScaleStatusData(isLightWeight: $isLightWeight, overload: $overload, clearZeroErr: $clearZeroErr, calibrationErr: $calibrationErr)';
  }
}

/// 计价数据
class ScalePriceData {
  /// 净重 (kg)
  final double net;

  /// 皮重 (kg)
  final double tare;

  /// 重量单位
  final int unit;

  /// 单价
  final String unitPrice;

  /// 总价
  final String totalPrice;

  /// 是否稳定
  final bool isStable;

  /// 是否过轻
  final bool isLightWeight;

  /// 时间戳
  final DateTime timestamp;

  ScalePriceData({
    required this.net,
    required this.tare,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    required this.isStable,
    required this.isLightWeight,
    required this.timestamp,
  });

  factory ScalePriceData.fromMap(Map<dynamic, dynamic> map) {
    return ScalePriceData(
      net: (map['net'] as int) / 1000.0,
      tare: (map['tare'] as int) / 1000.0,
      unit: map['unit'] as int? ?? 0,
      unitPrice: map['unitPrice'] as String? ?? '0',
      totalPrice: map['totalPrice'] as String? ?? '0',
      isStable: map['isStable'] as bool? ?? false,
      isLightWeight: map['isLightWeight'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// 获取单位名称
  String get unitName {
    switch (unit) {
      case 0:
        return 'g';
      case 1:
        return '100g';
      case 2:
        return '500g';
      case 3:
        return 'kg';
      default:
        return 'g';
    }
  }

  @override
  String toString() {
    return 'ScalePriceData(net: ${net.toStringAsFixed(3)}kg, unitPrice: $unitPrice, totalPrice: $totalPrice)';
  }
}

/// 连接状态
class ScaleConnectionData {
  /// 是否已连接
  final bool connected;

  /// 时间戳
  final DateTime timestamp;

  ScaleConnectionData({
    required this.connected,
    required this.timestamp,
  });

  factory ScaleConnectionData.fromMap(Map<dynamic, dynamic> map) {
    return ScaleConnectionData(
      connected: map['connected'] as bool? ?? false,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'ScaleConnectionData(connected: $connected)';
  }
}

/// 电子秤事件
class ScaleEvent {
  /// 事件类型: 'weight', 'status', 'price', 'error', 'connection'
  final String type;

  /// 事件数据
  final dynamic data;

  ScaleEvent({
    required this.type,
    required this.data,
  });

  factory ScaleEvent.fromMap(Map<dynamic, dynamic> map) {
    final type = map['type'] as String;

    dynamic data;
    switch (type) {
      case 'weight':
        data = ScaleWeightData.fromMap(map);
        break;
      case 'status':
        data = ScaleStatusData.fromMap(map);
        break;
      case 'price':
        data = ScalePriceData.fromMap(map);
        break;
      case 'connection':
        data = ScaleConnectionData.fromMap(map);
        break;
      case 'error':
        data = map['errorCode'] as int? ?? -1;
        break;
      default:
        data = map;
    }

    return ScaleEvent(type: type, data: data);
  }

  /// 是否是称重数据
  bool get isWeight => type == 'weight';

  /// 是否是状态数据
  bool get isStatus => type == 'status';

  /// 是否是计价数据
  bool get isPrice => type == 'price';

  /// 是否是错误
  bool get isError => type == 'error';

  /// 是否是连接状态
  bool get isConnection => type == 'connection';

  @override
  String toString() {
    return 'ScaleEvent(type: $type, data: $data)';
  }
}

/// 重量单位常量
class ScaleUnit {
  /// g (克，默认)
  static const int g = 0;

  /// 100g (百克)
  static const int g100 = 1;

  /// 500g (五百克)
  static const int g500 = 2;

  /// kg (千克)
  static const int kg = 3;

  /// 获取单位名称
  static String getName(int unit) {
    switch (unit) {
      case g:
        return 'g';
      case g100:
        return '100g';
      case g500:
        return '500g';
      case kg:
        return 'kg';
      default:
        return 'g';
    }
  }
}

/// 电子秤 API (Android 13+ 新版 SDK)
class IminScaleNew {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');
  static const EventChannel _eventChannel =
      EventChannel('imin_hardware_plugin/scale_new');

  static Stream<ScaleEvent>? _eventStream;

  // ==================== 服务连接 ====================

  /// 连接电子秤服务
  static Future<bool> connectService() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('scaleNew.connectService');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== 数据获取 ====================

  /// 开始获取称重数据（实时回调）
  static Future<bool> getData() async {
    try {
      final result = await _channel.invokeMethod<bool>('scaleNew.getData');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 取消获取数据
  static Future<bool> cancelGetData() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('scaleNew.cancelGetData');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== 版本信息 ====================

  /// 获取服务版本号
  static Future<String> getServiceVersion() async {
    try {
      final result =
          await _channel.invokeMethod<String>('scaleNew.getServiceVersion');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 获取固件版本号
  static Future<String> getFirmwareVersion() async {
    try {
      final result =
          await _channel.invokeMethod<String>('scaleNew.getFirmwareVersion');
      return result ?? 'Unknown';
    } catch (e) {
      return 'Unknown';
    }
  }

  // ==================== 称重操作 ====================

  /// 清零（清除 300g 以内的结果偏差）
  static Future<bool> zero() async {
    try {
      final result = await _channel.invokeMethod<bool>('scaleNew.zero');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 去皮/清皮
  ///
  /// 秤上有重量时为去皮，没有时为清皮
  static Future<bool> tare() async {
    try {
      final result = await _channel.invokeMethod<bool>('scaleNew.tare');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 数字去皮
  ///
  /// 直接给电子秤下发去皮的重量（单位：克）
  static Future<bool> digitalTare(int weight) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'scaleNew.digitalTare',
        {'weight': weight},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== 价格计算 ====================

  /// 设置单价
  ///
  /// 由电子秤服务计算价格时设置，将影响返回的计价结果
  /// 支持4位小数点位的计算
  static Future<bool> setUnitPrice(String price) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'scaleNew.setUnitPrice',
        {'price': price},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 获取当前已经设置的单价
  static Future<String> getUnitPrice() async {
    try {
      final result =
          await _channel.invokeMethod<String>('scaleNew.getUnitPrice');
      return result ?? '0';
    } catch (e) {
      return '0';
    }
  }

  /// 设置价格计算时的重量单位
  ///
  /// - 0: 按 g 计重
  /// - 1: 按 100g 计重
  /// - 2: 按 500g 计重
  /// - 3: 按 kg 计重
  static Future<bool> setUnit(int unit) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'scaleNew.setUnit',
        {'unit': unit},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 获取当前价格计算的重量单位
  static Future<int> getUnit() async {
    try {
      final result = await _channel.invokeMethod<int>('scaleNew.getUnit');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ==================== 设备信息 ====================

  /// 读取加速度数据
  ///
  /// 返回 [X, Y, Z] 方向数据
  static Future<List<int>> readAcceleData() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('scaleNew.readAcceleData');
      return result?.cast<int>() ?? [0, 0, 0];
    } catch (e) {
      return [0, 0, 0];
    }
  }

  /// 获取铅封状态
  ///
  /// - 0: 正常
  /// - 1: 铅封被破坏
  static Future<int> readSealState() async {
    try {
      final result = await _channel.invokeMethod<int>('scaleNew.readSealState');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 读取标定按钮开关状态
  ///
  /// - 0: 未按下
  /// - 1: 按下
  static Future<int> getCalStatus() async {
    try {
      final result = await _channel.invokeMethod<int>('scaleNew.getCalStatus');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 读取电子秤参数信息
  ///
  /// 返回值为一个多个量程的二维数组
  /// 例如量程为 6/15kg e=2/5g 多量程
  /// 电子秤将返回 [[6,2],[15,5]]
  static Future<List<List<int>>> getCalInfo() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('scaleNew.getCalInfo');
      if (result == null) return [];

      return result.map((item) {
        if (item is List) {
          return item.cast<int>();
        }
        return <int>[];
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ==================== 系统设置 ====================

  /// 重启电子秤
  ///
  /// 电子秤重启会重新读取零点请谨慎调用此方法防止秤重读数不准确
  static Future<bool> restart() async {
    try {
      final result = await _channel.invokeMethod<bool>('scaleNew.restart');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 获取城市重力加速表
  ///
  /// 例如一条数据：安徽,97947
  static Future<List<String>> getCityAccelerations() async {
    try {
      final result = await _channel
          .invokeMethod<List<dynamic>>('scaleNew.getCityAccelerations');
      return result?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// 设置城市重力加速
  ///
  /// index 对应城市重力加速列表顺序
  /// 返回 true 为设置成功，false 为设置失败
  static Future<bool> setGravityAcceleration(int index) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'scaleNew.setGravityAcceleration',
        {'index': index},
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  // ==================== 事件流 ====================

  /// 电子秤事件流
  ///
  /// 包含以下事件类型：
  /// - weight: 称重数据
  /// - status: 称重状态
  /// - price: 计价数据
  /// - error: 错误信息
  /// - connection: 连接状态
  static Stream<ScaleEvent> get eventStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream().map((data) {
      if (data is Map) {
        return ScaleEvent.fromMap(data.cast<String, dynamic>());
      }
      return ScaleEvent(type: 'unknown', data: data);
    });
    return _eventStream!;
  }
}
