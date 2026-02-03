# Serial Module

Serial port communication for iMin POS devices.

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

The plugin exports `IminSerial` class for serial port communication.

## Features

- Open/close serial ports
- Send and receive data
- Stream-based data reception
- Support for multiple baud rates

## API Reference

### Open Serial Port

```dart
bool success = await IminSerial.open(
  path: '/dev/ttyS4',
  baudRate: 115200,
);
```

Common serial ports:
- `/dev/ttyS4` - Default serial port
- `/dev/ttyUSB0` - USB serial adapter

Common baud rates: 9600, 19200, 38400, 57600, 115200

### Close Serial Port

```dart
bool success = await IminSerial.close();
```

### Write Data

```dart
Uint8List data = Uint8List.fromList([0x01, 0x02, 0x03]);
bool success = await IminSerial.write(data);
```

### Listen to Data Stream

```dart
StreamSubscription subscription = IminSerial.dataStream.listen((event) {
  print('Received: ${event.data}');
  print('Bytes: ${event.bytes}');
});
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'dart:typed_data';

class SerialExample extends StatefulWidget {
  @override
  _SerialExampleState createState() => _SerialExampleState();
}

class _SerialExampleState extends State<SerialExample> {
  bool _isOpen = false;
  List<String> _receivedData = [];
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToData();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isOpen) {
      IminSerial.close();
    }
    super.dispose();
  }

  void _listenToData() {
    _subscription = IminSerial.dataStream.listen((event) {
      setState(() {
        _receivedData.insert(0, event.data);
        if (_receivedData.length > 50) {
          _receivedData.removeLast();
        }
      });
    });
  }

  Future<void> _openPort() async {
    final success = await IminSerial.open(
      path: '/dev/ttyS4',
      baudRate: 115200,
    );
    setState(() => _isOpen = success);
  }

  Future<void> _closePort() async {
    await IminSerial.close();
    setState(() => _isOpen = false);
  }

  Future<void> _sendData(String text) async {
    if (!_isOpen) return;
    
    final bytes = Uint8List.fromList(text.codeUnits);
    await IminSerial.write(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Port: ${_isOpen ? "Open" : "Closed"}'),
        ElevatedButton(
          onPressed: _isOpen ? null : _openPort,
          child: Text('Open Port'),
        ),
        ElevatedButton(
          onPressed: _isOpen ? _closePort : null,
          child: Text('Close Port'),
        ),
        ElevatedButton(
          onPressed: _isOpen ? () => _sendData('Hello') : null,
          child: Text('Send Data'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _receivedData.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_receivedData[index]),
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

- Close port when not in use
- Handle data encoding/decoding appropriately
- Check port permissions on device
- Use appropriate baud rate for your device

## Supported Devices

All iMin POS devices with serial port support
