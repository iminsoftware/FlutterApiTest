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

  Future<void> _checkStatus() async {
    try {
      final isShowing = await FloatingWindowApi.isShowing();
      setState(() {
        _isShowing = isShowing;
      });
    } catch (e) {
      _showMessage('检查状态失败: $e');
    }
  }

  Future<void> _showFloatingWindow() async {
    try {
      final success = await FloatingWindowApi.show();
      if (success) {
        setState(() {
          _isShowing = true;
        });
        _showMessage('悬浮窗已显示');
      } else {
        _showMessage('显示悬浮窗失败，请检查权限');
      }
    } catch (e) {
      _showMessage('显示悬浮窗失败: $e');
    }
  }

  Future<void> _hideFloatingWindow() async {
    try {
      final success = await FloatingWindowApi.hide();
      if (success) {
        setState(() {
          _isShowing = false;
        });
        _showMessage('悬浮窗已隐藏');
      } else {
        _showMessage('隐藏悬浮窗失败');
      }
    } catch (e) {
      _showMessage('隐藏悬浮窗失败: $e');
    }
  }

  Future<void> _updateText() async {
    try {
      final success = await FloatingWindowApi.updateText(_textController.text);
      if (success) {
        _showMessage('文本已更新');
      } else {
        _showMessage('更新文本失败');
      }
    } catch (e) {
      _showMessage('更新文本失败: $e');
    }
  }

  Future<void> _updatePosition() async {
    try {
      final success = await FloatingWindowApi.setPosition(
        _xPosition.toInt(),
        _yPosition.toInt(),
      );
      if (success) {
        _showMessage('位置已更新: (${_xPosition.toInt()}, ${_yPosition.toInt()})');
      } else {
        _showMessage('更新位置失败');
      }
    } catch (e) {
      _showMessage('更新位置失败: $e');
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
                    '状态',
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
                        _isShowing ? '悬浮窗已显示' : '悬浮窗已隐藏',
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
                    '控制',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isShowing ? null : _showFloatingWindow,
                          icon: const Icon(Icons.visibility),
                          label: const Text('显示悬浮窗'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isShowing ? _hideFloatingWindow : null,
                          icon: const Icon(Icons.visibility_off),
                          label: const Text('隐藏悬浮窗'),
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
                    '更新文本',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: '悬浮窗文本',
                      border: OutlineInputBorder(),
                      hintText: '输入要显示的文本',
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isShowing ? _updateText : null,
                      icon: const Icon(Icons.update),
                      label: const Text('更新文本'),
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
                    '更新位置',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text('X 坐标: ${_xPosition.toInt()}'),
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
                  Text('Y 坐标: ${_yPosition.toInt()}'),
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
                      label: const Text('更新位置'),
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
                        '使用说明',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. 首次使用需要授予"显示在其他应用上层"权限'),
                  const Text('2. 悬浮窗会在应用退出后继续显示'),
                  const Text('3. 可以拖动悬浮窗改变位置'),
                  const Text('4. 使用"隐藏悬浮窗"按钮关闭悬浮窗'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
