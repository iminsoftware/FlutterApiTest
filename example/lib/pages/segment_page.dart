import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class SegmentPage extends StatefulWidget {
  const SegmentPage({super.key});

  @override
  State<SegmentPage> createState() => _SegmentPageState();
}

class _SegmentPageState extends State<SegmentPage> {
  final TextEditingController _dataController = TextEditingController();
  final List<String> _history = [];
  bool _isConnected = false;
  String _deviceInfo = '';
  String _alignMode = 'right';

  @override
  void dispose() {
    _dataController.dispose();
    // 退出页面时断开连接
    if (_isConnected) {
      IminSegment.disconnect().catchError((_) {});
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize device info with localized text
    if (_deviceInfo.isEmpty) {
      final l10n = AppLocalizations.of(context);
      _deviceInfo = l10n.noDeviceFound;
    }
  }

  Future<void> _findDevice() async {
    final l10n = AppLocalizations.of(context);
    try {
      final result = await IminSegment.findDevice();
      setState(() {
        if (result['found'] == true) {
          _deviceInfo = '${l10n.deviceFound}\n'
              'PID: ${result['productId']}\n'
              'VID: ${result['vendorId']}\n'
              'Name: ${result['deviceName']}';
        } else {
          _deviceInfo = l10n.noSegmentDeviceFound;
        }
      });
      _showMessage(_deviceInfo);
    } catch (e) {
      _showError('${l10n.findDeviceFailed}: $e');
    }
  }

  Future<void> _requestPermission() async {
    final l10n = AppLocalizations.of(context);
    try {
      final granted = await IminSegment.requestPermission();
      if (granted) {
        _showMessage(l10n.usbPermissionGranted);
      } else {
        _showError(l10n.usbPermissionDenied);
      }
    } catch (e) {
      _showError('${l10n.requestPermissionFailed}: $e');
    }
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Step 1: Find device
      final result = await IminSegment.findDevice();
      if (result['found'] != true) {
        _showError(l10n.noSegmentDeviceFound);
        return;
      }
      setState(() {
        _deviceInfo = '${l10n.deviceFound}\n'
            'PID: ${result['productId']}\n'
            'VID: ${result['vendorId']}\n'
            'Name: ${result['deviceName']}';
      });

      // Step 2: Request permission
      final granted = await IminSegment.requestPermission();
      if (!granted) {
        _showError(l10n.usbPermissionDenied);
        return;
      }

      // Step 3: Connect
      final success = await IminSegment.connect();
      setState(() {
        _isConnected = success;
      });
      if (success) {
        _showMessage(l10n.connectedToSegment);
      } else {
        _showError(l10n.failedToConnect);
      }
    } catch (e) {
      _showError('${l10n.connectFailed}: $e');
    }
  }

  Future<void> _sendData() async {
    final l10n = AppLocalizations.of(context);
    final data = _dataController.text;
    if (data.isEmpty) {
      _showError(l10n.pleaseEnterData);
      return;
    }

    if (!_isConnected) {
      _showError(l10n.pleaseConnectFirst);
      return;
    }

    try {
      await IminSegment.sendData(data, align: _alignMode);
      setState(() {
        _history.add('${_alignMode == 'left' ? '←' : '→'} $data');
      });
      _showMessage('${l10n.dataSent}: $data');
    } catch (e) {
      _showError('${l10n.sendDataFailed}: $e');
    }
  }

  Future<void> _clear() async {
    final l10n = AppLocalizations.of(context);
    if (!_isConnected) {
      _showError(l10n.pleaseConnectFirst);
      return;
    }

    try {
      await IminSegment.clear();
      setState(() {
        _history.add('🗑️ ${l10n.clearDisplayAction}');
      });
      _showMessage(l10n.displayCleared);
    } catch (e) {
      _showError('${l10n.clearFailed}: $e');
    }
  }

  Future<void> _full() async {
    final l10n = AppLocalizations.of(context);
    if (!_isConnected) {
      _showError(l10n.pleaseConnectFirst);
      return;
    }

    try {
      await IminSegment.full();
      setState(() {
        _history.add('💡 ${l10n.fullDisplayTest}');
      });
      _showMessage(l10n.displaySetToFull);
    } catch (e) {
      _showError('${l10n.fullDisplayFailed}: $e');
    }
  }

  Future<void> _disconnect() async {
    final l10n = AppLocalizations.of(context);
    try {
      await IminSegment.disconnect();
      setState(() {
        _isConnected = false;
      });
      _showMessage(l10n.disconnectedFromDevice);
    } catch (e) {
      _showError('${l10n.disconnectFailed}: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.segmentDisplay),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link : Icons.link_off),
            onPressed: null,
            tooltip: _isConnected ? l10n.connected : l10n.disconnected,
          ),
        ],
      ),
      body: Column(
        children: [
          // Device Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deviceInformation,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(_deviceInfo),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _findDevice,
                          icon: const Icon(Icons.search),
                          label: Text(l10n.findDevice),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.security),
                          label: Text(l10n.permission),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isConnected ? _disconnect : _connect,
                      icon: Icon(_isConnected ? Icons.link_off : Icons.link),
                      label:
                          Text(_isConnected ? l10n.disconnect : l10n.connect),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isConnected ? Colors.orange : Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.displayControl,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dataController,
                    decoration: InputDecoration(
                      labelText: l10n.dataToDisplay,
                      hintText: l10n.enterDataToDisplay,
                      border: const OutlineInputBorder(),
                      helperText: l10n.numbersLettersSupported,
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.alignment),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(l10n.rightAlign),
                          value: 'right',
                          groupValue: _alignMode,
                          onChanged: (value) {
                            setState(() {
                              _alignMode = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(l10n.leftAlign),
                          value: 'left',
                          groupValue: _alignMode,
                          onChanged: (value) {
                            setState(() {
                              _alignMode = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sendData,
                          icon: const Icon(Icons.send),
                          label: Text(l10n.send),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                          label: Text(l10n.clear),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _full,
                          icon: const Icon(Icons.lightbulb),
                          label: Text(l10n.full),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // History Card
          Expanded(
            child: Card(
              margin: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.history,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _history.clear();
                            });
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.clear),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noHistoryYet,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(_history[index]),
                                dense: true,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
