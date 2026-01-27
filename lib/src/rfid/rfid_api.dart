import 'dart:async';
import 'package:flutter/services.dart';

/// RFID API
///
/// 提供 RFID 设备的完整功能：
/// - 设备连接管理
/// - 标签读取（单次/连续）
/// - 标签写入
/// - 标签锁定/销毁
/// - 配置管理
/// - 电池监控
class IminRfid {
  static const MethodChannel _channel = MethodChannel('imin_hardware_plugin');
  static const EventChannel _tagChannel =
      EventChannel('imin_hardware_plugin/rfid_tag');
  static const EventChannel _connectionChannel =
      EventChannel('imin_hardware_plugin/rfid_connection');
  static const EventChannel _batteryChannel =
      EventChannel('imin_hardware_plugin/rfid_battery');

  // ==================== 连接管理 ====================

  /// 连接 RFID 设备
  static Future<void> connect() async {
    await _channel.invokeMethod('rfid.connect');
  }

  /// 断开 RFID 设备
  static Future<void> disconnect() async {
    await _channel.invokeMethod('rfid.disconnect');
  }

  /// 检查是否已连接
  static Future<bool> isConnected() async {
    final result = await _channel.invokeMethod<bool>('rfid.isConnected');
    return result ?? false;
  }

  // ==================== 标签读取 ====================

  /// 开始连续读取标签
  static Future<void> startReading() async {
    await _channel.invokeMethod('rfid.startReading');
  }

  /// 停止读取标签
  static Future<void> stopReading() async {
    await _channel.invokeMethod('rfid.stopReading');
  }

  /// 读取指定标签的数据
  ///
  /// [bank] - 存储区域：0=Reserved, 1=EPC, 2=TID, 3=USER
  /// [address] - 起始地址（字）
  /// [length] - 读取长度（字）
  /// [password] - 访问密码（十六进制字符串，可选）
  static Future<void> readTag({
    int bank = 1,
    int address = 2,
    int length = 6,
    String password = '',
  }) async {
    await _channel.invokeMethod('rfid.readTag', {
      'bank': bank,
      'address': address,
      'length': length,
      'password': password,
    });
  }

  /// 清空已读取的标签列表
  static Future<void> clearTags() async {
    await _channel.invokeMethod('rfid.clearTags');
  }

  // ==================== 标签写入 ====================

  /// 写入标签数据
  ///
  /// [bank] - 存储区域：0=Reserved, 1=EPC, 2=TID, 3=USER
  /// [address] - 起始地址（字）
  /// [data] - 要写入的数据（十六进制字符串）
  /// [password] - 访问密码（十六进制字符串，可选）
  static Future<void> writeTag({
    required int bank,
    required int address,
    required String data,
    String password = '',
  }) async {
    await _channel.invokeMethod('rfid.writeTag', {
      'bank': bank,
      'address': address,
      'data': data,
      'password': password,
    });
  }

  /// 写入 EPC 数据
  ///
  /// [newEpc] - 新的 EPC 数据（十六进制字符串）
  /// [password] - 访问密码（十六进制字符串，可选）
  static Future<void> writeEpc({
    required String newEpc,
    String password = '',
  }) async {
    await _channel.invokeMethod('rfid.writeEpc', {
      'newEpc': newEpc,
      'password': password,
    });
  }

  // ==================== 标签操作 ====================

  /// 锁定标签
  ///
  /// [lockObject] - 锁定对象：0=KillPassword, 1=AccessPassword, 2=EPC, 3=TID, 4=USER
  /// [lockType] - 锁定类型：0=Unlock, 1=Lock, 2=PermanentLock
  /// [password] - 访问密码（十六进制字符串）
  static Future<void> lockTag({
    required int lockObject,
    required int lockType,
    String password = '',
  }) async {
    await _channel.invokeMethod('rfid.lockTag', {
      'lockObject': lockObject,
      'lockType': lockType,
      'password': password,
    });
  }

  /// 销毁标签
  ///
  /// [password] - 销毁密码（十六进制字符串，必需）
  static Future<void> killTag({
    required String password,
  }) async {
    await _channel.invokeMethod('rfid.killTag', {
      'password': password,
    });
  }

