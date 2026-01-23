import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class SegmentPage extends StatefulWidget {
  const SegmentPage({super.key});

  @override
  State<SegmentPage> createState() => _SegmentPageState();
}

class _SegmentPageState extends State<SegmentPage> {
  final TextEditingController _dataController = TextEditingController();
  final List<String> _history = [];
  bool _isConnected = false;
  String _deviceInfo = 'No device found';
  String _alignMode = 'right';

  @override
  void dispose() {
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _findDevice() async {
    try {
      final result = await IminSegment.findDevice();
      setState(() {
        if (result['found'] == true) {
          _deviceInfo = 'Device found:\n'
              'PID: ${result['productId']}\n'
              'VID: ${result['vendorId']}\n'
              'Name: ${result['deviceName']}';
        } else {
          _deviceInfo = 'No segment device found';
        }
      });
      _showMessage(_deviceInfo);
    } catch (e) {
      _showError('Find device failed: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final granted = await IminSegment.requestPermission();
      if (granted) {
        _showMessage('USB permission granted');
      } else {
        _showError('USB permission denied');
      }
    } catch (e) {
      _showError('Request permission failed: $e');
    }
  }

  Future<void> _connect() async {
    try {
      final success = await IminSegment.connect();
      setState(() {
        _isConnected = success;
      });
      if (success) {
        _showMessage('Connected to segment device');
      } else {
        _showError('Failed to connect');
      }
    } catch (e) {
      _showError('Connect failed: $e');
    }
  }

  Future<void> _sendData() async {
    final data = _dataController.text;
    if (data.isEmpty) {
      _showError('Please enter data to display');
      return;
    }

    if (!_isConnected) {
      _showError('Please connect to device first');
      return;
    }

    try {
      await IminSegment.sendData(data, align: _alignMode);
      setState(() {
        _history.add('${_alignMode == 'left' ? '←' : '→'} $data');
      });
      _showMessage('Data sent: $data');
    } catch (e) {
      _showError('Send data failed: $e');
    }
  }

  Future<void> _clear() async {
    if (!_isConnected) {
      _showError('Please connect to device first');
      return;
    }

    try {
      await IminSegment.clear();
      setState(() {
        _history.add('🗑️ Clear display');
      });
      _showMessage('Display cleared');
    } catch (e) {
      _showError('Clear failed: $e');
    }
  }

  Future<void> _full() async {
    if (!_isConnected) {
      _showError('Please connect to device first');
      return;
    }

    try {
      await IminSegment.full();
      setState(() {
        _history.add('💡 Full display (test)');
      });
      _showMessage('Display set to full');
    } catch (e) {
      _showError('Full display failed: $e');
    }
  }

  Future<void> _disconnect() async {
    try {
      await IminSegment.disconnect();
      setState(() {
        _isConnected = false;
      });
      _showMessage('Disconnected from device');
    } catch (e) {
      _showError('Disconnect failed: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segment Display'),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.link : Icons.link_off),
            onPressed: null,
            tooltip: _isConnected ? 'Connected' : 'Disconnected',
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
                  const Text(
                    'Device Information',
                    style: TextStyle(
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
                          label: const Text('Find Device'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _requestPermission,
                          icon: const Icon(Icons.security),
                          label: const Text('Permission'),
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
                      label: Text(_isConnected ? 'Disconnect' : 'Connect'),
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
                  const Text(
                    'Display Control',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dataController,
                    decoration: const InputDecoration(
                      labelText: 'Data to Display',
                      hintText: 'Enter text (max 9 chars)',
                      border: OutlineInputBorder(),
                      helperText: 'Numbers, letters, and symbols supported',
                    ),
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),
                  const Text('Alignment:'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Right'),
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
                          title: const Text('Left'),
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
                          label: const Text('Send'),
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
                          label: const Text('Clear'),
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
                          label: const Text('Full'),
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
                        const Text(
                          'History',
                          style: TextStyle(
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
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _history.isEmpty
                        ? const Center(
                            child: Text(
                              'No history yet',
                              style: TextStyle(color: Colors.grey),
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
