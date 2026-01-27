import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({Key? key}) : super(key: key);

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _isListening = false;
  bool _isConnected = false;
  StreamSubscription<ScannerEvent>? _scanSubscription;
  final List<ScanResult> _scanHistory = [];
  int _scanCount = 0;

  // Custom configuration
  final _actionController = TextEditingController(
    text: 'com.imin.scanner.api.RESULT_ACTION',
  );
  final _dataKeyController = TextEditingController(
    text: 'decode_data_str',
  );
  final _byteDataKeyController = TextEditingController(
    text: 'decode_data',
  );

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _actionController.dispose();
    _dataKeyController.dispose();
    _byteDataKeyController.dispose();
    if (_isListening) {
      IminScanner.stopListening();
    }
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final l10n = AppLocalizations.of(context);

    try {
      final connected = await IminScanner.isConnected();
      setState(() {
        _isConnected = connected;
      });
    } catch (e) {
      _showError('${l10n.error}: $e');
    }
  }

  Future<void> _configure() async {
    final l10n = AppLocalizations.of(context);

    try {
      await IminScanner.configure(
        action: _actionController.text.trim().isEmpty
            ? null
            : _actionController.text.trim(),
        dataKey: _dataKeyController.text.trim().isEmpty
            ? null
            : _dataKeyController.text.trim(),
        byteDataKey: _byteDataKeyController.text.trim().isEmpty
            ? null
            : _byteDataKeyController.text.trim(),
      );

      // 关闭键盘
      FocusScope.of(context).unfocus();
      _showSuccess(l10n.permissionGranted);
    } catch (e) {
      _showError('${l10n.error}: $e');
    }
  }

  Future<void> _startListening() async {
    final l10n = AppLocalizations.of(context);

    try {
      final started = await IminScanner.startListening();
      if (started) {
        setState(() {
          _isListening = true;
        });

        // Listen to scan stream
        _scanSubscription = IminScanner.scanStream.listen(
          (event) {
            if (event is ScanResult) {
              setState(() {
                _scanHistory.insert(0, event);
                _scanCount++;
                // Keep only last 50 scans
                if (_scanHistory.length > 50) {
                  _scanHistory.removeLast();
                }
              });
            } else if (event is ScannerConnected) {
              setState(() {
                _isConnected = true;
              });
              _showSuccess(l10n.scannerConnected);
            } else if (event is ScannerDisconnected) {
              setState(() {
                _isConnected = false;
              });
              _showError(l10n.scannerNotConnected);
            } else if (event is ScannerConnectionStatus) {
              setState(() {
                _isConnected = event.connected;
              });
            }
          },
          onError: (error) {
            _showError('${l10n.error}: $error');
          },
        );

        _showSuccess(l10n.startListening);
      } else {
        _showError(l10n.listening);
      }
    } catch (e) {
      _showError('${l10n.error}: $e');
    }
  }

  Future<void> _stopListening() async {
    final l10n = AppLocalizations.of(context);

    try {
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      final stopped = await IminScanner.stopListening();
      if (stopped) {
        setState(() {
          _isListening = false;
        });
        _showSuccess(l10n.stopListening);
      } else {
        _showError(l10n.notListening);
      }
    } catch (e) {
      _showError('${l10n.error}: $e');
    }
  }

  void _clearHistory() {
    setState(() {
      _scanHistory.clear();
      _scanCount = 0;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      // 点击空白处关闭键盘
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // 重要：让页面适应键盘
        appBar: AppBar(
          title: Text(l10n.scanner),
          actions: [
            // Connection status indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.usb : Icons.usb_off,
                    color: _isConnected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isConnected ? l10n.connected : l10n.disconnected,
                    style: TextStyle(
                      color: _isConnected ? Colors.green : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 使用 Expanded + SingleChildScrollView 让整个内容区域可滚动
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Configuration section
                      if (!_isListening)
                        Container(
                          color: Colors.grey[100],
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.customConfig,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _actionController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.broadcastAction,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _dataKeyController,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: l10n.stringDataKey,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _byteDataKeyController,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  _configure();
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.byteDataKey,
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _configure,
                                  child: Text(l10n.applyConfig),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (!_isListening) const Divider(height: 1),

                      // Control buttons
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isListening ? null : _startListening,
                                    icon: const Icon(Icons.play_arrow),
                                    label: Text(l10n.startListening),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        _isListening ? _stopListening : null,
                                    icon: const Icon(Icons.stop),
                                    label: Text(l10n.stopListening),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _checkConnection,
                                    icon: const Icon(Icons.refresh),
                                    label: Text(l10n.status),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _scanHistory.isEmpty
                                        ? null
                                        : _clearHistory,
                                    icon: const Icon(Icons.clear_all),
                                    label: Text(l10n.clear),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status info
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color:
                            _isListening ? Colors.green[50] : Colors.grey[100],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isListening
                                  ? '🟢 ${l10n.listening}'
                                  : '⚪ ${l10n.notListening}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _isListening ? Colors.green : Colors.grey,
                              ),
                            ),
                            Text(
                              '${l10n.scanCount}: $_scanCount',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      // Scan history - 使用固定高度
                      SizedBox(
                        height: 400, // 固定高度，确保有足够空间显示
                        child: _scanHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_scanner,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _isListening
                                          ? l10n.noScanData
                                          : l10n.scannerTips,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _scanHistory.length,
                                itemBuilder: (context, index) {
                                  final scan = _scanHistory[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.blue,
                                        child: Text(
                                          '${_scanCount - index}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        scan.data,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text('Type: ${scan.labelType}'),
                                          Text(
                                            '${l10n.timestamp}: ${_formatTime(scan.timestamp)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.copy, size: 20),
                                        onPressed: () {
                                          _showSuccess('Copied: ${scan.data}');
                                        },
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
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
