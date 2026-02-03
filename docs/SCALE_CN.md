# 电子秤模块

iMin POS 设备的电子秤集成（Android 13+）。

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

插件导出 `IminScaleNew` 类用于电子秤操作（Android 13+）。

## 功能特性

- 连接秤服务
- 实时重量数据流
- 清零和去皮操作
- 价格计算
- 单位转换
- 设备信息和诊断

## API 参考

### 连接服务

```dart
bool success = await IminScaleNew.connectService();
```

### 获取服务版本

```dart
String version = await IminScaleNew.getServiceVersion();
```

### 获取固件版本

```dart
String version = await IminScaleNew.getFirmwareVersion();
```

### 开始获取数据

```dart
bool success = await IminScaleNew.getData();
```

### 停止获取数据

```dart
bool success = await IminScaleNew.cancelGetData();
```

### 监听秤事件

```dart
StreamSubscription<ScaleEvent> subscription = IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) {
    final data = event.data as ScaleWeightData;
    print('净重: ${data.net} kg');
    print('皮重: ${data.tare} kg');
    print('稳定: ${data.isStable}');
  } else if (event.isStatus) {
    final status = event.data as ScaleStatusData;
    print('过载: ${status.overload}');
    print('过轻: ${status.isLightWeight}');
  } else if (event.isPrice) {
    final price = event.data as ScalePriceData;
    print('单价: ${price.unitPrice}');
    print('总价: ${price.totalPrice}');
  } else if (event.isError) {
    print('错误码: ${event.data}');
  } else if (event.isConnection) {
    final conn = event.data as ScaleConnectionData;
    print('已连接: ${conn.connected}');
  }
});
```

### 清零操作

```dart
await IminScaleNew.zero();
```

### 去皮操作

```dart
await IminScaleNew.tare();
```

### 数字去皮

```dart
await IminScaleNew.digitalTare(100); // 去皮 100g
```

### 设置单价

```dart
await IminScaleNew.setUnitPrice('9.99');
```

### 设置单位

```dart
await IminScaleNew.setUnit(ScaleUnit.kg);
```

可用单位：
- `ScaleUnit.g` - 克
- `ScaleUnit.g100` - 100克
- `ScaleUnit.g500` - 500克
- `ScaleUnit.kg` - 千克

### 设备操作

```dart
// 读取加速度数据
List<int> accelData = await IminScaleNew.readAcceleData();

// 读取铅封状态
int sealState = await IminScaleNew.readSealState();

// 获取标定状态
int calStatus = await IminScaleNew.getCalStatus();

// 获取标定信息
List<List<int>> calInfo = await IminScaleNew.getCalInfo();

// 重启秤
await IminScaleNew.restart();
```

## 数据模型

### ScaleWeightData

```dart
class ScaleWeightData {
  final double net;        // 净重（千克）
  final double tare;       // 皮重（千克）
  final bool isStable;     // 重量稳定
}
```

### ScaleStatusData

```dart
class ScaleStatusData {
  final bool overload;         // 秤过载
  final bool isLightWeight;    // 重量过轻
  final bool clearZeroErr;     // 清零错误
  final bool calibrationErr;   // 标定错误
}
```

### ScalePriceData

```dart
class ScalePriceData {
  final String unitPrice;    // 单价
  final String totalPrice;   // 总价
  final String unitName;     // 单位名称
}
```

## 示例代码

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class ScaleExample extends StatefulWidget {
  @override
  _ScaleExampleState createState() => _ScaleExampleState();
}

class _ScaleExampleState extends State<ScaleExample> {
  bool _isConnected = false;
  bool _isGettingData = false;
  ScaleWeightData? _currentWeight;
  StreamSubscription<ScaleEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
    _connectService();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    IminScaleNew.cancelGetData();
    super.dispose();
  }

  void _listenToEvents() {
    _subscription = IminScaleNew.eventStream.listen((event) {
      if (event.isWeight) {
        setState(() => _currentWeight = event.data as ScaleWeightData);
      } else if (event.isConnection) {
        final conn = event.data as ScaleConnectionData;
        setState(() => _isConnected = conn.connected);
      }
    });
  }

  Future<void> _connectService() async {
    final success = await IminScaleNew.connectService();
    if (success) {
      await Future.delayed(Duration(milliseconds: 500));
      _startGetData();
    }
  }

  Future<void> _startGetData() async {
    final success = await IminScaleNew.getData();
    setState(() => _isGettingData = success);
  }

  Future<void> _stopGetData() async {
    await IminScaleNew.cancelGetData();
    setState(() => _isGettingData = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('已连接: $_isConnected'),
        Text('获取数据中: $_isGettingData'),
        if (_currentWeight != null) ...[
          Text('净重: ${_currentWeight!.net.toStringAsFixed(3)} kg'),
          Text('皮重: ${_currentWeight!.tare.toStringAsFixed(3)} kg'),
          Text('稳定: ${_currentWeight!.isStable ? "✓" : "~"}'),
        ],
        ElevatedButton(
          onPressed: _isConnected ? () => IminScaleNew.zero() : null,
          child: Text('清零'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? () => IminScaleNew.tare() : null,
          child: Text('去皮'),
        ),
      ],
    );
  }
}
```

## 注意事项

- 需要 Android 13 或更高版本
- 操作前先连接服务
- 激活时重量数据持续流式传输
- 不需要时停止获取数据
- 适当处理错误

## 支持设备

支持电子秤的 iMin 设备（Android 13+）
