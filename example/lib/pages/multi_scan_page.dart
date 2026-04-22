import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';

class MultiScanPage extends StatefulWidget {
  const MultiScanPage({super.key});

  @override
  State<MultiScanPage> createState() => _MultiScanPageState();
}

class _MultiScanPageState extends State<MultiScanPage> {
  bool? _mlkitAvailable;
  bool _isScanning = false;
  List<Map<String, dynamic>> _multiResults = [];
  Map<String, dynamic>? _lastSingle;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _checkMLKit();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted && mounted) {
      _showError(AppLocalizations.of(context).cameraPermissionRequired);
    }
  }

  Future<void> _checkMLKit() async {
    try {
      final available = await CameraScanApi.isMLKitAvailable();
      if (mounted) setState(() => _mlkitAvailable = available);
    } catch (e) {
      if (mounted) setState(() => _mlkitAvailable = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.multiScan),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ML Kit 状态
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ML Kit ${l10n.status}',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          _mlkitAvailable == null
                              ? l10n.checking
                              : _mlkitAvailable!
                                  ? '✅ ${l10n.ready}'
                                  : '❌ ZXing Only',
                          style: TextStyle(
                            color: _mlkitAvailable == true
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _checkMLKit,
                        child: Text(l10n.multiScanRefresh),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 原有 scan() 接口测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.multiScanOriginalApi,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isScanning ? null : _doSingleScan,
                      child: Text(_isScanning
                          ? l10n.multiScanScanning
                          : 'CameraScan.scan()'),
                    ),
                    if (_lastSingle != null) ...[
                      const SizedBox(height: 12),
                      _buildResultCard(
                          _lastSingle!['code'], _lastSingle!['format']),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 新 scanMulti() 接口测试
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.multiScanNewApi,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),

                    // 默认多码同扫
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _doMultiScan,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white),
                        child: Text(l10n.multiScanDefault),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 多角度扫码
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _doMultiAngleScan,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white),
                        child: Text(l10n.multiAngleScan),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 自定义配置
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isScanning ? null : _doCustomMultiScan,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white),
                        child: Text(l10n.customMultiScan),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 多码扫描结果
            if (_multiResults.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${l10n.multiScanResults} (${_multiResults.length})',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      ..._multiResults
                          .asMap()
                          .entries
                          .map((entry) => _buildResultCard(
                                entry.value['code'] ?? '',
                                entry.value['format'] ?? '',
                                index: entry.key + 1,
                              )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(String code, String format, {int? index}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: Colors.blue, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index != null ? '#$index [$format]' : format,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          SelectableText(
            code,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _doSingleScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final data = await CameraScanApi.scanAll();
      setState(() => _lastSingle = data);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _doMultiScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final results = await CameraScanApi.scanMulti();
      setState(() => _multiResults = results);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _doMultiAngleScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final results = await CameraScanApi.scanMulti(const MultiScanOptions(
        supportMultiAngle: true,
        supportMultiBarcode: false,
        fullAreaScan: true,
      ));
      setState(() => _multiResults = results);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _doCustomMultiScan() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final results = await CameraScanApi.scanMulti(const MultiScanOptions(
        formats: ['QR_CODE', 'EAN_13', 'CODE_128'],
        supportMultiBarcode: true,
        supportMultiAngle: true,
        useFlash: false,
        beepEnabled: true,
        fullAreaScan: true,
        areaRectRatio: 0.9,
        timeout: 30000,
      ));
      setState(() => _multiResults = results);
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isScanning = false);
    }
  }

  void _showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.red),
    );
  }
}
