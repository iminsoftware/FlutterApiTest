import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class LightPage extends StatefulWidget {
  const LightPage({super.key});

  @override
  State<LightPage> createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  bool _isConnected = false;
  String _statusMessage = '';
  LightColor _currentLight = LightColor.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      setState(() {
        _statusMessage = l10n.notConnected;
      });
    });
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);

    try {
      final success = await IminLight.connect();
      if (mounted) {
        setState(() {
          _isConnected = success;
          _statusMessage =
              success ? l10n.connectedToDevice : l10n.failedToConnect;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  Future<void> _turnOnGreen() async {
    final l10n = AppLocalizations.of(context);

    try {
      final success = await IminLight.turnOnGreen();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.green;
            _statusMessage = l10n.greenLightOn;
          } else {
            _statusMessage = l10n.failedToTurnOnGreen;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  Future<void> _turnOnRed() async {
    final l10n = AppLocalizations.of(context);

    try {
      final success = await IminLight.turnOnRed();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.red;
            _statusMessage = l10n.redLightOn;
          } else {
            _statusMessage = l10n.failedToTurnOnRed;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  Future<void> _turnOff() async {
    final l10n = AppLocalizations.of(context);

    try {
      final success = await IminLight.turnOff();
      if (mounted) {
        setState(() {
          if (success) {
            _currentLight = LightColor.off;
            _statusMessage = l10n.lightOff;
          } else {
            _statusMessage = l10n.failedToTurnOff;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context);

    try {
      final success = await IminLight.disconnect();
      if (mounted) {
        setState(() {
          _isConnected = false;
          _currentLight = LightColor.off;
          _statusMessage =
              success ? l10n.disconnectedFromDevice : l10n.failedToDisconnect;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.lightControl),
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
                      l10n.deviceStatus,
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
                                _isConnected
                                    ? l10n.connected
                                    : l10n.disconnected,
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
                      l10n.currentLightStatus,
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
                label: Text(l10n.connectDevice),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ] else ...[
              // Light Controls
              Text(
                l10n.lightControls,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _turnOnGreen,
                icon: const Icon(Icons.lightbulb),
                label: Text(l10n.turnOnGreenLight),
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
                label: Text(l10n.turnOnRedLight),
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
                label: Text(l10n.turnOffLight),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.usb_off),
                label: Text(l10n.disconnectDevice),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Tips
            Card(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          l10n.tips,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.lightTips,
                      style: const TextStyle(color: Colors.white),
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
    final l10n = AppLocalizations.of(context);

    switch (_currentLight) {
      case LightColor.green:
        return l10n.greenLightOnStatus;
      case LightColor.red:
        return l10n.redLightOnStatus;
      case LightColor.off:
        return l10n.lightOffStatus;
    }
  }
}

enum LightColor {
  off,
  green,
  red,
}
