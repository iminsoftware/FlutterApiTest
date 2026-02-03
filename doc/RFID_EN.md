# RFID Module

RFID tag reading and operations for iMin POS devices.

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

The plugin exports `IminRfid` class for RFID operations.

## Features

- Connect to RFID reader
- Read RFID tags
- Stream-based tag detection
- Battery status monitoring
- Tag operations (read, write, lock, kill)

## API Reference

### Check Connection

```dart
bool connected = await IminRfid.isConnected();
```

### Connect

```dart
await IminRfid.connect();
```

### Disconnect

```dart
await IminRfid.disconnect();
```

### Start Reading

```dart
await IminRfid.startReading();
```

### Stop Reading

```dart
await IminRfid.stopReading();
```

### Listen to Tag Stream

```dart
StreamSubscription subscription = IminRfid.tagStream.listen((event) {
  if (event.isTag && event.tag != null) {
    final tag = event.tag!;
    print('EPC: ${tag.epc}');
    print('RSSI: ${tag.rssi} dBm');
    print('Count: ${tag.count}');
    print('PC: ${tag.pc}');
    print('TID: ${tag.tid}');
  } else if (event.isError) {
    print('Error: ${event.errorMessage}');
  }
});
```

### Listen to Connection Stream

```dart
StreamSubscription subscription = IminRfid.connectionStream.listen((connected) {
  print('Connected: $connected');
});
```

### Listen to Battery Stream

```dart
StreamSubscription subscription = IminRfid.batteryStream.listen((status) {
  print('Battery: ${status.level}%');
  print('Charging: ${status.charging}');
});
```

### Get Battery Level

```dart
int level = await IminRfid.getBatteryLevel();
```

### Check if Charging

```dart
bool charging = await IminRfid.isCharging();
```

### Clear Tags

```dart
await IminRfid.clearTags();
```

## RfidTag Model

```dart
class RfidTag {
  final String epc;         // Electronic Product Code
  final int rssi;           // Signal strength (dBm)
  final int count;          // Read count
  final String? pc;         // Protocol Control
  final String? tid;        // Tag ID
  final int frequency;      // Frequency (kHz)
  final int timestamp;      // Detection time
}
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class RfidExample extends StatefulWidget {
  @override
  _RfidExampleState createState() => _RfidExampleState();
}

class _RfidExampleState extends State<RfidExample> {
  bool _isConnected = false;
  bool _isReading = false;
  int _batteryLevel = 0;
  List<RfidTag> _tags = [];
  StreamSubscription? _tagSubscription;
  StreamSubscription? _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _listenToStreams();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  void _listenToStreams() {
    _tagSubscription = IminRfid.tagStream.listen((event) {
      if (event.isTag && event.tag != null) {
        setState(() {
          _tags.add(event.tag!);
        });
      }
    });

    _connectionSubscription = IminRfid.connectionStream.listen((connected) {
      setState(() => _isConnected = connected);
    });
  }

  Future<void> _connect() async {
    await IminRfid.connect();
  }

  Future<void> _startReading() async {
    await IminRfid.startReading();
    setState(() => _isReading = true);
  }

  Future<void> _stopReading() async {
    await IminRfid.stopReading();
    setState(() => _isReading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Connected: $_isConnected'),
        Text('Battery: $_batteryLevel%'),
        ElevatedButton(
          onPressed: _isConnected ? null : _connect,
          child: Text('Connect'),
        ),
        ElevatedButton(
          onPressed: _isConnected && !_isReading ? _startReading : null,
          child: Text('Start Reading'),
        ),
        ElevatedButton(
          onPressed: _isReading ? _stopReading : null,
          child: Text('Stop Reading'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _tags.length,
            itemBuilder: (context, index) {
              final tag = _tags[index];
              return ListTile(
                title: Text(tag.epc),
                subtitle: Text('RSSI: ${tag.rssi} dBm, Count: ${tag.count}'),
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

- RFID reader must be paired via Bluetooth
- Battery status available when connected
- Tags are deduplicated by EPC
- RSSI indicates signal strength
- Stop reading when not needed to save battery

## Supported Devices

iMin devices with RFID reader support
