# iMin Hardware Plugin

A Flutter plugin for controlling iMin POS device hardware features including secondary display, scanner, NFC, RFID, and more.

## Features

- ✅ **Secondary Display Control** - Show text, images, and videos on secondary display
- ✅ **Cash Box** - Cash drawer control with voltage settings
- ✅ **Light Control** - USB LED indicator lights (red/green)
- ✅ **NFC Reader** - NFC card reading with real-time tag stream
- 🚧 **Scanner** - Barcode/QR code scanning (Coming soon)
- 🚧 **RFID** - RFID tag read/write (Coming soon)

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

## Permissions

### Android

Add the following permissions to your `AndroidManifest.xml`:

```xml
<!-- Display permissions -->
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.INTERNET"/>

<!-- USB permissions for light control -->
<uses-feature android:name="android.hardware.usb.host" android:required="false"/>

<!-- NFC permissions -->
<uses-permission android:name="android.permission.NFC" />
<uses-feature android:name="android.hardware.nfc" android:required="false" />

<!-- Activity configuration for NFC -->
<activity
    android:name=".MainActivity"
    android:launchMode="singleTop">
</activity>
```

**Notes:**
- `SYSTEM_ALERT_WINDOW` - Required for secondary display overlay
- `INTERNET` - Required for loading network images/videos on secondary display
- `android.hardware.usb.host` - Required for USB light device control
- `android.permission.NFC` - Required for NFC card reading
- `android.hardware.nfc` - NFC hardware feature (optional)
- `android:launchMode="singleTop"` - Required for NFC onNewIntent handling
- For Android 6.0+, overlay permission needs to be requested at runtime (handled automatically)

## Example

See the [example](example/) directory for a complete sample app.

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for development documentation.

## License

MIT License
