# Scanner Module

Barcode and QR code scanning on iMin POS devices.

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

The plugin exports `IminScanner` class for barcode scanning.

## Features

- Start/stop listening for scans
- Stream-based scan results
- Custom broadcast configuration
- Connection status monitoring

## API Reference

### Check Connection

```dart
bool connected = await IminScanner.isConnected();
```

### Configure Scanner

```dart
await IminScanner.configure(
  action: 'com.imin.scanner.api.RESULT_ACTION',
  dataKey: 'decode_data_str',
  byteDataKey: 'decode_data',
);
```

### Start Listening

```dart
bool started = await IminScanner.startListening();
```

### Stop Listening

```dart
bool stopped = await IminScanner.stopListening();
```

### Listen to Scan Stream

```dart
StreamSubscription<ScannerEvent> subscription = IminScanner.scanStream.listen((event) {
  if (event is ScanResult) {
    print('Data: ${event.data}');
    print('Type: ${event.labelType}');
    print('Time: ${event.timestamp}');
  } else if (event is ScannerConnected) {
    print('Scanner connected');
  } else if (event is ScannerDisconnected) {
    print('Scanner disconnected');
  } else if (event is ScannerConnectionStatus) {
    print('Connected: ${event.connected}');
  }
});
```

## Scanner Events

```dart
// Scan result
class ScanResult extends ScannerEvent {
  final String data;
  final String labelType;
  final DateTime timestamp;
}

// Connection events
class ScannerConnected extends ScannerEvent {}
class ScannerDisconnected extends ScannerEvent {}
class ScannerConnectionStatus extends ScannerEvent {
  final bool connected;
}
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class ScannerExample extends StatefulWidget {
  @override
  _ScannerExampleState createState() => _ScannerExampleState();
}

class _ScannerExampleState extends State<ScannerExample> {
  bool _isListening = false;
  bool _isConnected = false;
  List<ScanResult> _scanHistory = [];
  StreamSubscription<ScannerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isListening) {
      IminScanner.stopListening();
    }
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connected = await IminScanner.isConnected();
    setState(() => _isConnected = connected);
  }

  Future<void> _startListening() async {
    final started = await IminScanner.startListening();
    if (started) {
      setState(() => _isListening = true);
      
      _subscription = IminScanner.scanStream.listen((event) {
        if (event is ScanResult) {
          setState(() {
            _scanHistory.insert(0, event);
            if (_scanHistory.length > 50) {
              _scanHistory.removeLast();
            }
          });
        } else if (event is ScannerConnected) {
          setState(() => _isConnected = true);
        } else if (event is ScannerDisconnected) {
          setState(() => _isConnected = false);
        }
      });
    }
  }

  Future<void> _stopListening() async {
    await _subscription?.cancel();
    final stopped = await IminScanner.stopListening();
    if (stopped) {
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Connected: $_isConnected'),
        Text('Listening: $_isListening'),
        ElevatedButton(
          onPressed: _isListening ? null : _startListening,
          child: Text('Start Listening'),
        ),
        ElevatedButton(
          onPressed: _isListening ? _stopListening : null,
          child: Text('Stop Listening'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _scanHistory.length,
            itemBuilder: (context, index) {
              final scan = _scanHistory[index];
              return ListTile(
                title: Text(scan.data),
                subtitle: Text('Type: ${scan.labelType}'),
              );
            },
          ),
        ),
      ],
    );
  }
}
```

## Notes

- Scanner must be connected before listening
- Custom configuration is optional
- Keep listening active to receive scans
- Stop listening when not needed to save battery

## Supported Devices

All iMin POS devices with built-in or external scanner
