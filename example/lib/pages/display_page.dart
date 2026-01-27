import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class DisplayPage extends StatefulWidget {
  const DisplayPage({super.key});

  @override
  State<DisplayPage> createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  bool _isDisplayAvailable = false;
  bool _isDisplayEnabled = false;
  String _statusMessage = '';
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDisplayAvailability();
    });
  }

  Future<void> _checkDisplayAvailability() async {
    final l10n = AppLocalizations.of(context);

    setState(() {
      _statusMessage = l10n.checking;
    });

    try {
      final available = await IminDisplay.isAvailable();
      setState(() {
        _isDisplayAvailable = available;
        _statusMessage =
            available ? l10n.secondaryDisplayDetected : l10n.noSecondaryDisplay;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.error}: $e';
      });
    }
  }

  Future<void> _toggleDisplay() async {
    final l10n = AppLocalizations.of(context);

    try {
      if (_isDisplayEnabled) {
        await IminDisplay.disable();
        setState(() {
          _isDisplayEnabled = false;
          _statusMessage = l10n.displayDisabled;
        });
      } else {
        final success = await IminDisplay.enable();
        setState(() {
          _isDisplayEnabled = success;
          _statusMessage =
              success ? l10n.displayEnabled : l10n.failedToEnableDisplay;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.error}: $e';
      });
    }
  }

  Future<void> _showText() async {
    final l10n = AppLocalizations.of(context);

    try {
      final text = _textController.text.isEmpty
          ? l10n.helloFromFlutter
          : _textController.text;
      await IminDisplay.showText(text);
      setState(() {
        _statusMessage = l10n.textDisplayed;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.error}: $e';
      });
    }
  }

  Future<void> _showImage() async {
    final l10n = AppLocalizations.of(context);

    try {
      // 使用实际的 Flutter asset 路径
      await IminDisplay.showImage('assets/images/imin_product.png');
      setState(() {
        _statusMessage = l10n.imageDisplayed;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.errorShowingImage}: $e';
      });
    }
  }

  Future<void> _playVideo() async {
    final l10n = AppLocalizations.of(context);

    try {
      // 使用实际的 Flutter asset 路径
      await IminDisplay.playVideo('assets/videos/imin_video_3.mp4');
      setState(() {
        _statusMessage = l10n.videoPlaying;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.errorPlayingVideo}: $e';
      });
    }
  }

  Future<void> _clearDisplay() async {
    final l10n = AppLocalizations.of(context);

    try {
      await IminDisplay.clear();
      setState(() {
        _statusMessage = l10n.displayCleared;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '${l10n.error}: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      // 点击空白处关闭键盘
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(l10n.dualScreen),
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
                        l10n.status,
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
                              ? l10n.displayAvailable
                              : l10n.displayNotAvailable),
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
                label: Text(_isDisplayEnabled
                    ? l10n.disableDisplay
                    : l10n.enableDisplay),
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
                l10n.textDisplay,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: l10n.textToDisplay,
                  border: const OutlineInputBorder(),
                  hintText: l10n.enterTextHere,
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
                label: Text(l10n.showText),
              ),
              const SizedBox(height: 24),

              // Image Section
              Text(
                l10n.imageDisplay,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _showImage : null,
                icon: const Icon(Icons.image),
                label: Text(l10n.showImage),
              ),
              const SizedBox(height: 24),

              // Video Section
              Text(
                l10n.videoDisplay,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _playVideo : null,
                icon: const Icon(Icons.video_library),
                label: Text(l10n.playVideo),
              ),
              const SizedBox(height: 24),

              // Clear Button
              ElevatedButton.icon(
                onPressed: _isDisplayEnabled ? _clearDisplay : null,
                icon: const Icon(Icons.clear),
                label: Text(l10n.clearDisplay),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Tips
              Card(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            l10n.tips,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.displayTips,
                        style: const TextStyle(color: Colors.white),
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
