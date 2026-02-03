# LED 灯模块

控制 iMin POS 设备的 LED 指示灯。

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

插件导出 `IminLight` 类用于 LED 灯控制。

## 功能特性

- 连接/断开灯光设备
- 打开绿灯
- 打开红灯
- 关闭灯光

## API 参考

### 连接设备

```dart
bool success = await IminLight.connect();
```

### 打开绿灯

```dart
bool success = await IminLight.turnOnGreen();
```

### 打开红灯

```dart
bool success = await IminLight.turnOnRed();
```

### 关闭灯光

```dart
bool success = await IminLight.turnOff();
```

### 断开设备

```dart
bool success = await IminLight.disconnect();
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class LightExample extends StatefulWidget {
  @override
  _LightExampleState createState() => _LightExampleState();
}

class _LightExampleState extends State<LightExample> {
  bool _isConnected = false;
  LightColor _currentLight = LightColor.off;

  Future<void> _connect() async {
    final success = await IminLight.connect();
    setState(() => _isConnected = success);
  }

  Future<void> _turnOnGreen() async {
    final success = await IminLight.turnOnGreen();
    if (success) {
      setState(() => _currentLight = LightColor.green);
    }
  }

  Future<void> _turnOnRed() async {
    final success = await IminLight.turnOnRed();
    if (success) {
      setState(() => _currentLight = LightColor.red);
    }
  }

  Future<void> _turnOff() async {
    final success = await IminLight.turnOff();
    if (success) {
      setState(() => _currentLight = LightColor.off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('已连接: $_isConnected'),
        Text('当前状态: $_currentLight'),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('连接'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOnGreen : null,
          child: Text('绿灯'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOnRed : null,
          child: Text('红灯'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOff : null,
          child: Text('关闭'),
        ),
      ],
    );
  }
}

enum LightColor { off, green, red }
```

## 注意事项

- 控制灯光前必须先连接设备
- 同一时间只能有一个灯亮起
- 使用完毕后断开连接以释放资源

## 支持设备

带 LED 指示灯的 iMin 设备
