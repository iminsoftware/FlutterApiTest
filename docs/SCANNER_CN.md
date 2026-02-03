# 扫描器模块

iMin POS 设备上的条码和二维码扫描。

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

插件导出 `IminScanner` 类用于条码扫描。

## 功能特性

- 开始/停止监听扫描
- 基于流的扫描结果
- 自定义广播配置
- 连接状态监控

## API 参考

### 检查连接

```dart
bool connected = await IminScanner.isConnected();
```

### 配置扫描器

```dart
await IminScanner.configure(
  action: 'com.imin.scanner.api.RESULT_ACTION',
  dataKey: 'decode_data_str',
  byteDataKey: 'decode_data',
);
```

### 开始监听

```dart
bool started = await IminScanner.startListening();
```

### 停止监听

```dart
bool stopped = await IminScanner.stopListening();
```

### 监听扫描流

```dart
StreamSubscription<ScannerEvent> subscription = IminScanner.scanStream.listen((event) {
  if (event is ScanResult) {
    print('数据: ${event.data}');
    print('类型: ${event.labelType}');
    print('时间: ${event.timestamp}');
  } else if (event is ScannerConnected) {
    print('扫描器已连接');
  } else if (event is ScannerDisconnected) {
    print('扫描器已断开');
  } else if (event is ScannerConnectionStatus) {
    print('已连接: ${event.connected}');
  }
});
```

## 扫描器事件

```dart
// 扫描结果
class ScanResult extends ScannerEvent {
  final String data;
  final String labelType;
  final DateTime timestamp;
}

// 连接事件
class ScannerConnected extends ScannerEvent {}
class ScannerDisconnected extends ScannerEvent {}
class ScannerConnectionStatus extends ScannerEvent {
  final bool connected;
}
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class ScannerExample extends StatefulWidget {
  @override
  _ScannerExampleState createState() => _ScannerExampleState();
}

class _ScannerExampleState extends State<ScannerExample> {
  bool _isListening = false;
  bool _isConnected = false;
  List<ScanResult> _scanHistory = [];
  StreamSubscription<ScannerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isListening) {
      IminScanner.stopListening();
    }
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connected = await IminScanner.isConnected();
    setState(() => _isConnected = connected);
  }

  Future<void> _startListening() async {
    final started = await IminScanner.startListening();
    if (started) {
      setState(() => _isListening = true);
      
      _subscription = IminScanner.scanStream.listen((event) {
        if (event is ScanResult) {
          setState(() {
            _scanHistory.insert(0, event);
            if (_scanHistory.length > 50) {
              _scanHistory.removeLast();
            }
          });
        } else if (event is ScannerConnected) {
          setState(() => _isConnected = true);
        } else if (event is ScannerDisconnected) {
          setState(() => _isConnected = false);
        }
      });
    }
  }

  Future<void> _stopListening() async {
    await _subscription?.cancel();
    final stopped = await IminScanner.stopListening();
    if (stopped) {
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('已连接: $_isConnected'),
        Text('监听中: $_isListening'),
        ElevatedButton(
          onPressed: _isListening ? null : _startListening,
          child: Text('开始监听'),
        ),
        ElevatedButton(
          onPressed: _isListening ? _stopListening : null,
          child: Text('停止监听'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              final scan = _scanHistory[index];
              return ListTile(
                title: Text(scan.data),
                subtitle: Text('类型: ${scan.labelType}'),
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

- 监听前扫描器必须已连接
- 自定义配置是可选的
- 保持监听活动以接收扫描结果
- 不需要时停止监听以节省电量

## 支持设备

所有带内置或外置扫描器的 iMin POS 设备
