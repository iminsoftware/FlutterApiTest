import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class FloatingWindowPage extends StatefulWidget {
  const FloatingWindowPage({super.key});

  @override
  State<FloatingWindowPage> createState() => _FloatingWindowPageState();
}

class _FloatingWindowPageState extends State<FloatingWindowPage> {
  bool _isShowing = false;
  final TextEditingController _textController = TextEditingController(
    text: 'Hello, Floating Window!',
  );
  double _xPosition = 100;
  double _yPosition = 100;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Localization helper
  String _t(String en, String zh) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'zh' ? zh : en;
  }

  Future<void> _checkStatus() async {
    try {
      final isShowing = await FloatingWindowApi.isShowing();
      setState(() {
        _isShowing = isShowing;
      });
    } catch (e) {
      _showMessage(_t('Check status failed: $e', '检查状态失败: $e'));
    }
  }

  Future<void> _showFloatingWindow() async {
    try {
      final success = await FloatingWindowApi.show();
      if (success) {
        setState(() {
          _isShowing = true;
        });
        _showMessage(_t('Floating window shown', '悬浮窗已显示'));
      } else {
        _showMessage(_t('Failed to show, check permission', '显示悬浮窗失败，请检查权限'));
      }
    } catch (e) {
      _showMessage(_t('Show failed: $e', '显示悬浮窗失败: $e'));
    }
  }

  Future<void> _hideFloatingWindow() async {
    try {
      final success = await FloatingWindowApi.hide();
      if (success) {
        setState(() {
          _isShowing = false;
        });
        _showMessage(_t('Floating window hidden', '悬浮窗已隐藏'));
      } else {
        _showMessage(_t('Failed to hide', '隐藏悬浮窗失败'));
      }
    } catch (e) {
      _showMessage(_t('Hide failed: $e', '隐藏悬浮窗失败: $e'));
    }
  }

  Future<void> _updateText() async {
    try {
      final success = await FloatingWindowApi.updateText(_textController.text);
      if (success) {
        _showMessage(_t('Text updated', '文本已更新'));
      } else {
        _showMessage(_t('Update text failed', '更新文本失败'));
      }
    } catch (e) {
      _showMessage(_t('Update text failed: $e', '更新文本失败: $e'));
    }
  }

  Future<void> _updatePosition() async {
    try {
      final success = await FloatingWindowApi.setPosition(
        _xPosition.toInt(),
        _yPosition.toInt(),
      );
      if (success) {
        _showMessage(_t(
            'Position updated: (${_xPosition.toInt()}, ${_yPosition.toInt()})',
            '位置已更新: (${_xPosition.toInt()}, ${_yPosition.toInt()})'));
      } else {
        _showMessage(_t('Update position failed', '更新位置失败'));
      }
    } catch (e) {
      _showMessage(_t('Update position failed: $e', '更新位置失败: $e'));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.floatingWindow),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Status', '状态'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isShowing ? Icons.check_circle : Icons.cancel,
                        color: _isShowing ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isShowing
                            ? _t('Floating window shown', '悬浮窗已显示')
                            : _t('Floating window hidden', '悬浮窗已隐藏'),
                        style: TextStyle(
                          color: _isShowing ? Colors.green : Colors.grey,
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

          // Control Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Control', '控制'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isShowing ? null : _showFloatingWindow,
                          icon: const Icon(Icons.visibility),
                          label: Text(_t('Show', '显示悬浮窗')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isShowing ? _hideFloatingWindow : null,
                          icon: const Icon(Icons.visibility_off),
                          label: Text(_t('Hide', '隐藏悬浮窗')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Text Update Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Update Text', '更新文本'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: _t('Floating window text', '悬浮窗文本'),
                      border: const OutlineInputBorder(),
                      hintText: _t('Enter text to display', '输入要显示的文本'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isShowing ? _updateText : null,
                      icon: const Icon(Icons.update),
                      label: Text(_t('Update Text', '更新文本')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Position Update Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('Update Position', '更新位置'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('${_t('X coordinate', 'X 坐标')}: ${_xPosition.toInt()}'),
                  Slider(
                    value: _xPosition,
                    min: 0,
                    max: 1000,
                    divisions: 100,
                    label: _xPosition.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _xPosition = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('${_t('Y coordinate', 'Y 坐标')}: ${_yPosition.toInt()}'),
                  Slider(
                    value: _yPosition,
                    min: 0,
                    max: 2000,
                    divisions: 100,
                    label: _yPosition.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _yPosition = value;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isShowing ? _updatePosition : null,
                      icon: const Icon(Icons.my_location),
                      label: Text(_t('Update Position', '更新位置')),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        _t('Instructions', '使用说明'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_t(
                      '1. First use requires "Display over other apps" permission',
                      '1. 首次使用需要授予"显示在其他应用上层"权限')),
                  Text(_t('2. Floating window persists after app exit',
                      '2. 悬浮窗会在应用退出后继续显示')),
                  Text(_t('3. Drag to change position', '3. 可以拖动悬浮窗改变位置')),
                  Text(_t(
                      '4. Use "Hide" button to close', '4. 使用"隐藏悬浮窗"按钮关闭悬浮窗')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
