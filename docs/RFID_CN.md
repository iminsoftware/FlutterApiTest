# RFID 模块

iMin POS 设备的 RFID 标签读取和操作。

## 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 导入

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
```

插件导出 `IminRfid` 类用于 RFID 操作。

## 功能特性

- 连接 RFID 读取器
- 读取 RFID 标签
- 基于流的标签检测
- 电池状态监控
- 标签操作（读取、写入、锁定、销毁）

## API 参考

### 检查连接

```dart
bool connected = await IminRfid.isConnected();
```

### 连接

```dart
await IminRfid.connect();
```

### 断开连接

```dart
await IminRfid.disconnect();
```

### 开始读取

```dart
await IminRfid.startReading();
```

### 停止读取

```dart
await IminRfid.stopReading();
```

### 监听标签流

```dart
StreamSubscription subscription = IminRfid.tagStream.listen((event) {
  if (event.isTag && event.tag != null) {
    final tag = event.tag!;
    print('EPC: ${tag.epc}');
    print('RSSI: ${tag.rssi} dBm');
    print('次数: ${tag.count}');
    print('PC: ${tag.pc}');
    print('TID: ${tag.tid}');
  } else if (event.isError) {
    print('错误: ${event.errorMessage}');
  }
});
```

### 监听连接流

```dart
StreamSubscription subscription = IminRfid.connectionStream.listen((connected) {
  print('已连接: $connected');
});
```

### 监听电池流

```dart
StreamSubscription subscription = IminRfid.batteryStream.listen((status) {
  print('电量: ${status.level}%');
  print('充电中: ${status.charging}');
});
```

### 获取电池电量

```dart
int level = await IminRfid.getBatteryLevel();
```

### 检查是否充电

```dart
bool charging = await IminRfid.isCharging();
```

### 清空标签

```dart
await IminRfid.clearTags();
```

## RfidTag 模型

```dart
class RfidTag {
  final String epc;         // 电子产品代码
  final int rssi;           // 信号强度（dBm）
  final int count;          // 读取次数
  final String? pc;         // 协议控制
  final String? tid;        // 标签 ID
  final int frequency;      // 频率（kHz）
  final int timestamp;      // 检测时间
}
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class RfidExample extends StatefulWidget {
  @override
  _RfidExampleState createState() => _RfidExampleState();
}

class _RfidExampleState extends State<RfidExample> {
  bool _isConnected = false;
  bool _isReading = false;
  int _batteryLevel = 0;
  List<RfidTag> _tags = [];
  StreamSubscription? _tagSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _listenToStreams();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _listenToStreams() {
    _tagSubscription = IminRfid.tagStream.listen((event) {
      if (event.isTag && event.tag != null) {
        setState(() {
          _tags.add(event.tag!);
        });
      }
    });

    _connectionSubscription = IminRfid.connectionStream.listen((connected) {
      setState(() => _isConnected = connected);
    });
  }

  Future<void> _connect() async {
    await IminRfid.connect();
  }

  Future<void> _startReading() async {
    await IminRfid.startReading();
    setState(() => _isReading = true);
  }

  Future<void> _stopReading() async {
    await IminRfid.stopReading();
    setState(() => _isReading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('已连接: $_isConnected'),
        Text('电量: $_batteryLevel%'),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('连接'),
        ),
        ElevatedButton(
          onPressed: _isConnected && !_isReading ? _startReading : null,
          child: Text('开始读取'),
        ),
        ElevatedButton(
          onPressed: _isReading ? _stopReading : null,
          child: Text('停止读取'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              final tag = _tags[index];
              return ListTile(
                title: Text(tag.epc),
                subtitle: Text('RSSI: ${tag.rssi} dBm, 次数: ${tag.count}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## 注意事项

- RFID 读取器必须通过蓝牙配对
- 连接时可获取电池状态
- 标签通过 EPC 去重
- RSSI 表示信号强度
- 不需要时停止读取以节省电量

## 支持设备

支持 RFID 读取器的 iMin 设备
