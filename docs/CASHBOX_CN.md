# 钱箱模块

控制 iMin POS 设备的钱箱操作。

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

插件导出 `IminCashBox` 类用于钱箱控制。

## 功能特性

- 打开钱箱
- 检查钱箱状态
- 配置电压设置

## API 参考

### 打开钱箱

```dart
bool success = await IminCashBox.open();
```

### 获取状态

```dart
bool isOpen = await IminCashBox.getStatus();
```

返回 `true` 表示钱箱打开，`false` 表示关闭。

### 设置电压

```dart
bool success = await IminCashBox.setVoltage(CashBoxVoltage.v12);
```

可用电压选项：
- `CashBoxVoltage.v9` - 9V
- `CashBoxVoltage.v12` - 12V（默认）
- `CashBoxVoltage.v24` - 24V

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class CashBoxExample extends StatefulWidget {
  @override
  _CashBoxExampleState createState() => _CashBoxExampleState();
}

class _CashBoxExampleState extends State<CashBoxExample> {
  bool _isOpen = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final isOpen = await IminCashBox.getStatus();
      setState(() => _isOpen = isOpen);
    } catch (e) {
      print('检查状态错误: $e');
    }
  }

  Future<void> _openDrawer() async {
    try {
      final success = await IminCashBox.open();
      if (success) {
        print('钱箱已打开');
      }
    } catch (e) {
      print('打开钱箱错误: $e');
    }
  }

  Future<void> _setVoltage(CashBoxVoltage voltage) async {
    try {
      final success = await IminCashBox.setVoltage(voltage);
      if (success) {
        print('电压已设置为 ${voltage.value}V');
      }
    } catch (e) {
      print('设置电压错误: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('状态: ${_isOpen ? "打开" : "关闭"}'),
        ElevatedButton(
          onPressed: _openDrawer,
          child: Text('打开钱箱'),
        ),
        ElevatedButton(
          onPressed: () => _setVoltage(CashBoxVoltage.v12),
          child: Text('设置 12V'),
        ),
      ],
    );
  }
}
```

## 注意事项

- 电压必须与钱箱规格匹配
- 建议使用状态轮询实现实时更新
- 打开钱箱会触发短暂的脉冲信号

## 支持设备

所有带钱箱接口的 iMin POS 设备
