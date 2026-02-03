# MSR 模块

iMin POS 设备的磁条卡读取器。

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

插件导出 `IminMsr` 类用于磁条卡读取操作。

## 功能特性

- 检查 MSR 可用性
- 读取磁条卡
- 支持 Track 1、2 和 3 数据

## API 参考

### 检查可用性

```dart
bool available = await IminMsr.isAvailable();
```

## 使用方法

MSR 模块通过标准 Android 输入法工作。刷卡时，数据会自动发送到焦点文本框。

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class MsrExample extends StatefulWidget {
  @override
  _MsrExampleState createState() => _MsrExampleState();
}

class _MsrExampleState extends State<MsrExample> {
  bool _isAvailable = false;
  final TextEditingController _msrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void dispose() {
    _msrController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final available = await IminMsr.isAvailable();
    setState(() => _isAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('MSR 可用: $_isAvailable'),
        TextField(
          controller: _msrController,
          decoration: InputDecoration(
            labelText: '在此刷卡',
            hintText: '卡片数据将显示在这里',
          ),
          maxLines: 3,
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              print('收到卡片数据: ${value.length} 个字符');
              // 处理卡片数据
            }
          },
        ),
        ElevatedButton(
          onPressed: () => _msrController.clear(),
          child: Text('清空'),
        ),
      ],
    );
  }
}
```

## 卡片数据格式

磁条卡通常包含：
- Track 1：字母数字数据（姓名、账号）
- Track 2：数字数据（账号、有效期）
- Track 3：附加数据（因卡类型而异）

数据格式取决于卡类型和编码标准。

## 注意事项

- MSR 数据作为键盘输入发送
- 必须将焦点放在文本框上才能接收数据
- 数据包含起始/结束标记和分隔符
- 根据卡片格式解析原始数据
- 安全处理敏感数据

## 支持设备

带内置磁条卡读取器的 iMin 设备
