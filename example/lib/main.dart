import 'package:flutter/material.dart';
import 'pages/display_page.dart';
import 'pages/cashbox_page.dart';
import 'pages/light_page.dart';
import 'pages/nfc_page.dart';
import 'pages/scanner_page.dart';
import 'pages/msr_page.dart';
import 'pages/scale_page.dart';
import 'pages/serial_page.dart';
import 'pages/rfid_page.dart';
import 'pages/segment_page.dart';
import 'utils/permission_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMin Hardware Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // 应用启动时主动申请权限
    _requestPermissionsOnStartup();
  }

  Future<void> _requestPermissionsOnStartup() async {
    // 延迟一下，等待界面完全加载
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 检查并请求悬浮窗权限（用于副屏显示）
    final hasPermission =
        await PermissionHelper.hasSystemAlertWindowPermission();

    if (!hasPermission) {
      if (mounted) {
        final granted =
            await PermissionHelper.requestSystemAlertWindowPermission(context);

        if (granted && mounted) {
          PermissionHelper.showMessage(
            context,
            'Display permission granted successfully',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('iMin Hardware Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Device Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Information',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Brand: iMin'),
                  const Text('Model: Testing Device'),
                  const Text('SDK Version: 1.0.25'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hardware Features
          Text(
            'Hardware Features',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          _buildFeatureButton(
            context,
            icon: Icons.tv,
            title: 'Dual Screen Display',
            subtitle: 'Secondary display control',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DisplayPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.point_of_sale,
            title: 'Cash Box',
            subtitle: 'Cash drawer control',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CashBoxPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.lightbulb,
            title: 'Light Control',
            subtitle: 'LED indicator lights',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LightPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.nfc,
            title: 'NFC Reader',
            subtitle: 'NFC card reading',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NfcPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.qr_code_scanner,
            title: 'Scanner',
            subtitle: 'Barcode/QR code scanning',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.credit_card,
            title: 'MSR (Magnetic Stripe Reader)',
            subtitle: 'Magnetic card reading',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MsrPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.scale,
            title: 'Electronic Scale',
            subtitle: 'Weight measurement',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScalePage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.cable,
            title: 'Serial Port',
            subtitle: 'Serial communication',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SerialPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.sensors,
            title: 'RFID',
            subtitle: 'RFID tag read/write',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RfidPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.pin,
            title: 'Segment Display',
            subtitle: 'Digital tube display',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SegmentPage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
