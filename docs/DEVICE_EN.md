# Device Module

Get device information for iMin POS devices.

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Import

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
```

The plugin exports `IminDevice` class for device information.

## Features

- Get device model
- Get device serial number
- Get firmware version
- Get hardware version
- Get system information

## API Reference

### Get Device Model

```dart
String model = await IminDevice.getModel();
```

### Get Serial Number

```dart
String serialNumber = await IminDevice.getSerialNumber();
```

### Get Firmware Version

```dart
String firmwareVersion = await IminDevice.getFirmwareVersion();
```

### Get Hardware Version

```dart
String hardwareVersion = await IminDevice.getHardwareVersion();
```

### Get All Device Info

```dart
Map<String, String> info = await IminDevice.getAllInfo();
// Returns: {
//   model: String,
//   serialNumber: String,
//   firmwareVersion: String,
//   hardwareVersion: String,
//   androidVersion: String,
//   ...
// }
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class DeviceInfoExample extends StatefulWidget {
  @override
  _DeviceInfoExampleState createState() => _DeviceInfoExampleState();
}

class _DeviceInfoExampleState extends State<DeviceInfoExample> {
  String _model = '';
  String _serialNumber = '';
  String _firmwareVersion = '';
  Map<String, String> _allInfo = {};

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final model = await IminDevice.getModel();
    final serialNumber = await IminDevice.getSerialNumber();
    final firmwareVersion = await IminDevice.getFirmwareVersion();
    final allInfo = await IminDevice.getAllInfo();

    setState(() {
      _model = model;
      _serialNumber = serialNumber;
      _firmwareVersion = firmwareVersion;
      _allInfo = allInfo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Model: $_model'),
        Text('Serial Number: $_serialNumber'),
        Text('Firmware: $_firmwareVersion'),
        Divider(),
        Text('All Info:'),
        ..._allInfo.entries.map((e) => Text('${e.key}: ${e.value}')),
      ],
    );
  }
}
```

## Notes

- Device information is read-only
- Serial number is unique per device
- Firmware version format may vary by device
- Some information may not be available on all devices

## Supported Devices

All iMin POS devices
