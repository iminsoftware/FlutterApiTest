# 设备信息模块

获取 iMin POS 设备的设备信息。

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

插件导出 `IminDevice` 类用于获取设备信息。

## 功能特性

- 获取设备型号
- 获取设备序列号
- 获取固件版本
- 获取硬件版本
- 获取系统信息

## API 参考

### 获取设备型号

```dart
String model = await IminDevice.getModel();
```

### 获取序列号

```dart
String serialNumber = await IminDevice.getSerialNumber();
```

### 获取固件版本

```dart
String firmwareVersion = await IminDevice.getFirmwareVersion();
```

### 获取硬件版本

```dart
String hardwareVersion = await IminDevice.getHardwareVersion();
```

### 获取所有设备信息

```dart
Map<String, String> info = await IminDevice.getAllInfo();
// 返回: {
//   model: String,
//   serialNumber: String,
//   firmwareVersion: String,
//   hardwareVersion: String,
//   androidVersion: String,
//   ...
// }
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class DeviceInfoExample extends StatefulWidget {
  @override
  _DeviceInfoExampleState createState() => _DeviceInfoExampleState();
}

class _DeviceInfoExampleState extends State<DeviceInfoExample> {
  String _model = '';
  String _serialNumber = '';
  String _firmwareVersion = '';
  Map<String, String> _allInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final model = await IminDevice.getModel();
    final serialNumber = await IminDevice.getSerialNumber();
    final firmwareVersion = await IminDevice.getFirmwareVersion();
    final allInfo = await IminDevice.getAllInfo();

    setState(() {
      _model = model;
      _serialNumber = serialNumber;
      _firmwareVersion = firmwareVersion;
      _allInfo = allInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('型号: $_model'),
        Text('序列号: $_serialNumber'),
        Text('固件: $_firmwareVersion'),
        Divider(),
        Text('所有信息:'),
        ..._allInfo.entries.map((e) => Text('${e.key}: ${e.value}')),
      ],
    );
  }
}
```

## 注意事项

- 设备信息为只读
- 序列号对每个设备是唯一的
- 固件版本格式可能因设备而异
- 某些信息可能在所有设备上不可用

## 支持设备

所有 iMin POS 设备
