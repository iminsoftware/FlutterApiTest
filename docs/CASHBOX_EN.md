# Cashbox Module

Control cash drawer operations on iMin POS devices.

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

The plugin exports `IminCashBox` class for cash drawer control.

## Features

- Open cash drawer
- Check drawer status
- Configure voltage settings

## API Reference

### Open Cash Drawer

```dart
bool success = await IminCashBox.open();
```

### Get Status

```dart
bool isOpen = await IminCashBox.getStatus();
```

Returns `true` if drawer is open, `false` if closed.

### Set Voltage

```dart
bool success = await IminCashBox.setVoltage(CashBoxVoltage.v12);
```

Available voltage options:
- `CashBoxVoltage.v9` - 9V
- `CashBoxVoltage.v12` - 12V (default)
- `CashBoxVoltage.v24` - 24V

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class CashBoxExample extends StatefulWidget {
  @override
  _CashBoxExampleState createState() => _CashBoxExampleState();
}

class _CashBoxExampleState extends State<CashBoxExample> {
  bool _isOpen = false;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    _statusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final isOpen = await IminCashBox.getStatus();
      setState(() => _isOpen = isOpen);
    } catch (e) {
      print('Error checking status: $e');
    }
  }

  Future<void> _openDrawer() async {
    try {
      final success = await IminCashBox.open();
      if (success) {
        print('Cash drawer opened');
      }
    } catch (e) {
      print('Error opening drawer: $e');
    }
  }

  Future<void> _setVoltage(CashBoxVoltage voltage) async {
    try {
      final success = await IminCashBox.setVoltage(voltage);
      if (success) {
        print('Voltage set to ${voltage.value}V');
      }
    } catch (e) {
      print('Error setting voltage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Status: ${_isOpen ? "Open" : "Closed"}'),
        ElevatedButton(
          onPressed: _openDrawer,
          child: Text('Open Cash Drawer'),
        ),
        ElevatedButton(
          onPressed: () => _setVoltage(CashBoxVoltage.v12),
          child: Text('Set 12V'),
        ),
      ],
    );
  }
}
```

## Notes

- Voltage must match your cash drawer specifications
- Status polling recommended for real-time updates
- Opening drawer triggers a brief pulse signal

## Supported Devices

All iMin POS devices with cash drawer port
