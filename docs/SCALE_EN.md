# Scale Module

Electronic scale integration for iMin POS devices (Android 13+).

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

The plugin exports `IminScaleNew` class for electronic scale operations (Android 13+).

## Features

- Connect to scale service
- Real-time weight data streaming
- Zero and tare operations
- Price calculation
- Unit conversion
- Device information and diagnostics

## API Reference

### Connect to Service

```dart
bool success = await IminScaleNew.connectService();
```

### Get Service Version

```dart
String version = await IminScaleNew.getServiceVersion();
```

### Get Firmware Version

```dart
String version = await IminScaleNew.getFirmwareVersion();
```

### Start Getting Data

```dart
bool success = await IminScaleNew.getData();
```

### Stop Getting Data

```dart
bool success = await IminScaleNew.cancelGetData();
```

### Listen to Scale Events

```dart
StreamSubscription<ScaleEvent> subscription = IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) {
    final data = event.data as ScaleWeightData;
    print('Net: ${data.net} kg');
    print('Tare: ${data.tare} kg');
    print('Stable: ${data.isStable}');
  } else if (event.isStatus) {
    final status = event.data as ScaleStatusData;
    print('Overload: ${status.overload}');
    print('Light weight: ${status.isLightWeight}');
  } else if (event.isPrice) {
    final price = event.data as ScalePriceData;
    print('Unit price: ${price.unitPrice}');
    print('Total price: ${price.totalPrice}');
  } else if (event.isError) {
    print('Error code: ${event.data}');
  } else if (event.isConnection) {
    final conn = event.data as ScaleConnectionData;
    print('Connected: ${conn.connected}');
  }
});
```

### Zero Operation

```dart
await IminScaleNew.zero();
```

### Tare Operation

```dart
await IminScaleNew.tare();
```

### Digital Tare

```dart
await IminScaleNew.digitalTare(100); // Tare 100g
```

### Set Unit Price

```dart
await IminScaleNew.setUnitPrice('9.99');
```

### Set Unit

```dart
await IminScaleNew.setUnit(ScaleUnit.kg);
```

Available units:
- `ScaleUnit.g` - Grams
- `ScaleUnit.g100` - 100 grams
- `ScaleUnit.g500` - 500 grams
- `ScaleUnit.kg` - Kilograms

### Device Operations

```dart
// Read accelerometer data
List<int> accelData = await IminScaleNew.readAcceleData();

// Read seal state
int sealState = await IminScaleNew.readSealState();

// Get calibration status
int calStatus = await IminScaleNew.getCalStatus();

// Get calibration info
List<List<int>> calInfo = await IminScaleNew.getCalInfo();

// Restart scale
await IminScaleNew.restart();
```

## Data Models

### ScaleWeightData

```dart
class ScaleWeightData {
  final double net;        // Net weight in kg
  final double tare;       // Tare weight in kg
  final bool isStable;     // Weight is stable
}
```

### ScaleStatusData

```dart
class ScaleStatusData {
  final bool overload;         // Scale overloaded
  final bool isLightWeight;    // Weight too light
  final bool clearZeroErr;     // Zero error
  final bool calibrationErr;   // Calibration error
}
```

### ScalePriceData

```dart
class ScalePriceData {
  final String unitPrice;    // Unit price
  final String totalPrice;   // Total price
  final String unitName;     // Unit name
}
```

## Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class ScaleExample extends StatefulWidget {
  @override
  _ScaleExampleState createState() => _ScaleExampleState();
}

class _ScaleExampleState extends State<ScaleExample> {
  bool _isConnected = false;
  bool _isGettingData = false;
  ScaleWeightData? _currentWeight;
  StreamSubscription<ScaleEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
    _connectService();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    IminScaleNew.cancelGetData();
    super.dispose();
  }

  void _listenToEvents() {
    _subscription = IminScaleNew.eventStream.listen((event) {
      if (event.isWeight) {
        setState(() => _currentWeight = event.data as ScaleWeightData);
      } else if (event.isConnection) {
        final conn = event.data as ScaleConnectionData;
        setState(() => _isConnected = conn.connected);
      }
    });
  }

  Future<void> _connectService() async {
    final success = await IminScaleNew.connectService();
    if (success) {
      await Future.delayed(Duration(milliseconds: 500));
      _startGetData();
    }
  }

  Future<void> _startGetData() async {
    final success = await IminScaleNew.getData();
    setState(() => _isGettingData = success);
  }

  Future<void> _stopGetData() async {
    await IminScaleNew.cancelGetData();
    setState(() => _isGettingData = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Connected: $_isConnected'),
        Text('Getting Data: $_isGettingData'),
        if (_currentWeight != null) ...[
          Text('Net: ${_currentWeight!.net.toStringAsFixed(3)} kg'),
          Text('Tare: ${_currentWeight!.tare.toStringAsFixed(3)} kg'),
          Text('Stable: ${_currentWeight!.isStable ? "✓" : "~"}'),
        ],
        ElevatedButton(
          onPressed: _isConnected ? () => IminScaleNew.zero() : null,
          child: Text('Zero'),
        ),
        ElevatedButton(
          onPressed: _isConnected ? () => IminScaleNew.tare() : null,
          child: Text('Tare'),
        ),
      ],
    );
  }
}
```

## Notes

- Requires Android 13 or higher
- Connect to service before operations
- Weight data streams continuously when active
- Stop getting data when not needed
- Handle errors appropriately

## Supported Devices

iMin devices with electronic scale support (Android 13+)
