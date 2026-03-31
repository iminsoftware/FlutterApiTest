import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

/// 电子秤测试页面 (Android 13+ 新版 SDK)
class ScaleNewPage extends StatefulWidget {
  const ScaleNewPage({super.key});

  @override
  State<ScaleNewPage> createState() => _ScaleNewPageState();
}

class _ScaleNewPageState extends State<ScaleNewPage> {
  bool _isConnected = false;
  bool _isGettingData = false;
  String _serviceVersion = 'Unknown';
  String _firmwareVersion = 'Unknown';

  // 当前称重数据
  ScaleWeightData? _currentWeight;
  ScaleStatusData? _currentStatus;
  ScalePriceData? _currentPrice;
  int? _errorCode;

  // 价格设置
  final TextEditingController _priceController = TextEditingController();
  int _selectedUnit = ScaleUnit.g;

  // 数字去皮
  final TextEditingController _digitalTareController = TextEditingController();

  // 历史记录
  final List<String> _history = [];
  final int _maxHistory = 10;

  StreamSubscription<ScaleEvent>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    _listenToEvents();
    // 自动连接服务
    _connectService();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _priceController.dispose();
    _digitalTareController.dispose();
    IminScaleNew.cancelGetData();
    super.dispose();
  }

  // Localization helper
  String _t(String en, String zh) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'zh' ? zh : en;
  }

  // 监听事件
  void _listenToEvents() {
    _eventSubscription = IminScaleNew.eventStream.listen((event) {
      if (!mounted) return;

      setState(() {
        if (event.isWeight) {
          _currentWeight = event.data as ScaleWeightData;
        } else if (event.isStatus) {
          _currentStatus = event.data as ScaleStatusData;
        } else if (event.isPrice) {
          _currentPrice = event.data as ScalePriceData;
        } else if (event.isError) {
          _errorCode = event.data as int;
        } else if (event.isConnection) {
          final conn = event.data as ScaleConnectionData;
          _isConnected = conn.connected;
        }
      });
    });
  }

  void _addHistory(String message) {
    final time = DateTime.now();
    final timeStr = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
    _history.insert(0, '$timeStr - $message');
    if (_history.length > _maxHistory) {
      _history.removeLast();
    }
  }

  // 连接服务
  Future<void> _connectService() async {
    final success = await IminScaleNew.connectService();
    if (success) {
      _loadVersions();
      // 自动开始获取数据
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted && _isConnected) {
        _startGetData();
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? _t('Connected', '连接成功')
                : _t('Connect failed', '连接失败'))),
      );
    }
  }

  // 加载版本信息
  Future<void> _loadVersions() async {
    final serviceVer = await IminScaleNew.getServiceVersion();
    final firmwareVer = await IminScaleNew.getFirmwareVersion();
    if (mounted) {
      setState(() {
        _serviceVersion = serviceVer;
        _firmwareVersion = firmwareVer;
      });
    }
  }

  // 开始获取数据
  Future<void> _startGetData() async {
    final success = await IminScaleNew.getData();
    if (mounted) {
      setState(() => _isGettingData = success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? _t('Start reading', '开始读取')
                : _t('Read failed', '读取失败'))),
      );
    }
  }

  // 停止获取数据
  Future<void> _stopGetData() async {
    final success = await IminScaleNew.cancelGetData();
    if (mounted) {
      setState(() => _isGettingData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                success ? _t('Stopped', '已停止') : _t('Stop failed', '停止失败'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${l10n.scale} (Android 13+)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildConnectionCard(),
          const SizedBox(height: 16),
          _buildWeightCard(),
          const SizedBox(height: 16),
          _buildOperationsCard(),
          const SizedBox(height: 16),
          _buildPriceCard(),
          const SizedBox(height: 16),
          _buildDeviceInfoCard(),
          const SizedBox(height: 16),
          _buildHistoryCard(),
        ],
      ),
    );
  }

  // 连接状态卡片
  Widget _buildConnectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.cancel,
                  color: _isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected
                      ? _t('Connected', '已连接')
                      : _t('Not Connected', '未连接'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('${_t('Service version', '服务版本')}: $_serviceVersion'),
            Text('${_t('Firmware version', '固件版本')}: $_firmwareVersion'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? null : _connectService,
                    icon: const Icon(Icons.link),
                    label: Text(_t('Connect', '连接服务')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        !_isConnected || _isGettingData ? null : _startGetData,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(_t('Start', '开始读取')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !_isGettingData ? null : _stopGetData,
                    icon: const Icon(Icons.stop),
                    label: Text(_t('Stop', '停止读取')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 称重数据卡片
  Widget _buildWeightCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Real-time Weight Data', '实时称重数据'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (_currentWeight != null) ...[
              _buildDataRow(_t('Net', '净重'),
                  '${_currentWeight!.net.toStringAsFixed(3)} kg'),
              _buildDataRow(_t('Tare', '皮重'),
                  '${_currentWeight!.tare.toStringAsFixed(3)} kg'),
              _buildDataRow(
                _t('Status', '状态'),
                _currentWeight!.isStable
                    ? _t('✓ Stable', '✓ 稳定')
                    : _t('~ Unstable', '~ 浮动'),
                color: _currentWeight!.isStable ? Colors.green : Colors.orange,
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_t('No data', '暂无数据'),
                      style: const TextStyle(color: Colors.grey)),
                ),
              ),
            if (_currentStatus != null) ...[
              const Divider(),
              if (_currentStatus!.isLightWeight)
                _buildWarning(_t('⚠️ Underweight', '⚠️ 过轻')),
              if (_currentStatus!.overload)
                _buildWarning(_t('⚠️ Overload', '⚠️ 过载')),
              if (_currentStatus!.clearZeroErr)
                _buildWarning(_t('❌ Zero error', '❌ 清零错误')),
              if (_currentStatus!.calibrationErr)
                _buildWarning(_t('❌ Calibration error', '❌ 标定错误')),
            ],
            if (_errorCode != null) ...[
              const Divider(),
              _buildWarning(_t('Error code: $_errorCode', '错误码: $_errorCode')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(color: Colors.orange)),
    );
  }

  // 操作按钮卡片
  Widget _buildOperationsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Weight Operations', '称重操作'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? () => IminScaleNew.zero() : null,
                    icon: const Icon(Icons.exposure_zero),
                    label: Text(_t('Zero', '清零')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isConnected ? () => IminScaleNew.tare() : null,
                    icon: const Icon(Icons.scale),
                    label: Text(_t('Tare', '去皮')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _digitalTareController,
                    decoration: InputDecoration(
                      labelText: _t('Digital Tare (g)', '数字去皮 (克)'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected
                      ? () {
                          final weight =
                              int.tryParse(_digitalTareController.text);
                          if (weight != null) {
                            IminScaleNew.digitalTare(weight);
                          }
                        }
                      : null,
                  child: Text(_t('Set', '设置')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 价格设置卡片
  Widget _buildPriceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Price Calculation', '价格计算'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_currentPrice != null) ...[
              _buildDataRow(
                  _t('Unit Price', '单价'), '¥${_currentPrice!.unitPrice}'),
              _buildDataRow(_t('Total', '总价'), '¥${_currentPrice!.totalPrice}',
                  color: Colors.green),
              _buildDataRow(_t('Unit', '单位'), _currentPrice!.unitName),
              const Divider(),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: _t('Unit Price', '单价 (元)'),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isConnected
                      ? () {
                          final price = _priceController.text;
                          if (price.isNotEmpty) {
                            IminScaleNew.setUnitPrice(price);
                          }
                        }
                      : null,
                  child: Text(_t('Set', '设置')),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(_t('Weight Unit:', '重量单位:'),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('g'),
                  selected: _selectedUnit == ScaleUnit.g,
                  onSelected: _isConnected
                      ? (selected) {
                          if (selected) {
                            setState(() => _selectedUnit = ScaleUnit.g);
                            IminScaleNew.setUnit(ScaleUnit.g);
                          }
                        }
                      : null,
                ),
                ChoiceChip(
                  label: const Text('100g'),
                  selected: _selectedUnit == ScaleUnit.g100,
                  onSelected: _isConnected
                      ? (selected) {
                          if (selected) {
                            setState(() => _selectedUnit = ScaleUnit.g100);
                            IminScaleNew.setUnit(ScaleUnit.g100);
                          }
                        }
                      : null,
                ),
                ChoiceChip(
                  label: const Text('500g'),
                  selected: _selectedUnit == ScaleUnit.g500,
                  onSelected: _isConnected
                      ? (selected) {
                          if (selected) {
                            setState(() => _selectedUnit = ScaleUnit.g500);
                            IminScaleNew.setUnit(ScaleUnit.g500);
                          }
                        }
                      : null,
                ),
                ChoiceChip(
                  label: const Text('kg'),
                  selected: _selectedUnit == ScaleUnit.kg,
                  onSelected: _isConnected
                      ? (selected) {
                          if (selected) {
                            setState(() => _selectedUnit = ScaleUnit.kg);
                            IminScaleNew.setUnit(ScaleUnit.kg);
                          }
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 设备信息卡片
  Widget _buildDeviceInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('Device Info', '设备信息'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _isConnected
                      ? () async {
                          final data = await IminScaleNew.readAcceleData();
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(_t('Acceleration Data', '加速度数据')),
                                content: Text(
                                    'X: ${data[0]}\nY: ${data[1]}\nZ: ${data[2]}'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(_t('Close', '关闭')),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.speed),
                  label: Text(_t('Acceleration', '加速度')),
                ),
                ElevatedButton.icon(
                  onPressed: _isConnected
                      ? () async {
                          final state = await IminScaleNew.readSealState();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_t(
                                    'Seal status: ${state == 0 ? "Normal" : "Broken"}',
                                    '铅封状态: ${state == 0 ? "正常" : "被破坏"}')),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.security),
                  label: Text(_t('Seal Status', '铅封状态')),
                ),
                ElevatedButton.icon(
                  onPressed: _isConnected
                      ? () async {
                          final status = await IminScaleNew.getCalStatus();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_t(
                                    'Cal button: ${status == 0 ? "Not pressed" : "Pressed"}',
                                    '标定按钮: ${status == 0 ? "未按下" : "按下"}')),
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.tune),
                  label: Text(_t('Cal Status', '标定状态')),
                ),
                ElevatedButton.icon(
                  onPressed: _isConnected
                      ? () async {
                          final info = await IminScaleNew.getCalInfo();
                          if (mounted) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(_t('Scale Parameters', '秤参数信息')),
                                content: Text(
                                  info.isEmpty
                                      ? _t('No data', '无数据')
                                      : info
                                          .map((e) => '${e[0]}/${e[1]}')
                                          .join('\n'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(_t('Close', '关闭')),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      : null,
                  icon: const Icon(Icons.info),
                  label: Text(_t('Parameters', '秤参数')),
                ),
                ElevatedButton.icon(
                  onPressed: _isConnected
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(_t('Restart Scale', '重启电子秤')),
                              content: Text(_t(
                                  'Are you sure?\nRestart will re-read zero point.',
                                  '确定要重启电子秤吗？\n重启会重新读取零点，请谨慎操作。')),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(_t('Cancel', '取消')),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    IminScaleNew.restart();
                                  },
                                  child: Text(_t('Confirm', '确定')),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(_t('Restart', '重启')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 历史记录卡片
  Widget _buildHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _t('History', '操作历史'),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _history.isEmpty
                      ? null
                      : () {
                          setState(() => _history.clear());
                        },
                  icon: const Icon(Icons.clear_all),
                  label: Text(_t('Clear', '清空')),
                ),
              ],
            ),
            const Divider(),
            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_t('No history', '暂无记录'),
                      style: const TextStyle(color: Colors.grey)),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _history[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
