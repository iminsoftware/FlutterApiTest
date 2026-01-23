import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class FloatingWindowExample extends StatefulWidget {
  const FloatingWindowExample({Key? key}) : super(key: key);

  @override
  State<FloatingWindowExample> createState() => _FloatingWindowExampleState();
}

class _FloatingWindowExampleState extends State<FloatingWindowExample> {
  bool _isShowing = false;
  final TextEditingController _textController =
      TextEditingController(text: 'Floating Window');
  final TextEditingController _xController = TextEditingController(text: '0');
  final TextEditingController _yController = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final isShowing = await FloatingWindowApi.isShowing();
      setState(() {
        _isShowing = isShowing;
      });
    } catch (e) {
      _showError('Failed to check status: $e');
    }
  }

  Future<void> _showFloatingWindow() async {
    try {
      await FloatingWindowApi.show();
      await _checkStatus();
      _showSuccess('Floating window shown');
    } catch (e) {
      _showError('Failed to show: $e');
    }
  }

  Future<void> _hideFloatingWindow() async {
    try {
      await FloatingWindowApi.hide();
      await _checkStatus();
      _showSuccess('Floating window hidden');
    } catch (e) {
      _showError('Failed to hide: $e');
    }
  }

  Future<void> _updateText() async {
    try {
      await FloatingWindowApi.updateText(_textController.text);
      _showSuccess('Text updated');
    } catch (e) {
      _showError('Failed to update text: $e');
    }
  }

  Future<void> _setPosition() async {
    try {
      final x = int.tryParse(_xController.text) ?? 0;
      final y = int.tryParse(_yController.text) ?? 100;
      await FloatingWindowApi.setPosition(x, y);
      _showSuccess('Position updated');
    } catch (e) {
      _showError('Failed to set position: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Floating Window Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Status: ${_isShowing ? "Showing" : "Hidden"}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showFloatingWindow,
                            child: const Text('Show'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hideFloatingWindow,
                            child: const Text('Hide'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Text',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: 'Text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _updateText,
                      child: const Text('Update Text'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Position',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _xController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'X',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _yController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Y',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _setPosition,
                      child: const Text('Set Position'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Permission Required',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'On Android 6.0+, you need to grant "Display over other apps" permission. '
                      'If the floating window doesn\'t show, go to Settings > Apps > This App > '
                      'Display over other apps and enable it.',
                      style: TextStyle(fontSize: 12),
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

  @override
  void dispose() {
    _textController.dispose();
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }
}
