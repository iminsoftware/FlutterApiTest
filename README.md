# iMin Hardware Plugin

[![pub package](https://img.shields.io/pub/v/imin_hardware_plugin.svg)](https://pub.dev/packages/imin_hardware_plugin)
[![GitHub](https://img.shields.io/github/stars/iminsoftware/FlutterApiTest?style=social)](https://github.com/iminsoftware/FlutterApiTest)

[English](README.md) | [中文文档](README_CN.md)

A comprehensive Flutter plugin for controlling iMin POS device hardware features.

## Features

| Module | Description |
|--------|-------------|
| 📺 Display | Secondary display control |
| 💰 Cashbox | Cash drawer control |
| 💡 Light | LED indicator lights |
| 💳 NFC | NFC card reading |
| 📷 Scanner | Barcode/QR code scanner |
| 💳 MSR | Magnetic stripe reader |
| ⚖️ Scale | Electronic scale (Android 13+) |
| 🔌 Serial | Serial port communication |
| 🔢 Segment | Digital tube display |
| 🪟 Floating Window | Overlay window |
| 📸 Camera | Camera scanning (ZXing + ML Kit) |
| 📡 RFID | RFID tag operations |
| 📱 Device | Device information |

## Supported Devices

iMin D4, M2-Pro, Swan, Swift, Crane, Lark, Falcon series

## Installation

### From pub.dev

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

### From Git

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Camera scan (single barcode)
final result = await CameraScanApi.scanAll();
print('Code: ${result['code']}, Format: ${result['format']}');

// Camera scan (multi-barcode / multi-angle, ML Kit)
final results = await CameraScanApi.scanMulti();
for (final item in results) {
  print('Code: ${item['code']}, Format: ${item['format']}');
}

// Check ML Kit availability
final mlkitAvailable = await CameraScanApi.isMLKitAvailable();

// Hardware scanner (built-in scanner head)
IminScanner.scanStream.listen((event) => print('Scanned: ${event.data}'));
await IminScanner.startListening();

// NFC
IminNfc.tagStream.listen((tag) => print('NFC: ${tag['id']}'));

// Electronic Scale (Android 13+)
await IminScaleNew.connectService();
await IminScaleNew.getData();
```

## Camera Scan API

### Single Scan (ZXing)

```dart
// Quick scan with default formats
String code = await CameraScanApi.scanQuick();

// Scan QR code only
String code = await CameraScanApi.scanQRCode();

// Scan all formats with full result
Map<String, dynamic> result = await CameraScanApi.scanAll();

// Custom scan
Map<String, dynamic> result = await CameraScanApi.scan(
  formats: ['QR_CODE', 'EAN_13', 'CODE_128'],
  useFlash: true,
  beepEnabled: true,
  timeout: 10000,
);
```

### Multi Scan (ML Kit + ZXing)

Supports multi-barcode recognition and any-angle scanning. Auto-fallback to ZXing if ML Kit is unavailable.

```dart
// Default multi scan
List<Map<String, dynamic>> results = await CameraScanApi.scanMulti();

// Multi-angle scan (single barcode, any orientation)
final results = await CameraScanApi.scanMulti(const MultiScanOptions(
  supportMultiAngle: true,
  supportMultiBarcode: false,
));

// Full custom configuration
final results = await CameraScanApi.scanMulti(const MultiScanOptions(
  formats: ['QR_CODE', 'EAN_13', 'CODE_128'],
  supportMultiBarcode: true,
  supportMultiAngle: true,
  decodeEngine: DecodeEngine.mlkit,  // 0=ZXing, 1=MLKit
  fullAreaScan: true,
  areaRectRatio: 0.9,
  useFlash: false,
  beepEnabled: true,
  timeout: 30000,
));

// Check ML Kit availability
bool available = await CameraScanApi.isMLKitAvailable();
```

## Documentation

### Complete API Guides

- [Display Module](doc/DISPLAY_EN.md) - Secondary display control
- [Cashbox Module](doc/CASHBOX_EN.md) - Cash drawer operations
- [Light Module](doc/LIGHT_EN.md) - LED indicator control
- [NFC Module](doc/NFC_EN.md) - NFC card reading
- [Scanner Module](doc/SCANNER_EN.md) - Hardware barcode scanning
- [MSR Module](doc/MSR_EN.md) - Magnetic stripe reader
- [Scale Module](doc/SCALE_EN.md) - Electronic scale
- [Serial Module](doc/SERIAL_EN.md) - Serial communication
- [Segment Module](doc/SEGMENT_EN.md) - Digital display
- [Floating Window Module](doc/FLOATING_WINDOW_EN.md) - Overlay window
- [Camera Module](doc/CAMERA_EN.md) - Camera scanning
- [RFID Module](doc/RFID_EN.md) - RFID operations
- [Device Module](doc/DEVICE_EN.md) - Device information

## Example App

See [example](example/) directory for complete demo application with all hardware features.

## Requirements

- Flutter >=3.3.0
- Dart >=3.0.0
- Android minSdkVersion 21
- iMin POS device

## Permissions

Add to your app's `AndroidManifest.xml` as needed:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Support

- 📧 [GitHub Issues](https://github.com/iminsoftware/FlutterApiTest/issues)
- 🌐 [iMin Website](https://www.imin.sg)

## License

BSD-3-Clause License - see [LICENSE](LICENSE)
