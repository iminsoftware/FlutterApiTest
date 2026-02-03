# 悬浮窗模块

在 iMin POS 设备上显示覆盖层悬浮窗口。

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

插件导出 `FloatingWindowApi` 类用于悬浮窗操作。

## 功能特性

- 显示/隐藏悬浮窗
- 更新窗口文本
- 设置窗口位置
- 检查窗口状态

## API 参考

### 显示悬浮窗

```dart
await FloatingWindowApi.show();
```

### 隐藏悬浮窗

```dart
await FloatingWindowApi.hide();
```

### 检查是否显示

```dart
bool isShowing = await FloatingWindowApi.isShowing();
```

### 更新文本

```dart
await FloatingWindowApi.updateText('新文本');
```

### 设置位置

```dart
await FloatingWindowApi.setPosition(100, 200);  // x, y 坐标
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class FloatingWindowExample extends StatefulWidget {
  @override
  _FloatingWindowExampleState createState() => _FloatingWindowExampleState();
}

class _FloatingWindowExampleState extends State<FloatingWindowExample> {
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final isShowing = await FloatingWindowApi.isShowing();
    setState(() => _isShowing = isShowing);
  }

  Future<void> _showWindow() async {
    await FloatingWindowApi.show();
    await _checkStatus();
  }

  Future<void> _hideWindow() async {
    await FloatingWindowApi.hide();
    await _checkStatus();
  }

  Future<void> _updateText(String text) async {
    await FloatingWindowApi.updateText(text);
  }

  Future<void> _setPosition(int x, int y) async {
    await FloatingWindowApi.setPosition(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('状态: ${_isShowing ? "显示中" : "已隐藏"}'),
        ElevatedButton(
          onPressed: _showWindow,
          child: Text('显示窗口'),
        ),
        ElevatedButton(
          onPressed: _hideWindow,
          child: Text('隐藏窗口'),
        ),
        ElevatedButton(
          onPressed: () => _updateText('你好！'),
          child: Text('更新文本'),
        ),
        ElevatedButton(
          onPressed: () => _setPosition(100, 200),
          child: Text('设置位置'),
        ),
      ],
    );
  }
}
```

## 注意事项

- Android 6.0+ 需要"在其他应用上层显示"权限
- 窗口在应用屏幕间持续存在
- 位置以屏幕像素为单位
- 不需要时隐藏窗口

## 权限设置

在 `AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

运行时请求权限：

```dart
import 'package:permission_handler/permission_handler.dart';

await Permission.systemAlertWindow.request();
```

## 支持设备

所有运行 Android 6.0+ 的 iMin POS 设备
