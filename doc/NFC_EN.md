# NFC Module

Read NFC cards and tags on iMin POS devices.

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

The plugin exports `IminNfc` class for NFC operations.

## Features

- Check NFC availability and status
- Read NFC tags
- Stream-based tag detection
- Open NFC settings

## API Reference

### Check Availability

```dart
bool available = await IminNfc.isAvailable();
```

### Check if Enabled

```dart
bool enabled = await IminNfc.isEnabled();
```

### Listen to NFC Tags

```dart
StreamSubscription<NfcTag> subscription = IminNfc.tagStream.listen((tag) {
  print('NFC ID: ${tag.id}');
  print('Formatted: ${tag.formattedId}');
  print('Content: ${tag.content}');
  print('Technology: ${tag.technology}');
  print('Timestamp: ${tag.timestamp}');
});
```

### Open NFC Settings

```dart
await IminNfc.openSettings();
```

## NfcTag Model

```dart
class NfcTag {
  final String id;              // Raw hex ID
  final String formattedId;     // Formatted ID (e.g., "12:34:56:78")
  final String content;         // Tag content if available
  final String technology;      // NFC technology type
  final DateTime timestamp;     // Detection time
}
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class NfcExample extends StatefulWidget {
  @override
  _NfcExampleState createState() => _NfcExampleState();
}

class _NfcExampleState extends State<NfcExample> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  NfcTag? _currentTag;
  StreamSubscription<NfcTag>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkNfc();
    _startListening();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNfc() async {
    final available = await IminNfc.isAvailable();
    final enabled = await IminNfc.isEnabled();
    setState(() {
      _isAvailable = available;
      _isEnabled = enabled;
    });
  }

  void _startListening() {
    _subscription = IminNfc.tagStream.listen((tag) {
      setState(() => _currentTag = tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Available: $_isAvailable'),
        Text('Enabled: $_isEnabled'),
        if (_currentTag != null) ...[
          Text('ID: ${_currentTag!.formattedId}'),
          Text('Content: ${_currentTag!.content}'),
        ],
        if (!_isEnabled)
          ElevatedButton(
            onPressed: () => IminNfc.openSettings(),
            child: Text('Open NFC Settings'),
          ),
      ],
    );
  }
}
```

## Notes

- NFC must be enabled in device settings
- Keep listening active to detect tags
- Tag detection is automatic when NFC is enabled
- Some tags may not have readable content

## Supported Devices

iMin devices with NFC reader capability
