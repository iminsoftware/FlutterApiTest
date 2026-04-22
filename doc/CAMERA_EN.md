# Camera Module

Camera-based barcode and QR code scanning for iMin POS devices.

Supports two scan engines:
- **ZXing** (default) — local decoding, best compatibility
- **ML Kit** (optional) — any-angle recognition, multi-barcode, faster

## Installation

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
  permission_handler: ^11.0.0  # For camera permission
```

## Import

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
```

## API Reference

### Single Scan

```dart
// Quick scan (default formats: QR_CODE, UPC_A, EAN_13, CODE_128)
String code = await CameraScanApi.scanQuick();

// QR code only
String code = await CameraScanApi.scanQRCode();

// Barcode only (all 1D formats)
String code = await CameraScanApi.scanBarcode();

// All formats with full result
Map<String, dynamic> result = await CameraScanApi.scanAll();
// result = {'code': '...', 'format': 'QR_CODE'}

// Custom scan
Map<String, dynamic> result = await CameraScanApi.scan(
  formats: ['QR_CODE', 'CODE_128'],
  useFlash: true,
  beepEnabled: true,
  timeout: 10000,  // 10 seconds, 0 = no timeout
);
```

### Multi Scan (ML Kit)

Supports multi-barcode and any-angle recognition. Falls back to ZXing automatically if ML Kit is unavailable.

```dart
// Default multi scan
List<Map<String, dynamic>> results = await CameraScanApi.scanMulti();

// Multi-angle only (single barcode, any orientation)
final results = await CameraScanApi.scanMulti(const MultiScanOptions(
  supportMultiAngle: true,
  supportMultiBarcode: false,
  fullAreaScan: true,
));

// Full configuration
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

### ML Kit Detection

```dart
bool available = await CameraScanApi.isMLKitAvailable();
```

### MultiScanOptions

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| formats | List\<String\>? | all | Barcode formats to scan |
| useFlash | bool | false | Enable flashlight |
| beepEnabled | bool | true | Play beep on success |
| timeout | int | 0 | Timeout in ms (0 = none) |
| supportMultiBarcode | bool | true | Scan multiple barcodes |
| supportMultiAngle | bool | true | Any-angle recognition |
| decodeEngine | int | 1 (MLKit) | 0=ZXing, 1=MLKit |
| fullAreaScan | bool | true | Full area scanning |
| areaRectRatio | double | 0.8 | Scan area ratio (0.5~1.0) |

### Supported Formats

**1D (12):** CODABAR, CODE_39, CODE_93, CODE_128, EAN_8, EAN_13, ITF, RSS_14, RSS_EXPANDED, UPC_A, UPC_E, UPC_EAN_EXTENSION

**2D (5):** QR_CODE, DATA_MATRIX, PDF_417, AZTEC, MAXICODE

## Example

```dart
class ScanExample extends StatelessWidget {
  Future<void> _scan() async {
    // Request camera permission first
    await Permission.camera.request();

    // Single scan
    try {
      final result = await CameraScanApi.scanAll();
      print('${result['format']}: ${result['code']}');
    } catch (e) {
      print('Scan canceled or failed: $e');
    }

    // Multi scan
    try {
      final results = await CameraScanApi.scanMulti();
      for (final r in results) {
        print('${r['format']}: ${r['code']}');
      }
    } catch (e) {
      print('Multi scan failed: $e');
    }
  }
}
```

## Notes

- Camera permission required (`permission_handler` recommended)
- Scanning opens a full-screen camera view
- User can cancel by pressing back
- ML Kit requires Google Play Services; auto-fallback to ZXing on devices without GMS
- All iMin POS devices with camera are supported
