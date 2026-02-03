# Floating Window Module

Display overlay floating windows on iMin POS devices.

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

The plugin exports `FloatingWindowApi` class for floating window operations.

## Features

- Show/hide floating window
- Update window text
- Set window position
- Check window status

## API Reference

### Show Floating Window

```dart
await FloatingWindowApi.show();
```

### Hide Floating Window

```dart
await FloatingWindowApi.hide();
```

### Check if Showing

```dart
bool isShowing = await FloatingWindowApi.isShowing();
```

### Update Text

```dart
await FloatingWindowApi.updateText('New text');
```

### Set Position

```dart
await FloatingWindowApi.setPosition(100, 200);  // x, y coordinates
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class FloatingWindowExample extends StatefulWidget {
  @override
  _FloatingWindowExampleState createState() => _FloatingWindowExampleState();
}

class _FloatingWindowExampleState extends State<FloatingWindowExample> {
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final isShowing = await FloatingWindowApi.isShowing();
    setState(() => _isShowing = isShowing);
  }

  Future<void> _showWindow() async {
    await FloatingWindowApi.show();
    await _checkStatus();
  }

  Future<void> _hideWindow() async {
    await FloatingWindowApi.hide();
    await _checkStatus();
  }

  Future<void> _updateText(String text) async {
    await FloatingWindowApi.updateText(text);
  }

  Future<void> _setPosition(int x, int y) async {
    await FloatingWindowApi.setPosition(x, y);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Status: ${_isShowing ? "Showing" : "Hidden"}'),
        ElevatedButton(
          onPressed: _showWindow,
          child: Text('Show Window'),
        ),
        ElevatedButton(
          onPressed: _hideWindow,
          child: Text('Hide Window'),
        ),
        ElevatedButton(
          onPressed: () => _updateText('Hello!'),
          child: Text('Update Text'),
        ),
        ElevatedButton(
          onPressed: () => _setPosition(100, 200),
          child: Text('Set Position'),
        ),
      ],
    );
  }
}
```

## Notes

- Requires "Display over other apps" permission on Android 6.0+
- Window persists across app screens
- Position is in screen pixels
- Hide window when not needed

## Permission Setup

Add to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

Request permission at runtime:

```dart
import 'package:permission_handler/permission_handler.dart';

await Permission.systemAlertWindow.request();
```

## Supported Devices

All iMin POS devices running Android 6.0+
