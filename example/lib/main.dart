import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'pages/display_page.dart';
import 'pages/cashbox_page.dart';
import 'pages/light_page.dart';
import 'pages/nfc_page.dart';
import 'pages/scanner_page.dart';
import 'pages/msr_page.dart';
import 'pages/scale_page.dart';
import 'pages/scale_new_page.dart';
import 'pages/serial_page.dart';
import 'pages/rfid_page.dart';
import 'pages/segment_page.dart';
import 'pages/camera_scan_page.dart';
import 'pages/multi_scan_page.dart';
import 'pages/floating_window_page.dart';
import 'utils/permission_helper.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
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
  String _brand = 'iMin';
  String _model = 'Loading...';
  String _serialNumber = 'Loading...';
  String _deviceName = 'Loading...';

  @override
  void initState() {
    super.initState();
    // 应用启动时主动申请权限
    _requestPermissionsOnStartup();
    // 加载设备信息
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final deviceInfo = await IminDeviceInfo.getDeviceInfo();
      if (mounted) {
        setState(() {
          _brand = deviceInfo.brand;
          _model = deviceInfo.model;
          _serialNumber = deviceInfo.serialNumber;
          _deviceName = deviceInfo.deviceName;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _brand = 'iMin';
          _model = 'Unknown';
          _serialNumber = 'Unknown';
          _deviceName = 'Unknown';
        });
      }
    }
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
            AppLocalizations.of(context).permissionGranted,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
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
                    l10n.deviceInfo,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('${l10n.brand}: $_brand'),
                  Text('${l10n.model}: $_model'),
                  Text('SN: $_serialNumber'),
                  Text('${l10n.sdkVersion}: 1.0.25'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hardware Features
          Text(
            l10n.hardwareFeatures,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          _buildFeatureButton(
            context,
            icon: Icons.tv,
            title: l10n.dualScreen,
            subtitle: l10n.dualScreenDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DisplayPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.point_of_sale,
            title: l10n.cashBox,
            subtitle: l10n.cashBoxDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CashBoxPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.lightbulb,
            title: l10n.lightControl,
            subtitle: l10n.lightControlDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LightPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.nfc,
            title: l10n.nfcReader,
            subtitle: l10n.nfcReaderDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NfcPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.qr_code_scanner,
            title: l10n.scanner,
            subtitle: l10n.scannerDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ScannerPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.credit_card,
            title: l10n.msr,
            subtitle: l10n.msrDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MsrPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.scale,
            title: l10n.scale,
            subtitle: l10n.scaleDesc,
            onTap: () async {
              // 获取 Android 版本并跳转到对应页面
              final androidVersion = await IminDeviceInfo.getAndroidVersion();
              if (!mounted) return;

              if (androidVersion >= 33) {
                // Android 13+ 使用新版电子秤 SDK
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScaleNewPage()),
                );
              } else {
                // Android 11- 使用旧版串口电子秤
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScalePage()),
                );
              }
            },
          ),

          _buildFeatureButton(
            context,
            icon: Icons.cable,
            title: l10n.serialPort,
            subtitle: l10n.serialPortDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SerialPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.sensors,
            title: l10n.rfid,
            subtitle: l10n.rfidDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RfidPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.pin,
            title: l10n.segmentDisplay,
            subtitle: l10n.segmentDisplayDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SegmentPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.camera_alt,
            title: l10n.cameraScan,
            subtitle: l10n.cameraScanDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CameraScanPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.qr_code_scanner,
            title: l10n.multiScan,
            subtitle: l10n.multiScanDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MultiScanPage()),
            ),
          ),

          _buildFeatureButton(
            context,
            icon: Icons.picture_in_picture,
            title: l10n.floatingWindow,
            subtitle: l10n.floatingWindowDesc,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FloatingWindowPage()),
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
