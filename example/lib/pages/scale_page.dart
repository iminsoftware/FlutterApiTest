import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/src/scale/scale_api.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';

class ScalePage extends StatefulWidget {
  const ScalePage({super.key});

  @override
  State<ScalePage> createState() => _ScalePageState();
}

class _ScalePageState extends State<ScalePage> {
  bool _isConnected = false;
  String _weight = '0.000';
  ScaleStatus _status = ScaleStatus.unknown;
  String _devicePath = '/dev/ttyS4';
  StreamSubscription<ScaleData>? _subscription;

  final List<String> _devicePaths = [
    '/dev/ttyS1',
    '/dev/ttyS2',
    '/dev/ttyS3',
    '/dev/ttyS4',
    '/dev/ttyUSB0',
  ];

  @override
  void dispose() {
    _subscription?.cancel();
    if (_isConnected) {
      IminScale.disconnect();
    }
    super.dispose();
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    final success = await IminScale.connect(devicePath: _devicePath);
    if (success) {
      _subscription = IminScale.weightStream.listen((data) {
        setState(() {
          _weight = data.weight;
          _status = data.status;
        });
      });
      setState(() => _isConnected = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.scaleConnected)),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToConnectScale)),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await IminScale.disconnect();
    setState(() {
      _isConnected = false;
      _weight = '0.000';
      _status = ScaleStatus.unknown;
    });
  }

  Future<void> _tare() async {
    final l10n = AppLocalizations.of(context);
    if (_status == ScaleStatus.unstable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weightUnstable)),
      );
      return;
    }
    await IminScale.tare();
  }

  Future<void> _zero() async {
    final l10n = AppLocalizations.of(context);
    if (_status == ScaleStatus.unstable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.weightUnstable)),
      );
      return;
    }
    await IminScale.zero();
  }

  Color _getStatusColor() {
    switch (_status) {
      case ScaleStatus.stable:
        return Colors.green;
      case ScaleStatus.unstable:
        return Colors.orange;
      case ScaleStatus.overweight:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (_status) {
      case ScaleStatus.stable:
        return l10n.stable;
      case ScaleStatus.unstable:
        return l10n.unstable;
      case ScaleStatus.overweight:
        return l10n.overweight;
      default:
        return l10n.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.electronicScale)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _devicePath,
                      decoration: InputDecoration(
                        labelText: l10n.devicePath,
                        border: const OutlineInputBorder(),
                      ),
                      items: _devicePaths.map((path) {
                        return DropdownMenuItem(
                          value: path,
                          child: Text(path),
                        );
                      }).toList(),
                      onChanged: _isConnected
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() => _devicePath = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isConnected ? _disconnect : _connect,
                        child:
                            Text(_isConnected ? l10n.disconnect : l10n.connect),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _weight,
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getStatusText(context),
                      style: TextStyle(
                        fontSize: 20,
                        color: _getStatusColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _tare : null,
                    child: Text(l10n.tare),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isConnected ? _zero : null,
                    child: Text(l10n.zero),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
