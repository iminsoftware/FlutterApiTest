# Display Module

Control secondary display on iMin POS devices.

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

The plugin exports `IminDisplay` class for display control.

## Features

- Enable/disable secondary display
- Show text content
- Display images
- Play videos
- Clear display

## API Reference

### Check Availability

```dart
bool available = await IminDisplay.isAvailable();
```

### Enable Display

```dart
bool success = await IminDisplay.enable();
```

### Disable Display

```dart
await IminDisplay.disable();
```

### Show Text

```dart
await IminDisplay.showText('Hello from Flutter!');
```

### Show Image

```dart
await IminDisplay.showImage('assets/images/logo.png');
```

### Play Video

```dart
await IminDisplay.playVideo('assets/videos/promo.mp4');
```

### Clear Display

```dart
await IminDisplay.clear();
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class DisplayExample extends StatefulWidget {
  @override
  _DisplayExampleState createState() => _DisplayExampleState();
}

class _DisplayExampleState extends State<DisplayExample> {
  bool _isAvailable = false;
  bool _isEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkDisplay();
  }

  Future<void> _checkDisplay() async {
    final available = await IminDisplay.isAvailable();
    setState(() => _isAvailable = available);
  }

  Future<void> _toggleDisplay() async {
    if (_isEnabled) {
      await IminDisplay.disable();
      setState(() => _isEnabled = false);
    } else {
      final success = await IminDisplay.enable();
      setState(() => _isEnabled = success);
    }
  }

  Future<void> _showContent() async {
    await IminDisplay.showText('Welcome!');
    await Future.delayed(Duration(seconds: 2));
    await IminDisplay.showImage('assets/images/logo.png');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Display Available: $_isAvailable'),
        ElevatedButton(
          onPressed: _isAvailable ? _toggleDisplay : null,
          child: Text(_isEnabled ? 'Disable' : 'Enable'),
        ),
        ElevatedButton(
          onPressed: _isEnabled ? _showContent : null,
          child: Text('Show Content'),
        ),
      ],
    );
  }
}
```

## Notes

- Secondary display must be enabled before showing content
- Supported image formats: PNG, JPG
- Supported video formats: MP4
- Assets must be declared in `pubspec.yaml`

## Supported Devices

iMin D4, M2-Pro, Swan, Swift series with secondary display
