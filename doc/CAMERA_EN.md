# Camera Module

Camera-based barcode and QR code scanning for iMin POS devices.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
  permission_handler: ^11.0.0  # For camera permission
```

Then run:

```bash
flutter pub get
```

## Import

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
```

The plugin exports `CameraScanApi` class for camera-based scanning.

## Features

- Quick scan with default settings
- QR code only scanning
- Barcode only scanning
- All formats scanning
- Flash control
- Timeout configuration
- Custom format selection

## API Reference

### Quick Scan

```dart
String code = await CameraScanApi.scanQuick();
```

### Scan QR Code Only

```dart
String code = await CameraScanApi.scanQRCode();
```

### Scan Barcode Only

```dart
String code = await CameraScanApi.scanBarcode();
```

### Scan All Formats

```dart
Map<String, String> result = await CameraScanApi.scanAll();
// Returns: {code: String, format: String}
```

### Custom Scan

```dart
Map<String, String> result = await CameraScanApi.scan(
  formats: [BarcodeFormat.qrCode, BarcodeFormat.code128],
  useFlash: true,
  timeout: 10000,  // 10 seconds
  prompt: 'Scan your code',
);
```

### Barcode Formats

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
  // ... more formats
}
```

## Example

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
      print('Scan error: $e');
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
      print('Scan error: $e');
    }
  }

  Future<void> _scanWithFlash() async {
    try {
      final result = await CameraScanApi.scan(
        useFlash: true,
        prompt: 'Scan with flash',
      );
      setState(() {
        _lastResult = result['code']!;
        _lastFormat = result['format']!;
      });
    } catch (e) {
      print('Scan error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Last Result: $_lastResult'),
        Text('Format: $_lastFormat'),
        ElevatedButton(
          onPressed: _scanQuick,
          child: Text('Quick Scan'),
        ),
        ElevatedButton(
          onPressed: _scanQRCode,
          child: Text('Scan QR Code'),
        ),
        ElevatedButton(
          onPressed: _scanWithFlash,
          child: Text('Scan with Flash'),
        ),
      ],
    );
  }
}
```

## Notes

- Camera permission required
- Scanning opens a full-screen camera view
- User can cancel scan by pressing back
- Timeout causes scan to fail if no code detected
- Flash may not be available on all devices

## Supported Devices

All iMin POS devices with camera
