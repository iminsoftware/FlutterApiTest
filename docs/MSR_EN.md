# MSR Module

Magnetic Stripe Reader for iMin POS devices.

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

The plugin exports `IminMsr` class for magnetic stripe reader operations.

## Features

- Check MSR availability
- Read magnetic stripe cards
- Support for Track 1, 2, and 3 data

## API Reference

### Check Availability

```dart
bool available = await IminMsr.isAvailable();
```

## Usage

The MSR module works through standard Android input methods. When a card is swiped, the data is automatically sent to the focused text field.

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class MsrExample extends StatefulWidget {
  @override
  _MsrExampleState createState() => _MsrExampleState();
}

class _MsrExampleState extends State<MsrExample> {
  bool _isAvailable = false;
  final TextEditingController _msrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void dispose() {
    _msrController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    final available = await IminMsr.isAvailable();
    setState(() => _isAvailable = available);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('MSR Available: $_isAvailable'),
        TextField(
          controller: _msrController,
          decoration: InputDecoration(
            labelText: 'Swipe Card Here',
            hintText: 'Card data will appear here',
          ),
          maxLines: 3,
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              print('Card data received: ${value.length} characters');
              // Process card data
            }
          },
        ),
        ElevatedButton(
          onPressed: () => _msrController.clear(),
          child: Text('Clear'),
        ),
      ],
    );
  }
}
```

## Card Data Format

Magnetic stripe cards typically contain:
- Track 1: Alphanumeric data (name, account number)
- Track 2: Numeric data (account number, expiration)
- Track 3: Additional data (varies by card type)

The data format depends on the card type and encoding standard.

## Notes

- MSR data is sent as keyboard input
- Focus must be on a text field to receive data
- Data includes start/end sentinels and separators
- Parse the raw data according to your card format
- Handle sensitive data securely

## Supported Devices

iMin devices with built-in magnetic stripe reader
