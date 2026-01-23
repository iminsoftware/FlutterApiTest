import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({super.key});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  bool _isListening = false;
  String _statusMessage = 'Checking NFC status...';
  NfcTag? _currentTag;
  final List<NfcTag> _tagHistory = [];
  StreamSubscription<NfcTag>? _tagSubscription;

  @override
  void initState() {
    super.initState();
    _checkNfcStatus();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkNfcStatus() async {
    try {
      final available = await IminNfc.isAvailable();
      final enabled = await IminNfc.isEnabled();

      if (mounted) {
        setState(() {
          _isAvailable = available;
          _isEnabled = enabled;
          _statusMessage = _getStatusMessage();
        });

        // Auto start listening if NFC is available and enabled
        if (available && enabled && !_isListening) {
          _startListening();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Error: $e';
        });
      }
    }
  }

  String _getStatusMessage() {
    if (!_isAvailable) {
      return 'NFC not available on this device';
    }
    if (!_isEnabled) {
      return 'NFC is disabled. Please enable it in settings.';
    }
    if (_isListening) {
      return 'Ready to scan NFC tags';
    }
    return 'NFC is available and enabled';
  }

  void _startListening() {
    if (_isListening) return;

    setState(() {
      _isListening = true;
      _statusMessage = 'Ready to scan NFC tags';
    });

    _tagSubscription = IminNfc.tagStream.listen(
      (tag) {
        if (mounted) {
          setState(() {
            _currentTag = tag;
            _tagHistory.insert(0, tag);
            // Keep only last 20 tags
            if (_tagHistory.length > 20) {
              _tagHistory.removeLast();
            }
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _statusMessage = 'Error: $error';
          });
        }
      },
    );
  }

  void _stopListening() {
    _tagSubscription?.cancel();
    _tagSubscription = null;
    setState(() {
      _isListening = false;
      _statusMessage = _getStatusMessage();
    });
  }

  Future<void> _openSettings() async {
    try {
      await IminNfc.openSettings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _clearHistory() {
    setState(() {
      _tagHistory.clear();
      _currentTag = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('NFC Reader'),
        actions: [
          if (_tagHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _clearHistory,
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _checkNfcStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              _buildStatusCard(),
              const SizedBox(height: 16),

              // Current Tag Display
              if (_currentTag != null) ...[
                _buildCurrentTagCard(),
                const SizedBox(height: 16),
              ],

              // Control Buttons
              _buildControlButtons(),
              const SizedBox(height: 24),

              // History Section
              if (_tagHistory.isNotEmpty) ...[
                Text(
                  'Scan History (${_tagHistory.length})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                ..._tagHistory.map((tag) => _buildHistoryItem(tag)),
              ],

              // Tips
              const SizedBox(height: 24),
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NFC Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _isAvailable && _isEnabled ? Icons.nfc : Icons.nfc_outlined,
                  size: 48,
                  color:
                      _isAvailable && _isEnabled ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAvailable ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: _isAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isAvailable ? 'Available' : 'Not Available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _isEnabled ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: _isEnabled ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isEnabled ? 'Enabled' : 'Disabled',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _statusMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTagCard() {
    final tag = _currentTag!;
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nfc, color: Colors.blue, size: 32),
                const SizedBox(width: 8),
                Text(
                  'Current Tag',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // NFC ID
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NFC ID',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tag.formattedId,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[900],
                                ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(tag.id),
                  tooltip: 'Copy ID',
                ),
              ],
            ),
            if (tag.content.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Content',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                tag.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatTime(tag.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                if (tag.technology.isNotEmpty) ...[
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tag.technology,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_isAvailable) ...[
          const Card(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'NFC is not available on this device',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ] else if (!_isEnabled) ...[
          ElevatedButton.icon(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Open NFC Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ] else ...[
          if (!_isListening)
            ElevatedButton.icon(
              onPressed: _startListening,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _stopListening,
              icon: const Icon(Icons.stop),
              label: const Text('Stop Scanning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
        ],
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _checkNfcStatus,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh Status'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(NfcTag tag) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.nfc, color: Colors.blue),
        title: Text(
          tag.formattedId,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(_formatTime(tag.timestamp)),
        trailing: IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () => _copyToClipboard(tag.id),
        ),
        onTap: () {
          setState(() {
            _currentTag = tag;
          });
        },
      ),
    );
  }

  Widget _buildTipsCard() {
    return const Card(
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
              '• Enable NFC in device settings\n'
              '• Hold NFC card close to the device\n'
              '• Card will be read automatically\n'
              '• Tap history items to view details\n'
              '• Supported: Crane 1, Swan 1/2, Swift 1/2, etc.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