  // ==================== 配置管理 ====================

  /// 设置读写功率
  ///
  /// [readPower] - 读取功率（10-30 dBm）
  /// [writePower] - 写入功率（10-30 dBm）
  static Future<void> setPower({
    int readPower = 30,
    int writePower = 30,
  }) async {
    await _channel.invokeMethod('rfid.setReadPower', {
      'readPower': readPower,
      'writePower': writePower,
    });
  }

  /// 设置标签过滤器
  ///
  /// [epc] - 要过滤的 EPC（十六进制字符串）
  static Future<void> setFilter({
    required String epc,
  }) async {
    await _channel.invokeMethod('rfid.setFilter', {
      'epc': epc,
    });
  }

  /// 清除标签过滤器
  static Future<void> clearFilter() async {
    await _channel.invokeMethod('rfid.clearFilter');
  }

  /// 设置 RSSI 过滤器
  ///
  /// [enabled] - 是否启用
  /// [level] - RSSI 阈值（-70 到 0 dBm）
  static Future<void> setRssiFilter({
    required bool enabled,
    int level = -70,
  }) async {
    await _channel.invokeMethod('rfid.setRssiFilter', {
      'enabled': enabled,
      'level': level,
    });
  }

  /// 设置 Gen2 Q 值
  ///
  /// [qValue] - Q 值（-1=自动，0-15=固定值）
  static Future<void> setGen2Q({
    int qValue = -1,
  }) async {
    await _channel.invokeMethod('rfid.setGen2Q', {
      'qValue': qValue,
    });
  }

  /// 设置会话模式
  ///
  /// [session] - 会话：0=S0, 1=S1, 2=S2, 3=S3
  static Future<void> setSession({
    int session = 0,
  }) async {
    await _channel.invokeMethod('rfid.setSession', {
      'session': session,
    });
  }

  /// 设置目标模式
  ///
  /// [target] - 目标：0=A, 1=B, 2=A->B, 3=B->A
  static Future<void> setTarget({
    int target = 0,
  }) async {
    await _channel.invokeMethod('rfid.setTarget', {
      'target': target,
    });
  }

  /// 设置 RF 模式
  ///
  /// [rfMode] - RF 模式字符串
  static Future<void> setRfMode({
    String rfMode = 'RF_MODE_1',
  }) async {
    await _channel.invokeMethod('rfid.setRfMode', {
      'rfMode': rfMode,
    });
  }

  // ==================== 电池监控 ====================

  /// 获取电池电量（0-100）
  static Future<int> getBatteryLevel() async {
    final result = await _channel.invokeMethod<int>('rfid.getBatteryLevel');
    return result ?? 0;
  }

  /// 检查是否正在充电
  static Future<bool> isCharging() async {
    final result = await _channel.invokeMethod<bool>('rfid.isCharging');
    return result ?? false;
  }

  // ==================== 事件流 ====================

  /// 标签事件流
  ///
  /// 接收标签读取、写入、锁定、销毁等事件
  static Stream<RfidEvent> get tagStream {
    return _tagChannel.receiveBroadcastStream('tag_stream').map((event) {
      return RfidEvent.fromMap(Map<String, dynamic>.from(event));
    });
  }

  /// 连接状态流
  static Stream<bool> get connectionStream {
    return _connectionChannel
        .receiveBroadcastStream('connection_stream')
        .map((event) {
      final map = Map<String, dynamic>.from(event);
      return map['connected'] as bool? ?? false;
    });
  }

  /// 电池状态流
  static Stream<BatteryStatus> get batteryStream {
    return _batteryChannel
        .receiveBroadcastStream('battery_stream')
        .map((event) {
      return BatteryStatus.fromMap(Map<String, dynamic>.from(event));
    });
  }
}

// ==================== 数据模型 ====================

/// RFID 事件
class RfidEvent {
  final String type;
  final Map<String, dynamic> data;

  RfidEvent({
    required this.type,
    required this.data,
  });

  factory RfidEvent.fromMap(Map<String, dynamic> map) {
    return RfidEvent(
      type: map['type'] as String? ?? 'unknown',
      data: map,
    );
  }

