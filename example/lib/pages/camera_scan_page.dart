import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key});

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> {
  String _lastResult = '';
  String _lastFormat = '';
  final List<Map<String, String>> _scanHistory = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        _showError(AppLocalizations.of(context).cameraPermissionRequired);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cameraScan),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Last Scan Result Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.lastScanResult,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_lastResult.isNotEmpty) ...[
                      Text('${l10n.format}: $_lastFormat'),
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.code}: $_lastResult',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ] else
                      Text(l10n.noScanResult),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Single scan button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanAll,
                icon: const Icon(Icons.document_scanner, size: 28),
                label: Text(
                  l10n.scanAllFormats,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Scan History
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.scanHistory} (${_scanHistory.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_scanHistory.isNotEmpty)
                  TextButton(
                    onPressed: _clearHistory,
                    child: Text(l10n.clear),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_scanHistory.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(l10n.noScanHistory),
                ),
              )
            else
              ..._scanHistory.reversed.take(10).map((scan) => Card(
                    child: ListTile(
                      leading: Icon(
                        scan['format'] == 'QR_CODE'
                            ? Icons.qr_code
                            : Icons.barcode_reader,
                      ),
                      title: Text(scan['code']!),
                      subtitle: Text(scan['format']!),
                      trailing: Text(scan['time']!),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _scanAll() async {
    setState(() => _isScanning = true);
    try {
      final result = await CameraScanApi.scanAll();
      _handleScanResult(result['code'], result['format']);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _handleScanResult(String code, String format) {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _lastResult = code;
      _lastFormat = format;
      _scanHistory.add({
        'code': code,
        'format': format,
        'time': TimeOfDay.now().format(context),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${l10n.scanned}: $code'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _clearHistory() {
    setState(() {
      _scanHistory.clear();
    });
  }
}
