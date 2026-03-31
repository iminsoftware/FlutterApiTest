import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import 'dart:async';

class RfidPage extends StatefulWidget {
  const RfidPage({Key? key}) : super(key: key);

  @override
  State<RfidPage> createState() => _RfidPageState();
}

class _RfidPageState extends State<RfidPage> {
  bool _isConnected = false;
  bool _isReading = false;
  int _batteryLevel = 0;
  bool _isCharging = false;
  int _tagCount = 0;
  int _totalReadCount = 0;

  final List<RfidTag> _tags = [];
  final Map<String, RfidTag> _tagMap = {};

  StreamSubscription? _tagSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _batterySubscription;

  final _epcController = TextEditingController();
  final _dataController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _listenToStreams();
  }

  @override
  void dispose() {
    _tagSubscription?.cancel();
    _connectionSubscription?.cancel();
    _batterySubscription?.cancel();
    _epcController.dispose();
    _dataController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    try {
      final connected = await IminRfid.isConnected();
      setState(() => _isConnected = connected);

      if (connected) {
        final level = await IminRfid.getBatteryLevel();
        final charging = await IminRfid.isCharging();
        setState(() {
          _batteryLevel = level;
          _isCharging = charging;
        });
      }
    } catch (e) {
      _showError(_t('Check connection failed: $e', '检查连接失败: $e'));
    }
  }

  // Localization helper
  String _t(String en, String zh) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'zh' ? zh : en;
  }

  void _listenToStreams() {
    // 标签事件流
    _tagSubscription = IminRfid.tagStream.listen((event) {
      if (event.isTag && event.tag != null) {
        final tag = event.tag!;
        setState(() {
          _tagMap[tag.epc] = tag;
          _tags.clear();
          _tags.addAll(_tagMap.values);
          _tags.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _tagCount = _tags.length;
          _totalReadCount++;
        });
      } else if (event.isError) {
        _showError(_t('RFID error: ${event.errorMessage}',
            'RFID 错误: ${event.errorMessage}'));
      }
    });

    // 连接状态流
    _connectionSubscription = IminRfid.connectionStream.listen((connected) {
      setState(() => _isConnected = connected);
      if (connected) {
        _showSuccess(_t('RFID device connected', 'RFID 设备已连接'));
        _checkConnection();
      } else {
        _showError(_t('RFID device disconnected', 'RFID 设备已断开'));
      }
    });

    // 电池状态流
    _batterySubscription = IminRfid.batteryStream.listen((status) {
      setState(() {
        _batteryLevel = status.level;
        _isCharging = status.charging;
      });
    });
  }

  Future<void> _connect() async {
    try {
      await IminRfid.connect();
      _showSuccess(_t('Connecting RFID device...', '正在连接 RFID 设备...'));
    } catch (e) {
      _showError(_t('Connect failed: $e', '连接失败: $e'));
    }
  }

  Future<void> _disconnect() async {
    try {
      if (_isReading) {
        await _stopReading();
      }
      await IminRfid.disconnect();
      setState(() {
        _isConnected = false;
        _batteryLevel = 0;
        _isCharging = false;
      });
      _showSuccess(_t('Disconnected', '已断开连接'));
    } catch (e) {
      _showError(_t('Disconnect failed: $e', '断开失败: $e'));
    }
  }

  Future<void> _startReading() async {
    try {
      await IminRfid.startReading();
      setState(() => _isReading = true);
      _showSuccess(_t('Start reading tags', '开始读取标签'));
    } catch (e) {
      _showError(_t('Start reading failed: $e', '开始读取失败: $e'));
    }
  }

  Future<void> _stopReading() async {
    try {
      await IminRfid.stopReading();
      setState(() => _isReading = false);
      _showSuccess(_t('Stop reading', '停止读取'));
    } catch (e) {
      _showError(_t('Stop reading failed: $e', '停止读取失败: $e'));
    }
  }

  Future<void> _clearTags() async {
    try {
      await IminRfid.clearTags();
      setState(() {
        _tags.clear();
        _tagMap.clear();
        _tagCount = 0;
        _totalReadCount = 0;
      });
      _showSuccess(_t('Tags cleared', '已清空标签列表'));
    } catch (e) {
      _showError(_t('Clear failed: $e', '清空失败: $e'));
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏷️ RFID'),
        actions: [
          IconButton(
            icon: Icon(_isConnected
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled),
            onPressed: _isConnected ? _disconnect : _connect,
            tooltip:
                _isConnected ? _t('Disconnect', '断开连接') : _t('Connect', '连接设备'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusCard(),
          _buildControlButtons(),
          _buildStatsCard(),
          Expanded(child: _buildTagList()),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.cancel,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected
                      ? _t('Connected', '已连接')
                      : _t('Not Connected', '未连接'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                _buildBatteryIndicator(),
              ],
            ),
            if (_isConnected) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusItem(_t('Battery', '电量'), '$_batteryLevel%'),
                  _buildStatusItem(
                      _t('Status', '状态'),
                      _isCharging
                          ? _t('Charging', '充电中')
                          : _t('Not Charging', '未充电')),
                  _buildStatusItem(
                      _t('Reading', '读取'),
                      _isReading
                          ? _t('In Progress', '进行中')
                          : _t('Stopped', '已停止')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryIndicator() {
    IconData icon;
    Color color;

    if (_isCharging) {
      icon = Icons.battery_charging_full;
      color = Colors.green;
    } else if (_batteryLevel >= 75) {
      icon = Icons.battery_full;
      color = Colors.green;
    } else if (_batteryLevel >= 50) {
      icon = Icons.battery_6_bar;
      color = Colors.orange;
    } else if (_batteryLevel >= 25) {
      icon = Icons.battery_3_bar;
      color = Colors.orange;
    } else {
      icon = Icons.battery_1_bar;
      color = Colors.red;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text('$_batteryLevel%', style: TextStyle(color: color)),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isConnected && !_isReading ? _startReading : null,
              icon: const Icon(Icons.play_arrow),
              label: Text(_t('Start', '开始读取')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isConnected && _isReading ? _stopReading : null,
              icon: const Icon(Icons.stop),
              label: Text(_t('Stop', '停止读取')),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _tags.isNotEmpty ? _clearTags : null,
              icon: const Icon(Icons.clear_all),
              label: Text(_t('Clear', '清空')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
                _t('Tags', '标签数'), _tagCount.toString(), Icons.label),
            _buildStatItem(
                _t('Total', '总读取'), _totalReadCount.toString(), Icons.refresh),
            _buildStatItem(_t('Speed', '速度'),
                _isReading ? '${_totalReadCount ~/ 1}/s' : '0/s', Icons.speed),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildTagList() {
    if (_tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.label_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _t('No tags', '暂无标签'),
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _isConnected
                  ? _t('Click "Start" to scan tags', '点击"开始读取"扫描标签')
                  : _t('Please connect RFID device first', '请先连接 RFID 设备'),
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _tags.length,
      itemBuilder: (context, index) {
        final tag = _tags[index];
        return _buildTagCard(tag);
      },
    );
  }

  Widget _buildTagCard(RfidTag tag) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRssiColor(tag.rssi),
          child: Text(
            tag.count.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          tag.epc,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.signal_cellular_alt,
                size: 16, color: _getRssiColor(tag.rssi)),
            const SizedBox(width: 4),
            Text('${tag.rssi} dBm'),
            const SizedBox(width: 16),
            const Icon(Icons.refresh, size: 16),
            const SizedBox(width: 4),
            Text('${tag.count} ${_t('times', '次')}'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (tag.pc != null) _buildInfoRow('PC', tag.pc!),
                if (tag.tid != null) _buildInfoRow('TID', tag.tid!),
                _buildInfoRow(_t('Frequency', '频率'), '${tag.frequency} kHz'),
                _buildInfoRow(
                    _t('Time', '时间'), _formatTimestamp(tag.timestamp)),
                const Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(
                        _t('Read', '读取'), Icons.read_more, () => _readTag(tag)),
                    _buildActionButton(
                        _t('Write', '写入'), Icons.edit, () => _writeTag(tag)),
                    _buildActionButton(
                        _t('Lock', '锁定'), Icons.lock, () => _lockTag(tag)),
                    _buildActionButton(_t('Kill', '销毁'), Icons.delete_forever,
                        () => _killTag(tag)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getRssiColor(int rssi) {
    if (rssi >= -50) return Colors.green;
    if (rssi >= -70) return Colors.orange;
    return Colors.red;
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

  // 标签操作方法
  Future<void> _readTag(RfidTag tag) async {
    _showError(_t('Read function in development...', '读取功能开发中...'));
  }

  Future<void> _writeTag(RfidTag tag) async {
    _showError(_t('Write function in development...', '写入功能开发中...'));
  }

  Future<void> _lockTag(RfidTag tag) async {
    _showError(_t('Lock function in development...', '锁定功能开发中...'));
  }

  Future<void> _killTag(RfidTag tag) async {
    _showError(_t('Kill function in development...', '销毁功能开发中...'));
  }
}
