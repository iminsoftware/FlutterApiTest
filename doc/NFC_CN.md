# NFC 模块

读取 iMin POS 设备上的 NFC 卡片和标签。

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

插件导出 `IminNfc` 类用于 NFC 操作。

## 功能特性

- 检查 NFC 可用性和状态
- 读取 NFC 标签
- 基于流的标签检测
- 打开 NFC 设置

## API 参考

### 检查可用性

```dart
bool available = await IminNfc.isAvailable();
```

### 检查是否启用

```dart
bool enabled = await IminNfc.isEnabled();
```

### 监听 NFC 标签

```dart
StreamSubscription<NfcTag> subscription = IminNfc.tagStream.listen((tag) {
  print('NFC ID: ${tag.id}');
  print('格式化 ID: ${tag.formattedId}');
  print('内容: ${tag.content}');
  print('技术类型: ${tag.technology}');
  print('时间戳: ${tag.timestamp}');
});
```

### 打开 NFC 设置

```dart
await IminNfc.openSettings();
```

## NfcTag 模型

```dart
class NfcTag {
  final String id;              // 原始十六进制 ID
  final String formattedId;     // 格式化 ID（例如："12:34:56:78"）
  final String content;         // 标签内容（如果可用）
  final String technology;      // NFC 技术类型
  final DateTime timestamp;     // 检测时间
}
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class NfcExample extends StatefulWidget {
  @override
  _NfcExampleState createState() => _NfcExampleState();
}

class _NfcExampleState extends State<NfcExample> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  NfcTag? _currentTag;
  StreamSubscription<NfcTag>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkNfc();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNfc() async {
    final available = await IminNfc.isAvailable();
    final enabled = await IminNfc.isEnabled();
    setState(() {
      _isAvailable = available;
      _isEnabled = enabled;
    });
  }

  void _startListening() {
    _subscription = IminNfc.tagStream.listen((tag) {
      setState(() => _currentTag = tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('可用: $_isAvailable'),
        Text('已启用: $_isEnabled'),
        if (_currentTag != null) ...[
          Text('ID: ${_currentTag!.formattedId}'),
          Text('内容: ${_currentTag!.content}'),
        ],
        if (!_isEnabled)
          ElevatedButton(
            onPressed: () => IminNfc.openSettings(),
            child: Text('打开 NFC 设置'),
          ),
      ],
    );
  }
}
```

## 注意事项

- 必须在设备设置中启用 NFC
- 保持监听活动以检测标签
- 启用 NFC 后标签检测是自动的
- 某些标签可能没有可读内容

## 支持设备

带 NFC 读卡器功能的 iMin 设备
