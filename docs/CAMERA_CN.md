# 相机模块

iMin POS 设备的基于相机的条码和二维码扫描。

## 安装

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
  permission_handler: ^11.0.0  # 用于相机权限
```

然后运行：

```bash
flutter pub get
```

## 导入

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
```

插件导出 `CameraScanApi` 类用于基于相机的扫描。

## 功能特性

- 使用默认设置快速扫描
- 仅扫描二维码
- 仅扫描条码
- 扫描所有格式
- 闪光灯控制
- 超时配置
- 自定义格式选择

## API 参考

### 快速扫描

```dart
String code = await CameraScanApi.scanQuick();
```

### 仅扫描二维码

```dart
String code = await CameraScanApi.scanQRCode();
```

### 仅扫描条码

```dart
String code = await CameraScanApi.scanBarcode();
```

### 扫描所有格式

```dart
Map<String, String> result = await CameraScanApi.scanAll();
// 返回: {code: String, format: String}
```

### 自定义扫描

```dart
Map<String, String> result = await CameraScanApi.scan(
  formats: [BarcodeFormat.qrCode, BarcodeFormat.code128],
  useFlash: true,
  timeout: 10000,  // 10 秒
  prompt: '扫描您的代码',
);
```

### 条码格式

```dart
enum BarcodeFormat {
  qrCode,
  code128,
  code39,
  code93,
  ean8,
  ean13,
  upcA,
  upcE,
  dataMatrix,
  pdf417,
  aztec,
  // ... 更多格式
}
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraExample extends StatefulWidget {
  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  String _lastResult = '';
  String _lastFormat = '';

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    await Permission.camera.request();
  }

  Future<void> _scanQuick() async {
    try {
      final code = await CameraScanApi.scanQuick();
      setState(() {
        _lastResult = code;
        _lastFormat = 'DEFAULT';
      });
    } catch (e) {
      print('扫描错误: $e');
    }
  }

  Future<void> _scanQRCode() async {
    try {
      final code = await CameraScanApi.scanQRCode();
      setState(() {
        _lastResult = code;
        _lastFormat = 'QR_CODE';
      });
    } catch (e) {
      print('扫描错误: $e');
    }
  }

  Future<void> _scanWithFlash() async {
    try {
      final result = await CameraScanApi.scan(
        useFlash: true,
        prompt: '使用闪光灯扫描',
      );
      setState(() {
        _lastResult = result['code']!;
        _lastFormat = result['format']!;
      });
    } catch (e) {
      print('扫描错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('最后结果: $_lastResult'),
        Text('格式: $_lastFormat'),
        ElevatedButton(
          onPressed: _scanQuick,
          child: Text('快速扫描'),
        ),
        ElevatedButton(
          onPressed: _scanQRCode,
          child: Text('扫描二维码'),
        ),
        ElevatedButton(
          onPressed: _scanWithFlash,
          child: Text('使用闪光灯扫描'),
        ),
      ],
    );
  }
}
```

## 注意事项

- 需要相机权限
- 扫描会打开全屏相机视图
- 用户可以按返回键取消扫描
- 如果未检测到代码，超时会导致扫描失败
- 并非所有设备都支持闪光灯

## 支持设备

所有带相机的 iMin POS 设备