  /// 是否是标签事件
  bool get isTag => type == 'tag';

  /// 是否是读取成功事件
  bool get isReadSuccess => type == 'read_success';

  /// 是否是写入成功事件
  bool get isWriteSuccess => type == 'write_success';

  /// 是否是锁定成功事件
  bool get isLockSuccess => type == 'lock_success';

  /// 是否是销毁成功事件
  bool get isKillSuccess => type == 'kill_success';

  /// 是否是错误事件
  bool get isError => type == 'error';

  /// 获取标签数据（如果是标签事件）
  RfidTag? get tag => isTag ? RfidTag.fromMap(data) : null;

  /// 获取错误信息（如果是错误事件）
  String? get errorMessage => isError ? data['message'] as String? : null;

  @override
  String toString() => 'RfidEvent(type: $type, data: $data)';
}

/// RFID 标签
class RfidTag {
  final String epc;
  final String? pc;
  final String? tid;
  final int rssi;
  final int count;
  final int frequency;
  final int timestamp;

  RfidTag({
    required this.epc,
    this.pc,
    this.tid,
    required this.rssi,
    required this.count,
    required this.frequency,
    required this.timestamp,
  });

  factory RfidTag.fromMap(Map<String, dynamic> map) {
    return RfidTag(
      epc: map['epc'] as String? ?? '',
      pc: map['pc'] as String?,
      tid: map['tid'] as String?,
      rssi: map['rssi'] as int? ?? 0,
      count: map['count'] as int? ?? 0,
      frequency: map['frequency'] as int? ?? 0,
      timestamp: map['timestamp'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'epc': epc,
      'pc': pc,
      'tid': tid,
      'rssi': rssi,
      'count': count,
      'frequency': frequency,
      'timestamp': timestamp,
    };
  }

  @override
  String toString() => 'RfidTag(epc: $epc, rssi: $rssi, count: $count)';
}

/// 电池状态
class BatteryStatus {
  final int level;
  final bool charging;

  BatteryStatus({
    required this.level,
    required this.charging,
  });

  factory BatteryStatus.fromMap(Map<String, dynamic> map) {
    return BatteryStatus(
      level: map['level'] as int? ?? 0,
      charging: map['charging'] as bool? ?? false,
    );
  }

  /// 电池状态描述
  String get description {
    if (charging) return '充电中 ($level%)';
    if (level >= 75) return '电量充足 ($level%)';
    if (level >= 50) return '电量中等 ($level%)';
    if (level >= 25) return '电量较低 ($level%)';
    return '电量不足 ($level%)';
  }

  @override
  String toString() => 'BatteryStatus(level: $level%, charging: $charging)';
}

// ==================== 常量定义 ====================

/// 存储区域
class RfidBank {
  static const int reserved = 0;
  static const int epc = 1;
  static const int tid = 2;
  static const int user = 3;
}

/// 锁定对象
class LockObject {
  static const int killPassword = 0;
  static const int accessPassword = 1;
  static const int epc = 2;
  static const int tid = 3;
  static const int user = 4;
}

/// 锁定类型
class LockType {
  static const int unlock = 0;
  static const int lock = 1;
  static const int permanentLock = 2;
}

/// 会话模式
class SessionMode {
  static const int s0 = 0;
  static const int s1 = 1;
  static const int s2 = 2;
  static const int s3 = 3;
}

/// 目标模式
class TargetMode {
  static const int a = 0;
  static const int b = 1;
  static const int aToB = 2;
  static const int bToA = 3;
}

/// RF 模式
class RfMode {
  static const String mode1 = 'RF_MODE_1';
  static const String mode3 = 'RF_MODE_3';
  static const String mode5 = 'RF_MODE_5';
  static const String mode7 = 'RF_MODE_7';
  static const String mode11 = 'RF_MODE_11';
  static const String mode12 = 'RF_MODE_12';
  static const String mode13 = 'RF_MODE_13';
  static const String mode15 = 'RF_MODE_15';
  static const String mode103 = 'RF_MODE_103';
  static const String mode120 = 'RF_MODE_120';
  static const String mode345 = 'RF_MODE_345';
}
