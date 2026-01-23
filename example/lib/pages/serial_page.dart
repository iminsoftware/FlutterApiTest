import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

/// Serial Port Test Page
///
/// Based on IMinApiTest SerialActivity implementation
class SerialPage extends StatefulWidget {
  const SerialPage({Key? key}) : super(key: key);

  @override
  State<SerialPage> createState() => _SerialPageState();
}

class _SerialPageState extends State<SerialPage> {
  final TextEditingController _pathController =
      TextEditingController(text: '/dev/ttyS4');
  final TextEditingController _baudRateController =
      TextEditingController(text: '115200');
  final TextEditingController _dataController = TextEditingController();

  bool _isOpen = false;
  bool _isLoading = false;
  final List<String> _receivedData = [];
  int _dataCount = 0;

  @override
  void initState() {
    super.initState();
    _listenToSerialData();
  }

  @override
  void dispose() {
    _closePort();
    _pathController.dispose();
    _baudRateController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  void _listenToSerialData() {
    IminSerial.dataStream.listen(
      (data) {
        setState(() {
          _dataCount++;
          final dataStr = '$_dataCount: ${data.data}';
          _receivedData.insert(0, dataStr);

          // Limit history to 50 items
          if (_receivedData.length > 50) {
            _receivedData.removeLast();
          }
        });
      },
      onError: (error) {
        _showMessage(_t('Error receiving data: $error', '接收数据错误: $error'),
            isError: true);
      },
    );
  }

  Future<void> _openPort() async {
    final path = _pathController.text.trim();
    final baudRateStr = _baudRateController.text.trim();

    if (path.isEmpty) {
      _showMessage(_t('Please enter serial port path', '请输入串口路径'),
          isError: true);
      return;
    }

    final baudRate = int.tryParse(baudRateStr);
    if (baudRate == null) {
      _showMessage(_t('Invalid baud rate', '无效的波特率'), isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await IminSerial.open(
        path: path,
        baudRate: baudRate,
      );

      if (success) {
        setState(() => _isOpen = true);
        _showMessage(_t('Serial port opened: $path @ $baudRate',
            '串口已打开: $path @ $baudRate'));
      } else {
        _showMessage(_t('Failed to open serial port', '打开串口失败'), isError: true);
      }
    } catch (e) {
      _showMessage(_t('Error: $e', '错误: $e'), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _closePort() async {
    if (!_isOpen) return;

    setState(() => _isLoading = true);

    try {
      final success = await IminSerial.close();
      if (success) {
        setState(() => _isOpen = false);
        _showMessage(_t('Serial port closed', '串口已关闭'));
      }
    } catch (e) {
      _showMessage(_t('Error: $e', '错误: $e'), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _writeData() async {
    if (!_isOpen) {
      _showMessage(_t('Serial port is not open', '串口未打开'), isError: true);
      return;
    }

    final dataStr = _dataController.text.trim();
    if (dataStr.isEmpty) {
      _showMessage(_t('Please enter data to send', '请输入要发送的数据'), isError: true);
      return;
    }

    try {
      // Convert string to bytes (UTF-8)
      final bytes = Uint8List.fromList(dataStr.codeUnits);
      final success = await IminSerial.write(bytes);

      if (success) {
        _showMessage(
            _t('Sent ${bytes.length} bytes', '已发送 ${bytes.length} 字节'));
        _dataController.clear();
      } else {
        _showMessage(_t('Failed to write data', '发送数据失败'), isError: true);
      }
    } catch (e) {
      _showMessage(_t('Error: $e', '错误: $e'), isError: true);
    }
  }

  Future<void> _writeHexData() async {
    if (!_isOpen) {
      _showMessage(_t('Serial port is not open', '串口未打开'), isError: true);
      return;
    }

    final dataStr = _dataController.text.trim();
    if (dataStr.isEmpty) {
      _showMessage(_t('Please enter hex data to send', '请输入要发送的十六进制数据'),
          isError: true);
      return;
    }

    try {
      // Parse hex string (e.g., "01 02 03" or "010203")
      final hexStr = dataStr.replaceAll(' ', '');
      if (hexStr.length % 2 != 0) {
        _showMessage(
            _t('Invalid hex string (must be even length)',
                '无效的十六进制字符串（长度必须为偶数）'),
            isError: true);
        return;
      }

      final bytes = Uint8List(hexStr.length ~/ 2);
      for (int i = 0; i < hexStr.length; i += 2) {
        bytes[i ~/ 2] = int.parse(hexStr.substring(i, i + 2), radix: 16);
      }

      final success = await IminSerial.write(bytes);
      if (success) {
        _showMessage(_t('Sent ${bytes.length} bytes (hex)',
            '已发送 ${bytes.length} 字节（十六进制）'));
        _dataController.clear();
      } else {
        _showMessage(_t('Failed to write data', '发送数据失败'), isError: true);
      }
    } catch (e) {
      _showMessage(_t('Error: $e', '错误: $e'), isError: true);
    }
  }

  void _clearData() {
    setState(() {
      _receivedData.clear();
      _dataCount = 0;
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // Localization helper
  String _t(String en, String zh) {
    // Simple language detection based on system locale
    // You can enhance this with proper localization package
    return zh; // Default to Chinese for iMin devices
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Serial Port Test', '串口测试')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                            _t('Serial Port Status', '串口状态'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isOpen ? Icons.check_circle : Icons.error,
                                color: _isOpen ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isOpen
                                    ? _t('Open', '已打开')
                                    : _t('Closed', '已关闭'),
                                style: TextStyle(
                                  color: _isOpen ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Configuration
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Configuration', '配置'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _pathController,
                            decoration: InputDecoration(
                              labelText: _t('Serial Port Path', '串口路径'),
                              hintText: '/dev/ttyS4',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.cable),
                            ),
                            enabled: !_isOpen,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _baudRateController,
                            decoration: InputDecoration(
                              labelText: _t('Baud Rate', '波特率'),
                              hintText: '115200',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.speed),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: !_isOpen,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isOpen ? null : _openPort,
                                  icon: const Icon(Icons.power),
                                  label: Text(_t('Open Port', '打开串口')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isOpen ? _closePort : null,
                                  icon: const Icon(Icons.power_off),
                                  label: Text(_t('Close Port', '关闭串口')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Send Data
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Send Data', '发送数据'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _dataController,
                            decoration: InputDecoration(
                              labelText: _t('Data', '数据'),
                              hintText: _t('Enter text or hex (e.g., 01 02 03)',
                                  '输入文本或十六进制 (如: 01 02 03)'),
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.edit),
                            ),
                            maxLines: 2,
                            enabled: _isOpen,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isOpen ? _writeData : null,
                                  icon: const Icon(Icons.send),
                                  label: Text(_t('Send Text', '发送文本')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isOpen ? _writeHexData : null,
                                  icon: const Icon(Icons.hexagon),
                                  label: Text(_t('Send Hex', '发送十六进制')),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Received Data
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _t('Received Data', '接收数据'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _clearData,
                                icon: const Icon(Icons.clear_all),
                                label: Text(_t('Clear', '清空')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 300,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _receivedData.isEmpty
                                ? Center(
                                    child: Text(
                                      _t('No data received yet', '暂无接收数据'),
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _receivedData.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        dense: true,
                                        title: Text(
                                          _receivedData[index],
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info Card
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('Common Serial Ports', '常用串口'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _t(
                              '• /dev/ttyS4 - Default serial port\n'
                                  '• /dev/ttyUSB0 - USB serial adapter\n'
                                  '• Baud rates: 9600, 19200, 38400, 57600, 115200',
                              '• /dev/ttyS4 - 默认串口\n'
                                  '• /dev/ttyUSB0 - USB 串口适配器\n'
                                  '• 波特率: 9600, 19200, 38400, 57600, 115200',
                            ),
                            style: const TextStyle(fontSize: 13),
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
