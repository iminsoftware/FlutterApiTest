import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  @override
  State<LightPage> createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  bool _isConnected = false;
  String _statusMessage = 'Not connected';
  LightColor _currentLight = LightColor.off;

  Future<void> _connect() async {
    try {
      final success = await IminLight.connect();
      if (mounted) {
        setState(() {
          _isConnected = success;
          _statusMessage = success
              ? 'Connected to light device'
              : 'Failed to connect. Please check USB connection.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _turnOnGreen() async {
    try {
      final success = await IminLight.turnOnGreen();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.green;
            _statusMessage = 'Green light is ON';
          } else {
            _statusMessage = 'Failed to turn on green light';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _turnOnRed() async {
    try {
      final success = await IminLight.turnOnRed();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.red;
            _statusMessage = 'Red light is ON';
          } else {
            _statusMessage = 'Failed to turn on red light';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _turnOff() async {
    try {
      final success = await IminLight.turnOff();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.off;
            _statusMessage = 'Light is OFF';
          } else {
            _statusMessage = 'Failed to turn off light';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      final success = await IminLight.disconnect();
      if (mounted) {
        setState(() {
          _isConnected = false;
          _currentLight = LightColor.off;
          _statusMessage = success
              ? 'Disconnected from light device'
              : 'Failed to disconnect';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Light Control'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.usb : Icons.usb_off,
                          size: 48,
                          color: _isConnected ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isConnected ? 'CONNECTED' : 'DISCONNECTED',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color: _isConnected
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _statusMessage,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Light Indicator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Current Light Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getLightColor(),
                        boxShadow: _currentLight != LightColor.off
                            ? [
                                BoxShadow(
                                  color: _getLightColor().withAlpha(128),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.lightbulb,
                          size: 60,
                          color: _currentLight != LightColor.off
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getLightStatusText(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _getLightColor(),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Connection Controls
            if (!_isConnected) ...[
              ElevatedButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.usb),
                label: const Text('Connect Device'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              // Light Controls
              Text(
                'Light Controls',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _turnOnGreen,
                icon: const Icon(Icons.lightbulb),
                label: const Text('Turn On Green Light'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _turnOnRed,
                icon: const Icon(Icons.lightbulb),
                label: const Text('Turn On Red Light'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _turnOff,
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Turn Off Light'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.usb_off),
                label: const Text('Disconnect Device'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Tips
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Tips',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Connect USB light device first\n'
                      '• Grant USB permission when prompted\n'
                      '• Green light: Success/Ready state\n'
                      '• Red light: Error/Busy state\n'
                      '• Supported devices: Crane 1, M2-Pro',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getLightColor() {
    switch (_currentLight) {
      case LightColor.green:
        return Colors.green;
      case LightColor.red:
        return Colors.red;
      case LightColor.off:
        return Colors.grey[300]!;
    }
  }

  String _getLightStatusText() {
    switch (_currentLight) {
      case LightColor.green:
        return 'GREEN LIGHT ON';
      case LightColor.red:
        return 'RED LIGHT ON';
      case LightColor.off:
        return 'LIGHT OFF';
    }
  }
}

enum LightColor {
  off,
  green,
  red,
}
