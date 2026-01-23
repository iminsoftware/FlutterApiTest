import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  bool _isDisplayAvailable = false;
  bool _isDisplayEnabled = false;
  String _statusMessage = 'Checking...';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkDisplayAvailability();
  }

  Future<void> _checkDisplayAvailability() async {
    try {
      final available = await IminDisplay.isAvailable();
      setState(() {
        _isDisplayAvailable = available;
        _statusMessage = available
            ? 'Secondary display detected'
            : 'No secondary display found';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _toggleDisplay() async {
    try {
      if (_isDisplayEnabled) {
        await IminDisplay.disable();
        setState(() {
          _isDisplayEnabled = false;
          _statusMessage = 'Display disabled';
        });
      } else {
        final success = await IminDisplay.enable();
        setState(() {
          _isDisplayEnabled = success;
          _statusMessage = success
              ? 'Display enabled successfully'
              : 'Failed to enable display';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showText() async {
    try {
      final text = _textController.text.isEmpty
          ? 'Hello from Flutter!'
          : _textController.text;
      await IminDisplay.showText(text);
      setState(() {
        _statusMessage = 'Text displayed';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _showImage() async {
    try {
      // 使用实际的 Flutter asset 路径
      await IminDisplay.showImage('assets/images/imin_product.png');
      setState(() {
        _statusMessage = 'Image displayed: iMin Product';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error showing image: $e';
      });
    }
  }

  Future<void> _playVideo() async {
    try {
      // 使用实际的 Flutter asset 路径
      await IminDisplay.playVideo('assets/videos/imin_video_3.mp4');
      setState(() {
        _statusMessage = 'Video playing: iMin Demo';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error playing video: $e';
      });
    }
  }

  Future<void> _clearDisplay() async {
    try {
      await IminDisplay.clear();
      setState(() {
        _statusMessage = 'Display cleared';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 点击空白处关闭键盘
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Dual Screen Display'),
        ),
        body: SingleChildScrollView(
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
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(_statusMessage),
                      const SizedBox(height: 8),
                      // Display Availability
                      Row(
                        children: [
                          Icon(
                            _isDisplayAvailable
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                _isDisplayAvailable ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(_isDisplayAvailable
                              ? 'Display Available'
                              : 'Display Not Available'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Enable/Disable Button
              ElevatedButton.icon(
                onPressed: _isDisplayAvailable ? _toggleDisplay : null,
                icon: Icon(_isDisplayEnabled ? Icons.stop : Icons.play_arrow),
                label: Text(
                    _isDisplayEnabled ? 'Disable Display' : 'Enable Display'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor:
                      _isDisplayEnabled ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Text Section
              Text(
                'Text Display',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  labelText: 'Text to display',
                  border: OutlineInputBorder(),
                  hintText: 'Enter text here...',
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  // 按回车键时关闭键盘并显示文本
                  FocusScope.of(context).unfocus();
                  if (_isDisplayEnabled) {
                    _showText();
                  }
                },
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled
                    ? () {
                        // 点击按钮时先关闭键盘
                        FocusScope.of(context).unfocus();
                        _showText();
                      }
                    : null,
                icon: const Icon(Icons.text_fields),
                label: const Text('Show Text'),
              ),
              const SizedBox(height: 24),

              // Image Section
              Text(
                'Image Display',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _showImage : null,
                icon: const Icon(Icons.image),
                label: const Text('Show Image (iMin Product)'),
              ),
              const SizedBox(height: 24),

              // Video Section
              Text(
                'Video Display',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _playVideo : null,
                icon: const Icon(Icons.video_library),
                label: const Text('Play Video (iMin Demo)'),
              ),
              const SizedBox(height: 24),

              // Clear Button
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _clearDisplay : null,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Display'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Tips
              const Card(
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
                        '• Connect a secondary display to test\n'
                        '• Image: iMin Product Logo\n'
                        '• Video: iMin Demo Video (looping)',
                        style: TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
