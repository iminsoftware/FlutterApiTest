import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.msrTest),
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
                          Text(
                            l10n.msrStatus,
                            style: const TextStyle(
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
                                _isAvailable
                                    ? l10n.msrAvailable
                                    : l10n.msrNotAvailable,
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
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                l10n.howToUse,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.msrInstructions,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Input Field
                  Text(
                    l10n.swipeCardHere,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _msrController,
                    decoration: InputDecoration(
                      hintText: l10n.cardDataPlaceholder,
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
                                '${l10n.cardDataReceived}: ${value.length} ${l10n.characters}'),
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
                    label: Text(l10n.clearInput),
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
                        children: [
                          Text(
                            l10n.technicalNotes,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.msrTechnicalNotes,
                            style: const TextStyle(fontSize: 13),
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
