import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class CashBoxPage extends StatefulWidget {
  const CashBoxPage({super.key});

  @override
  State<CashBoxPage> createState() => _CashBoxPageState();
}

class _CashBoxPageState extends State<CashBoxPage> {
  bool _isOpen = false;
  String _statusMessage = 'Ready';
  CashBoxVoltage _selectedVoltage = CashBoxVoltage.v12;
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
    // 每秒轮询钱箱状态
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkStatus();
    });
    // 立即检查一次
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final isOpen = await IminCashBox.getStatus();
      if (mounted) {
        setState(() {
          _isOpen = isOpen;
        });
      }
    } catch (e) {
      // 静默失败，避免频繁显示错误
    }
  }

  Future<void> _openCashBox() async {
    try {
      final success = await IminCashBox.open();
      if (mounted) {
        setState(() {
          _statusMessage = success
              ? 'Cash box opened successfully'
              : 'Failed to open cash box';
        });
      }
      // 立即检查状态
      await _checkStatus();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  Future<void> _setVoltage() async {
    try {
      final success = await IminCashBox.setVoltage(_selectedVoltage);
      if (mounted) {
        setState(() {
          _statusMessage = success
              ? 'Voltage set to ${_selectedVoltage.value}'
              : 'Failed to set voltage';
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
        title: const Text('Cash Box Control'),
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
                      'Cash Box Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isOpen ? Icons.lock_open : Icons.lock,
                          size: 48,
                          color: _isOpen ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isOpen ? 'OPEN' : 'CLOSED',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color:
                                          _isOpen ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Status updates every second',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(_statusMessage),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Open Cash Box Button
            ElevatedButton.icon(
              onPressed: _openCashBox,
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Open Cash Box'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),

            // Voltage Settings
            Text(
              'Voltage Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select voltage for cash box:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<CashBoxVoltage>(
                      title: const Text('9V'),
                      value: CashBoxVoltage.v9,
                      groupValue: _selectedVoltage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVoltage = value;
                          });
                        }
                      },
                    ),
                    RadioListTile<CashBoxVoltage>(
                      title: const Text('12V'),
                      value: CashBoxVoltage.v12,
                      groupValue: _selectedVoltage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVoltage = value;
                          });
                        }
                      },
                    ),
                    RadioListTile<CashBoxVoltage>(
                      title: const Text('24V'),
                      value: CashBoxVoltage.v24,
                      groupValue: _selectedVoltage,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedVoltage = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _setVoltage,
              icon: const Icon(Icons.settings),
              label: Text('Set Voltage to ${_selectedVoltage.value}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
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
                      '• Connect a cash drawer to test\n'
                      '• Status updates automatically every second\n'
                      '• Set voltage according to your cash drawer specs\n'
                      '• Common voltage: 12V (default)',
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
}
