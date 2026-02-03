# Segment Display Module

Digital tube display control for iMin POS devices.

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

The plugin exports `IminSegment` class for segment display control.

## Features

- Find and connect to segment display
- Send data to display
- Clear display
- Full display test
- Left/right alignment

## API Reference

### Find Device

```dart
Map<String, dynamic> result = await IminSegment.findDevice();
// Returns: {found: bool, productId: int, vendorId: int, deviceName: String}
```

### Request Permission

```dart
bool granted = await IminSegment.requestPermission();
```

### Connect

```dart
bool success = await IminSegment.connect();
```

### Send Data

```dart
await IminSegment.sendData('12345', align: 'right');
```

Alignment options:
- `'right'` - Right align (default)
- `'left'` - Left align

### Clear Display

```dart
await IminSegment.clear();
```

### Full Display Test

```dart
await IminSegment.full();
```

### Disconnect

```dart
await IminSegment.disconnect();
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class SegmentExample extends StatefulWidget {
  @override
  _SegmentExampleState createState() => _SegmentExampleState();
}

class _SegmentExampleState extends State<SegmentExample> {
  bool _isConnected = false;
  String _deviceInfo = 'No device found';

  Future<void> _findDevice() async {
    final result = await IminSegment.findDevice();
    setState(() {
      if (result['found'] == true) {
        _deviceInfo = 'Device found\n'
            'PID: ${result['productId']}\n'
            'VID: ${result['vendorId']}\n'
            'Name: ${result['deviceName']}';
      } else {
        _deviceInfo = 'No segment device found';
      }
    });
  }

  Future<void> _connect() async {
    final granted = await IminSegment.requestPermission();
    if (granted) {
      final success = await IminSegment.connect();
      setState(() => _isConnected = success);
    }
  }

  Future<void> _sendData(String data) async {
    if (!_isConnected) return;
    await IminSegment.sendData(data, align: 'right');
  }

  Future<void> _clear() async {
    if (!_isConnected) return;
    await IminSegment.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(_deviceInfo),
        ElevatedButton(
          onPressed: _findDevice,
          child: Text('Find Device'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('Connect'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? () => _sendData('12345') : null,
          child: Text('Send Data'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _clear : null,
          child: Text('Clear'),
        ),
      ],
    );
  }
}
```

## Notes

- USB permission required before connecting
- Supports numbers and letters
- Maximum 9 characters
- Device must be physically connected via USB

## Supported Devices

iMin devices with USB segment display support
