# 副屏显示模块

控制 iMin POS 设备的副屏显示功能。

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

插件导出 `IminDisplay` 类用于副屏控制。

## 功能特性

- 启用/禁用副屏
- 显示文本内容
- 显示图片
- 播放视频
- 清空显示

## API 参考

### 检查可用性

```dart
bool available = await IminDisplay.isAvailable();
```

### 启用副屏

```dart
bool success = await IminDisplay.enable();
```

### 禁用副屏

```dart
await IminDisplay.disable();
```

### 显示文本

```dart
await IminDisplay.showText('你好，Flutter！');
```

### 显示图片

```dart
await IminDisplay.showImage('assets/images/logo.png');
```

### 播放视频

```dart
await IminDisplay.playVideo('assets/videos/promo.mp4');
```

### 清空显示

```dart
await IminDisplay.clear();
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class DisplayExample extends StatefulWidget {
  @override
  _DisplayExampleState createState() => _DisplayExampleState();
}

class _DisplayExampleState extends State<DisplayExample> {
  bool _isAvailable = false;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkDisplay();
  }

  Future<void> _checkDisplay() async {
    final available = await IminDisplay.isAvailable();
    setState(() => _isAvailable = available);
  }

  Future<void> _toggleDisplay() async {
    if (_isEnabled) {
      await IminDisplay.disable();
      setState(() => _isEnabled = false);
    } else {
      final success = await IminDisplay.enable();
      setState(() => _isEnabled = success);
    }
  }

  Future<void> _showContent() async {
    await IminDisplay.showText('欢迎！');
    await Future.delayed(Duration(seconds: 2));
    await IminDisplay.showImage('assets/images/logo.png');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('副屏可用: $_isAvailable'),
        ElevatedButton(
          onPressed: _isAvailable ? _toggleDisplay : null,
          child: Text(_isEnabled ? '禁用' : '启用'),
        ),
        ElevatedButton(
          onPressed: _isEnabled ? _showContent : null,
          child: Text('显示内容'),
        ),
      ],
    );
  }
}
```

## 注意事项

- 显示内容前必须先启用副屏
- 支持的图片格式：PNG、JPG
- 支持的视频格式：MP4
- 资源文件必须在 `pubspec.yaml` 中声明

## 支持设备

带副屏的 iMin D4、M2-Pro、Swan、Swift 系列设备
