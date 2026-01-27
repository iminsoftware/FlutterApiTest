# iMin Hardware Plugin

A Flutter plugin for controlling iMin POS device hardware features including secondary display, scanner, NFC, RFID, and more.

## Features

- ✅ **Secondary Display Control** - Show text, images, and videos on secondary display
- ✅ **Cash Box** - Cash drawer control with voltage settings
- ✅ **Light Control** - USB LED indicator lights (red/green)
- ✅ **NFC Reader** - NFC card reading with real-time tag stream
- ✅ **Scanner** - Hardware barcode/QR code scanner
- ✅ **MSR** - Magnetic stripe card reader
- ✅ **Electronic Scale** - Serial port weight measurement
- ✅ **Serial Port** - Serial communication
- ✅ **Segment Display** - USB digital tube display
- ✅ **Floating Window** - System floating window overlay
- ✅ **Camera Scan** - Camera-based barcode/QR code scanning (ZXing)
- ✅ **RFID** - RFID tag read/write (Basic implementation)

## Supported Devices

- iMin Crane 1
- iMin Swan 1/2/3
- iMin Swift 1/2/2 Ultra
- iMin Lark 1
- iMin Falcon 2
- iMin D4
- iMin M2-Pro

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  imin_hardware_plugin:
    path: ../imin_hardware_plugin
```

## Usage

### Secondary Display

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Check if secondary display is available
bool available = await IminDisplay.isAvailable();

// Enable secondary display
bool success = await IminDisplay.enable();

// Show text
await IminDisplay.showText('Hello, Secondary Display!');

// Show image
await IminDisplay.showImage('/path/to/image.png');

// Play video
await IminDisplay.playVideo('/path/to/video.mp4');

// Clear display
await IminDisplay.clear();

// Disable display
await IminDisplay.disable();
```

### Cash Box

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Open cash box
bool success = await IminCashBox.open();

// Get cash box status
bool isOpen = await IminCashBox.getStatus();

// Set voltage (9V, 12V, or 24V)
bool success = await IminCashBox.setVoltage(CashBoxVoltage.v12);
```

### Light Control

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Connect to light device
bool connected = await IminLight.connect();

// Turn on green light (success/ready state)
bool success = await IminLight.turnOnGreen();

// Turn on red light (error/busy state)
bool success = await IminLight.turnOnRed();

// Turn off all lights
bool success = await IminLight.turnOff();

// Disconnect from device
bool success = await IminLight.disconnect();
```

### NFC Reader

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Check if NFC is available
bool available = await IminNfc.isAvailable();

// Check if NFC is enabled
bool enabled = await IminNfc.isEnabled();

// Open NFC settings
await IminNfc.openSettings();

// Listen to NFC tag stream
IminNfc.tagStream.listen((tag) {
  print('NFC ID: ${tag.id}');
  print('Formatted ID: ${tag.formattedId}'); // e.g., "1234 5678 90AB CDEF"
  print('Content: ${tag.content}');
  print('Technology: ${tag.technology}');
  print('Timestamp: ${tag.timestamp}');
});
```

### Scanner

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Configure scanner (optional)
await IminScanner.configure(
  action: 'com.imin.scanner.api.RESULT_ACTION',
  dataKey: 'decode_data_str',
);

// Start listening
await IminScanner.startListening();

// Listen to scan events
IminScanner.scanStream.listen((result) {
  print('Scanned: ${result.data}');
  print('Timestamp: ${result.timestamp}');
});

// Stop listening
await IminScanner.stopListening();
```

### Floating Window

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Show floating window
bool success = await FloatingWindowApi.show();

// Update text
await FloatingWindowApi.updateText('Hello, Floating Window!');

// Set position
await FloatingWindowApi.setPosition(100, 100);

// Check if showing
bool isShowing = await FloatingWindowApi.isShowing();

// Hide floating window
await FloatingWindowApi.hide();
```

### Camera Scan

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Quick scan (default formats)
String result = await CameraScanApi.scanQuick();

// Scan QR code only
String qrCode = await CameraScanApi.scanQRCode();

// Scan barcode only
String barcode = await CameraScanApi.scanBarcode();

// Custom scan with specific formats
String customResult = await CameraScanApi.scan(
  formats: [BarcodeFormat.qrCode, BarcodeFormat.code128],
  prompt: 'Scan a code',
);
```

## Permissions

### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<!-- Display and floating window permissions -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- USB permissions for light control and segment display -->
<uses-feature android:name="android.hardware.usb.host" android:required="false"/>

<!-- NFC permissions -->
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />

<!-- Camera permissions for camera scan -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false"/>

<!-- Activity configuration for NFC -->
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop">
</activity>
```

**Notes:**
- `SYSTEM_ALERT_WINDOW` - Required for secondary display overlay and floating window
- `INTERNET` - Required for loading network images/videos on secondary display
- `android.hardware.usb.host` - Required for USB light device control and segment display
- `android.permission.NFC` - Required for NFC card reading
- `android.hardware.nfc` - NFC hardware feature (optional)
- `android.permission.CAMERA` - Required for camera-based scanning
- `android:launchMode="singleTop"` - Required for NFC onNewIntent handling
- For Android 6.0+, overlay permission needs to be requested at runtime (handled automatically)

## Example

See the [example](example/) directory for a complete sample app.

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for development documentation.

## License

MIT License
