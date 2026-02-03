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
| 📸 Camera | Camera-based scanning |
| 📡 RFID | RFID tag operations |
| 📱 Device | Device information |

## Supported Devices

iMin D4, M2-Pro, Swan, Swift, Crane, Lark, Falcon series

## Installation

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Scanner
IminScanner.startScan();
IminScanner.scanStream.listen((code) => print('Scanned: $code'));

// NFC
IminNfc.startNfc();
IminNfc.nfcStream.listen((tag) => print('NFC: ${tag.id}'));

// Electronic Scale
await IminScaleNew.connectService();
await IminScaleNew.getData();
IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) print('Weight: ${event.data.net}kg');
});
```

## Documentation

### 📖 Complete Guides

- [Display Module](docs/DISPLAY_EN.md) - Secondary display control
- [Cashbox Module](docs/CASHBOX_EN.md) - Cash drawer operations
- [Light Module](docs/LIGHT_EN.md) - LED indicator control
- [NFC Module](docs/NFC_EN.md) - NFC card reading
- [Scanner Module](docs/SCANNER_EN.md) - Barcode scanning
- [MSR Module](docs/MSR_EN.md) - Magnetic stripe reader
- [Scale Module](docs/SCALE_EN.md) - Electronic scale
- [Serial Module](docs/SERIAL_EN.md) - Serial communication
- [Segment Module](docs/SEGMENT_EN.md) - Digital display
- [Floating Window Module](docs/FLOATING_WINDOW_EN.md) - Overlay window
- [Camera Module](docs/CAMERA_EN.md) - Camera scanning
- [RFID Module](docs/RFID_EN.md) - RFID operations
- [Device Module](docs/DEVICE_EN.md) - Device information

## Example App

See [example](example/) directory for complete demo application.

## Requirements

- Flutter >=3.3.0
- Dart >=3.0.0
- Android minSdkVersion 21
- iMin POS device

## Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

## Support

- 📧 [GitHub Issues](https://github.com/iminsoftware/FlutterApiTest/issues)
- 📖 [Documentation](https://pub.dev/packages/imin_hardware_plugin)
- 🌐 [Website](https://www.imin.sg)

## License

MIT License - see [LICENSE](LICENSE)

---

Made with ❤️ by [iMin Technology](https://www.imin.sg)
