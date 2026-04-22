# 相机模块

iMin POS 设备的摄像头条码/二维码扫描功能。

支持两种扫码引擎：
- **ZXing**（默认）— 本地解码，兼容性最好
- **ML Kit**（可选）— 任意角度识别、多码同扫、速度更快

## 安装

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
  permission_handler: ^11.0.0  # 相机权限
```

## 导入

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
```

## API 参考

### 单码扫描

```dart
// 快速扫描（默认格式：QR_CODE, UPC_A, EAN_13, CODE_128）
String code = await CameraScanApi.scanQuick();

// 仅扫描二维码
String code = await CameraScanApi.scanQRCode();

// 仅扫描条码（所有一维码格式）
String code = await CameraScanApi.scanBarcode();

// 扫描所有格式，返回完整结果
Map<String, dynamic> result = await CameraScanApi.scanAll();
// result = {'code': '...', 'format': 'QR_CODE'}

// 自定义扫描
Map<String, dynamic> result = await CameraScanApi.scan(
  formats: ['QR_CODE', 'CODE_128'],
  useFlash: true,
  beepEnabled: true,
  timeout: 10000,  // 10秒，0=不超时
);
```

### 多码同扫 / 多角度扫码（ML Kit）

支持多条码同时识别和任意角度识别。ML Kit 不可用时自动降级为 ZXing。

```dart
// 默认多码同扫
List<Map<String, dynamic>> results = await CameraScanApi.scanMulti();

// 仅多角度识别（单条码，任意方向）
final results = await CameraScanApi.scanMulti(const MultiScanOptions(
  supportMultiAngle: true,
  supportMultiBarcode: false,
  fullAreaScan: true,
));

// 完整自定义配置
final results = await CameraScanApi.scanMulti(const MultiScanOptions(
  formats: ['QR_CODE', 'EAN_13', 'CODE_128'],
  supportMultiBarcode: true,
  supportMultiAngle: true,
  decodeEngine: DecodeEngine.mlkit,
  fullAreaScan: true,
  areaRectRatio: 0.9,
  useFlash: false,
  beepEnabled: true,
  timeout: 30000,
));
```

### ML Kit 可用性检测

```dart
bool available = await CameraScanApi.isMLKitAvailable();
```

### MultiScanOptions 参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| formats | List\<String\>? | 全部 | 要识别的条码格式 |
| useFlash | bool | false | 是否开启闪光灯 |
| beepEnabled | bool | true | 成功时播放提示音 |
| timeout | int | 0 | 超时时间(ms)，0=不超时 |
| supportMultiBarcode | bool | true | 是否多条码同时识别 |
| supportMultiAngle | bool | true | 是否多角度识别 |
| decodeEngine | int | 1 (MLKit) | 0=ZXing, 1=MLKit |
| fullAreaScan | bool | true | 是否全区域扫码 |
| areaRectRatio | double | 0.8 | 识别区域比例 (0.5~1.0) |

### 支持的码制

**一维码 (12种):** CODABAR, CODE_39, CODE_93, CODE_128, EAN_8, EAN_13, ITF, RSS_14, RSS_EXPANDED, UPC_A, UPC_E, UPC_EAN_EXTENSION

**二维码 (5种):** QR_CODE, DATA_MATRIX, PDF_417, AZTEC, MAXICODE

## 示例代码

```dart
class ScanExample extends StatelessWidget {
  Future<void> _scan() async {
    // 先请求相机权限
    await Permission.camera.request();

    // 单码扫描
    try {
      final result = await CameraScanApi.scanAll();
      print('${result['format']}: ${result['code']}');
    } catch (e) {
      print('扫描取消或失败: $e');
    }

    // 多码同扫
    try {
      final results = await CameraScanApi.scanMulti();
      for (final r in results) {
        print('${r['format']}: ${r['code']}');
      }
    } catch (e) {
      print('多码扫描失败: $e');
    }
  }
}
```

## 注意事项

- 需要相机权限（建议使用 `permission_handler`）
- 扫描会打开全屏相机界面
- 用户可按返回键取消扫描
- ML Kit 需要 Google Play Services，无 GMS 的设备会自动降级为 ZXing
- 所有带摄像头的 iMin POS 设备均支持
