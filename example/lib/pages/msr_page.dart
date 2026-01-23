import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

/// MSR (Magnetic Stripe Reader) Test Page
///
/// Based on IMinApiTest MsrActivity implementation
class MsrPage extends StatefulWidget {
  const MsrPage({Key? key}) : super(key: key);

  @override
  State<MsrPage> createState() => _MsrPageState();
}

class _MsrPageState extends State<MsrPage> {
  final TextEditingController _msrController = TextEditingController();
  bool _isAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  @override
  void dispose() {
    _msrController.dispose();
    super.dispose();
  }

  Future<void> _checkAvailability() async {
    setState(() => _isLoading = true);
    try {
      final available = await IminMsr.isAvailable();
      setState(() {
        _isAvailable = available;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearInput() {
    _msrController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MSR Test'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          const Text(
                            'MSR Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                _isAvailable ? Icons.check_circle : Icons.error,
                                color: _isAvailable ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isAvailable ? 'Available' : 'Not Available',
                                style: TextStyle(
                                  color:
                                      _isAvailable ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Instructions
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'How to Use',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text(
                            '1. Tap the input field below\n'
                            '2. Swipe a magnetic stripe card\n'
                            '3. Card data will appear automatically\n'
                            '4. MSR device works as keyboard input',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Field
                  const Text(
                    'Swipe Card Here:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _msrController,
                    decoration: InputDecoration(
                      hintText: 'Card data will appear here automatically',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.credit_card),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearInput,
                      ),
                    ),
                    maxLines: 3,
                    readOnly: false,
                    autofocus: true,
                    onSubmitted: (value) {
                      // Card data received
                      if (value.isNotEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Card data received: ${value.length} characters'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Clear Button
                  ElevatedButton.icon(
                    onPressed: _clearInput,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Input'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Card
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Technical Notes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• MSR devices work as keyboard input devices\n'
                            '• No special API calls needed to read data\n'
                            '• Data format depends on card and device\n'
                            '• Supported devices: Crane 1, Swan 2, M2-Pro',
                            style: TextStyle(fontSize: 13),
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
}
