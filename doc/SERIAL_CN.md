# 串口模块

iMin POS 设备的串口通信。

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

插件导出 `IminSerial` 类用于串口通信。

## 功能特性

- 打开/关闭串口
- 发送和接收数据
- 基于流的数据接收
- 支持多种波特率

## API 参考

### 打开串口

```dart
bool success = await IminSerial.open(
  path: '/dev/ttyS4',
  baudRate: 115200,
);
```

常用串口：
- `/dev/ttyS4` - 默认串口
- `/dev/ttyUSB0` - USB 串口适配器

常用波特率：9600、19200、38400、57600、115200

### 关闭串口

```dart
bool success = await IminSerial.close();
```

### 写入数据

```dart
Uint8List data = Uint8List.fromList([0x01, 0x02, 0x03]);
bool success = await IminSerial.write(data);
```

### 监听数据流

```dart
StreamSubscription subscription = IminSerial.dataStream.listen((event) {
  print('接收: ${event.data}');
  print('字节: ${event.bytes}');
});
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'dart:typed_data';

class SerialExample extends StatefulWidget {
  @override
  _SerialExampleState createState() => _SerialExampleState();
}

class _SerialExampleState extends State<SerialExample> {
  bool _isOpen = false;
  List<String> _receivedData = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isOpen) {
      IminSerial.close();
    }
    super.dispose();
  }

  void _listenToData() {
    _subscription = IminSerial.dataStream.listen((event) {
      setState(() {
        _receivedData.insert(0, event.data);
        if (_receivedData.length > 50) {
          _receivedData.removeLast();
        }
      });
    });
  }

  Future<void> _openPort() async {
    final success = await IminSerial.open(
      path: '/dev/ttyS4',
      baudRate: 115200,
    );
    setState(() => _isOpen = success);
  }

  Future<void> _closePort() async {
    await IminSerial.close();
    setState(() => _isOpen = false);
  }

  Future<void> _sendData(String text) async {
    if (!_isOpen) return;
    
    final bytes = Uint8List.fromList(text.codeUnits);
    await IminSerial.write(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('端口: ${_isOpen ? "已打开" : "已关闭"}'),
        ElevatedButton(
          onPressed: _isOpen ? null : _openPort,
          child: Text('打开端口'),
        ),
        ElevatedButton(
          onPressed: _isOpen ? _closePort : null,
          child: Text('关闭端口'),
        ),
        ElevatedButton(
          onPressed: _isOpen ? () => _sendData('你好') : null,
          child: Text('发送数据'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _receivedData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_receivedData[index]),
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

- 不使用时关闭端口
- 适当处理数据编码/解码
- 检查设备上的端口权限
- 为您的设备使用适当的波特率

## 支持设备

所有支持串口的 iMin POS 设备
