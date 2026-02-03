# Light Module

Control LED indicator lights on iMin POS devices.

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

The plugin exports `IminLight` class for LED light control.

## Features

- Connect/disconnect to light device
- Turn on green light
- Turn on red light
- Turn off lights

## API Reference

### Connect to Device

```dart
bool success = await IminLight.connect();
```

### Turn On Green Light

```dart
bool success = await IminLight.turnOnGreen();
```

### Turn On Red Light

```dart
bool success = await IminLight.turnOnRed();
```

### Turn Off Light

```dart
bool success = await IminLight.turnOff();
```

### Disconnect from Device

```dart
bool success = await IminLight.disconnect();
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class LightExample extends StatefulWidget {
  @override
  _LightExampleState createState() => _LightExampleState();
}

class _LightExampleState extends State<LightExample> {
  bool _isConnected = false;
  LightColor _currentLight = LightColor.off;

  Future<void> _connect() async {
    final success = await IminLight.connect();
    setState(() => _isConnected = success);
  }

  Future<void> _turnOnGreen() async {
    final success = await IminLight.turnOnGreen();
    if (success) {
      setState(() => _currentLight = LightColor.green);
    }
  }

  Future<void> _turnOnRed() async {
    final success = await IminLight.turnOnRed();
    if (success) {
      setState(() => _currentLight = LightColor.red);
    }
  }

  Future<void> _turnOff() async {
    final success = await IminLight.turnOff();
    if (success) {
      setState(() => _currentLight = LightColor.off);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Connected: $_isConnected'),
        Text('Current: $_currentLight'),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('Connect'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOnGreen : null,
          child: Text('Green Light'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOnRed : null,
          child: Text('Red Light'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? _turnOff : null,
          child: Text('Turn Off'),
        ),
      ],
    );
  }
}

enum LightColor { off, green, red }
```

## Notes

- Must connect to device before controlling lights
- Only one light can be active at a time
- Disconnect when done to free resources

## Supported Devices

iMin devices with LED indicator lights
