# 数码管显示模块

iMin POS 设备的数码管显示控制。

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

插件导出 `IminSegment` 类用于数码管显示控制。

## 功能特性

- 查找并连接数码管显示器
- 发送数据到显示器
- 清空显示
- 全显示测试
- 左/右对齐

## API 参考

### 查找设备

```dart
Map<String, dynamic> result = await IminSegment.findDevice();
// 返回: {found: bool, productId: int, vendorId: int, deviceName: String}
```

### 请求权限

```dart
bool granted = await IminSegment.requestPermission();
```

### 连接

```dart
bool success = await IminSegment.connect();
```

### 发送数据

```dart
await IminSegment.sendData('12345', align: 'right');
```

对齐选项：
- `'right'` - 右对齐（默认）
- `'left'` - 左对齐

### 清空显示

```dart
await IminSegment.clear();
```

### 全显示测试

```dart
await IminSegment.full();
```

### 断开连接

```dart
await IminSegment.disconnect();
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class SegmentExample extends StatefulWidget {
  @override
  _SegmentExampleState createState() => _SegmentExampleState();
}

class _SegmentExampleState extends State<SegmentExample> {
  bool _isConnected = false;
  String _deviceInfo = '未找到设备';

  Future<void> _findDevice() async {
    final result = await IminSegment.findDevice();
    setState(() {
      if (result['found'] == true) {
        _deviceInfo = '找到设备\n'
            'PID: ${result['productId']}\n'
            'VID: ${result['vendorId']}\n'
            '名称: ${result['deviceName']}';
      } else {
        _deviceInfo = '未找到数码管设备';
      }
    });
  }

  Future<void> _connect() async {
    final granted = await IminSegment.requestPermission();
    if (granted) {
      final success = await IminSegment.connect();
      setState(() => _isConnected = success);
    }
  }

  Future<void> _sendData(String data) async {
    if (!_isConnected) return;
    await IminSegment.sendData(data, align: 'right');
  }

  Future<void> _clear() async {
    if (!_isConnected) return;
    await IminSegment.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_deviceInfo),
        ElevatedButton(
          onPressed: _findDevice,
          child: Text('查找设备'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('连接'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? () => _sendData('12345') : null,
          child: Text('发送数据'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _clear : null,
          child: Text('清空'),
        ),
      ],
    );
  }
}
```

## 注意事项

- 连接前需要 USB 权限
- 支持数字和字母
- 最多 9 个字符
- 设备必须通过 USB 物理连接

## 支持设备

支持 USB 数码管显示的 iMin 设备
