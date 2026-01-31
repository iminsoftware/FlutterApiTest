import 'package:flutter/material.dart';

/// 应用国际化
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('zh', ''),
  ];

  // 通用
  String get appTitle =>
      locale.languageCode == 'zh' ? 'iMin 硬件演示' : 'iMin Hardware Demo';
  String get deviceInfo =>
      locale.languageCode == 'zh' ? '设备信息' : 'Device Information';
  String get brand => locale.languageCode == 'zh' ? '品牌' : 'Brand';
  String get model => locale.languageCode == 'zh' ? '型号' : 'Model';
  String get sdkVersion =>
      locale.languageCode == 'zh' ? 'SDK 版本' : 'SDK Version';
  String get testingDevice =>
      locale.languageCode == 'zh' ? '测试设备' : 'Testing Device';
  String get hardwareFeatures =>
      locale.languageCode == 'zh' ? '硬件功能' : 'Hardware Features';

  // 功能列表
  String get dualScreen =>
      locale.languageCode == 'zh' ? '双屏显示' : 'Dual Screen Display';
  String get dualScreenDesc =>
      locale.languageCode == 'zh' ? '副屏显示控制' : 'Secondary display control';

  String get cashBox => locale.languageCode == 'zh' ? '钱箱' : 'Cash Box';
  String get cashBoxDesc =>
      locale.languageCode == 'zh' ? '钱箱控制' : 'Cash drawer control';

  String get lightControl =>
      locale.languageCode == 'zh' ? '灯光控制' : 'Light Control';
  String get lightControlDesc =>
      locale.languageCode == 'zh' ? 'LED 指示灯' : 'LED indicator lights';

  String get nfcReader =>
      locale.languageCode == 'zh' ? 'NFC 读卡器' : 'NFC Reader';
  String get nfcReaderDesc =>
      locale.languageCode == 'zh' ? 'NFC 卡片读取' : 'NFC card reading';

  String get scanner => locale.languageCode == 'zh' ? '扫码器' : 'Scanner';
  String get scannerDesc =>
      locale.languageCode == 'zh' ? '条码/二维码扫描' : 'Barcode/QR code scanning';

  String get msr =>
      locale.languageCode == 'zh' ? '磁条卡读卡器' : 'MSR (Magnetic Stripe Reader)';
  String get msrDesc =>
      locale.languageCode == 'zh' ? '磁条卡读取' : 'Magnetic card reading';

  String get scale => locale.languageCode == 'zh' ? '电子秤' : 'Electronic Scale';
  String get scaleDesc =>
      locale.languageCode == 'zh' ? '重量测量' : 'Weight measurement';

  String get serialPort => locale.languageCode == 'zh' ? '串口' : 'Serial Port';
  String get serialPortDesc =>
      locale.languageCode == 'zh' ? '串口通信' : 'Serial communication';

  String get rfid => locale.languageCode == 'zh' ? 'RFID' : 'RFID';
  String get rfidDesc =>
      locale.languageCode == 'zh' ? 'RFID 标签读写' : 'RFID tag read/write';

  String get segmentDisplay =>
      locale.languageCode == 'zh' ? '数码管显示' : 'Segment Display';
  String get segmentDisplayDesc =>
      locale.languageCode == 'zh' ? '数码管显示' : 'Digital tube display';

  String get cameraScan =>
      locale.languageCode == 'zh' ? '摄像头扫码' : 'Camera Scan';
  String get cameraScanDesc => locale.languageCode == 'zh'
      ? '摄像头条码/二维码扫描'
      : 'Barcode/QR code camera scanning';

  String get floatingWindow =>
      locale.languageCode == 'zh' ? '悬浮窗' : 'Floating Window';
  String get floatingWindowDesc => locale.languageCode == 'zh'
      ? '系统悬浮窗显示'
      : 'System floating window display';

  // 摄像头扫码页面
  String get lastScanResult =>
      locale.languageCode == 'zh' ? '最近扫码结果' : 'Last Scan Result';
  String get noScanResult =>
      locale.languageCode == 'zh' ? '暂无扫码结果' : 'No scan result yet';
  String get format => locale.languageCode == 'zh' ? '格式' : 'Format';
  String get code => locale.languageCode == 'zh' ? '内容' : 'Code';
  String get quickScan => locale.languageCode == 'zh' ? '快速扫码' : 'Quick Scan';
  String get quickScanDefault => locale.languageCode == 'zh'
      ? '快速扫码（默认格式）'
      : 'Quick Scan (Default Formats)';
  String get scanQRCodeOnly =>
      locale.languageCode == 'zh' ? '仅扫描二维码' : 'Scan QR Code Only';
  String get scanBarcodeOnly =>
      locale.languageCode == 'zh' ? '仅扫描条形码' : 'Scan Barcode Only';
  String get scanAllFormats =>
      locale.languageCode == 'zh' ? '扫描所有格式' : 'Scan All Formats';
  String get advancedOptions =>
      locale.languageCode == 'zh' ? '高级选项' : 'Advanced Options';
  String get scanWithFlash =>
      locale.languageCode == 'zh' ? '开启闪光灯扫码' : 'Scan with Flash';
  String get scanWithTimeout =>
      locale.languageCode == 'zh' ? '10秒超时扫码' : 'Scan with 10s Timeout';
  String get scanCustomFormats =>
      locale.languageCode == 'zh' ? '自定义格式扫码' : 'Scan Custom Formats';
  String get scanHistory =>
      locale.languageCode == 'zh' ? '扫码历史' : 'Scan History';
  String get noScanHistory =>
      locale.languageCode == 'zh' ? '暂无扫码历史' : 'No scan history';
  String get clear => locale.languageCode == 'zh' ? '清空' : 'Clear';
  String get scanned => locale.languageCode == 'zh' ? '已扫描' : 'Scanned';
  String get cameraPermissionRequired => locale.languageCode == 'zh'
      ? '需要相机权限才能扫码'
      : 'Camera permission is required for scanning';
  String get permissionGranted => locale.languageCode == 'zh'
      ? '权限已授予'
      : 'Display permission granted successfully';

  // 权限对话框
  String get displayPermissionRequired =>
      locale.languageCode == 'zh' ? '需要显示权限' : 'Display Permission Required';
  String get displayPermissionMessage => locale.languageCode == 'zh'
      ? '此应用需要权限才能在副屏上显示内容。请在下一个屏幕中授予"显示在其他应用上层"权限。'
      : 'This app needs permission to display content on the secondary screen. Please grant "Display over other apps" permission in the next screen.';
  String get cancel => locale.languageCode == 'zh' ? '取消' : 'Cancel';
  String get continueText => locale.languageCode == 'zh' ? '继续' : 'Continue';
  String get permissionDenied =>
      locale.languageCode == 'zh' ? '权限被拒绝' : 'Permission Denied';
  String get permissionDeniedMessage => locale.languageCode == 'zh'
      ? '权限被拒绝。某些功能可能无法正常工作。您可以在应用设置中手动授予权限。'
      : 'The permission was denied. Some features may not work properly. You can grant the permission manually in app settings.';
  String get openSettings =>
      locale.languageCode == 'zh' ? '打开设置' : 'Open Settings';

  // 通用按钮和状态
  String get status => locale.languageCode == 'zh' ? '状态' : 'Status';
  String get checking => locale.languageCode == 'zh' ? '检查中...' : 'Checking...';
  String get ready => locale.languageCode == 'zh' ? '就绪' : 'Ready';
  String get connected => locale.languageCode == 'zh' ? '已连接' : 'CONNECTED';
  String get disconnected =>
      locale.languageCode == 'zh' ? '未连接' : 'DISCONNECTED';
  String get open => locale.languageCode == 'zh' ? '打开' : 'OPEN';
  String get closed => locale.languageCode == 'zh' ? '关闭' : 'CLOSED';
  String get enable => locale.languageCode == 'zh' ? '启用' : 'Enable';
  String get disable => locale.languageCode == 'zh' ? '禁用' : 'Disable';
  String get connect => locale.languageCode == 'zh' ? '连接' : 'Connect';
  String get disconnect => locale.languageCode == 'zh' ? '断开' : 'Disconnect';
  String get tips => locale.languageCode == 'zh' ? '提示' : 'Tips';
  String get error => locale.languageCode == 'zh' ? '错误' : 'Error';
  String get helloFromFlutter =>
      locale.languageCode == 'zh' ? '来自 Flutter 的问候！' : 'Hello from Flutter!';

  // 双屏显示页面
  String get secondaryDisplayDetected =>
      locale.languageCode == 'zh' ? '检测到副屏' : 'Secondary display detected';
  String get noSecondaryDisplay =>
      locale.languageCode == 'zh' ? '未检测到副屏' : 'No secondary display found';
  String get displayDisabled =>
      locale.languageCode == 'zh' ? '副屏已禁用' : 'Display disabled';
  String get displayEnabled =>
      locale.languageCode == 'zh' ? '副屏已成功启用' : 'Display enabled successfully';
  String get failedToEnableDisplay =>
      locale.languageCode == 'zh' ? '启用副屏失败' : 'Failed to enable display';
  String get displayAvailable =>
      locale.languageCode == 'zh' ? '副屏可用' : 'Display Available';
  String get displayNotAvailable =>
      locale.languageCode == 'zh' ? '副屏不可用' : 'Display Not Available';
  String get enableDisplay =>
      locale.languageCode == 'zh' ? '启用副屏' : 'Enable Display';
  String get disableDisplay =>
      locale.languageCode == 'zh' ? '禁用副屏' : 'Disable Display';
  String get textDisplay =>
      locale.languageCode == 'zh' ? '文本显示' : 'Text Display';
  String get textToDisplay =>
      locale.languageCode == 'zh' ? '要显示的文本' : 'Text to display';
  String get enterTextHere =>
      locale.languageCode == 'zh' ? '在此输入文本...' : 'Enter text here...';
  String get showText => locale.languageCode == 'zh' ? '显示文本' : 'Show Text';
  String get textDisplayed =>
      locale.languageCode == 'zh' ? '文本已显示' : 'Text displayed';
  String get imageDisplay =>
      locale.languageCode == 'zh' ? '图片显示' : 'Image Display';
  String get showImage => locale.languageCode == 'zh'
      ? '显示图片（iMin 产品）'
      : 'Show Image (iMin Product)';
  String get imageDisplayed => locale.languageCode == 'zh'
      ? '图片已显示：iMin 产品'
      : 'Image displayed: iMin Product';
  String get videoDisplay =>
      locale.languageCode == 'zh' ? '视频显示' : 'Video Display';
  String get playVideo =>
      locale.languageCode == 'zh' ? '播放视频（iMin 演示）' : 'Play Video (iMin Demo)';
  String get videoPlaying => locale.languageCode == 'zh'
      ? '视频播放中：iMin 演示'
      : 'Video playing: iMin Demo';
  String get clearDisplay =>
      locale.languageCode == 'zh' ? '清空显示' : 'Clear Display';
  String get displayCleared =>
      locale.languageCode == 'zh' ? '显示已清空' : 'Display cleared';
  String get displayTips => locale.languageCode == 'zh'
      ? '• 连接副屏进行测试\n• 图片：iMin 产品标志\n• 视频：iMin 演示视频（循环播放）'
      : '• Connect a secondary display to test\n• Image: iMin Product Logo\n• Video: iMin Demo Video (looping)';
  String get errorShowingImage =>
      locale.languageCode == 'zh' ? '显示图片错误' : 'Error showing image';
  String get errorPlayingVideo =>
      locale.languageCode == 'zh' ? '播放视频错误' : 'Error playing video';

  // 钱箱页面
  String get cashBoxStatus =>
      locale.languageCode == 'zh' ? '钱箱状态' : 'Cash Box Status';
  String get statusUpdatesEverySecond =>
      locale.languageCode == 'zh' ? '状态每秒更新' : 'Status updates every second';
  String get openCashBox =>
      locale.languageCode == 'zh' ? '打开钱箱' : 'Open Cash Box';
  String get cashBoxOpened =>
      locale.languageCode == 'zh' ? '钱箱已成功打开' : 'Cash box opened successfully';
  String get failedToOpenCashBox =>
      locale.languageCode == 'zh' ? '打开钱箱失败' : 'Failed to open cash box';
  String get voltageSettings =>
      locale.languageCode == 'zh' ? '电压设置' : 'Voltage Settings';
  String get selectVoltage =>
      locale.languageCode == 'zh' ? '选择钱箱电压：' : 'Select voltage for cash box:';
  String get setVoltageTo =>
      locale.languageCode == 'zh' ? '设置电压为' : 'Set Voltage to';
  String get voltageSet =>
      locale.languageCode == 'zh' ? '电压已设置为' : 'Voltage set to';
  String get failedToSetVoltage =>
      locale.languageCode == 'zh' ? '设置电压失败' : 'Failed to set voltage';
  String get cashBoxTips => locale.languageCode == 'zh'
      ? '• 连接钱箱进行测试\n• 状态每秒自动更新\n• 根据钱箱规格设置电压\n• 常用电压：12V（默认）'
      : '• Connect a cash drawer to test\n• Status updates automatically every second\n• Set voltage according to your cash drawer specs\n• Common voltage: 12V (default)';

  // 灯光控制页面
  String get deviceStatus =>
      locale.languageCode == 'zh' ? '设备状态' : 'Device Status';
  String get notConnected =>
      locale.languageCode == 'zh' ? '未连接' : 'Not connected';
  String get connectedToDevice =>
      locale.languageCode == 'zh' ? '已连接到灯光设备' : 'Connected to light device';
  String get failedToConnect => locale.languageCode == 'zh'
      ? '连接失败。请检查 USB 连接。'
      : 'Failed to connect. Please check USB connection.';
  String get disconnectedFromDevice => locale.languageCode == 'zh'
      ? '已断开灯光设备'
      : 'Disconnected from light device';
  String get failedToDisconnect =>
      locale.languageCode == 'zh' ? '断开失败' : 'Failed to disconnect';
  String get currentLightStatus =>
      locale.languageCode == 'zh' ? '当前灯光状态' : 'Current Light Status';
  String get lightControls =>
      locale.languageCode == 'zh' ? '灯光控制' : 'Light Controls';
  String get turnOnGreenLight =>
      locale.languageCode == 'zh' ? '开启绿灯' : 'Turn On Green Light';
  String get turnOnRedLight =>
      locale.languageCode == 'zh' ? '开启红灯' : 'Turn On Red Light';
  String get turnOffLight =>
      locale.languageCode == 'zh' ? '关闭灯光' : 'Turn Off Light';
  String get greenLightOn =>
      locale.languageCode == 'zh' ? '绿灯已开启' : 'Green light is ON';
  String get redLightOn =>
      locale.languageCode == 'zh' ? '红灯已开启' : 'Red light is ON';
  String get lightOff => locale.languageCode == 'zh' ? '灯光已关闭' : 'Light is OFF';
  String get failedToTurnOnGreen =>
      locale.languageCode == 'zh' ? '开启绿灯失败' : 'Failed to turn on green light';
  String get failedToTurnOnRed =>
      locale.languageCode == 'zh' ? '开启红灯失败' : 'Failed to turn on red light';
  String get failedToTurnOff =>
      locale.languageCode == 'zh' ? '关闭灯光失败' : 'Failed to turn off light';
  String get greenLightOnStatus =>
      locale.languageCode == 'zh' ? '绿灯开启' : 'GREEN LIGHT ON';
  String get redLightOnStatus =>
      locale.languageCode == 'zh' ? '红灯开启' : 'RED LIGHT ON';
  String get lightOffStatus =>
      locale.languageCode == 'zh' ? '灯光关闭' : 'LIGHT OFF';
  String get connectDevice =>
      locale.languageCode == 'zh' ? '连接设备' : 'Connect Device';
  String get disconnectDevice =>
      locale.languageCode == 'zh' ? '断开设备' : 'Disconnect Device';
  String get lightTips => locale.languageCode == 'zh'
      ? '• 首先连接 USB 灯光设备\n• 提示时授予 USB 权限\n• 绿灯：成功/就绪状态\n• 红灯：错误/忙碌状态\n• 支持设备：Crane 1、M2-Pro'
      : '• Connect USB light device first\n• Grant USB permission when prompted\n• Green light: Success/Ready state\n• Red light: Error/Busy state\n• Supported devices: Crane 1, M2-Pro';

  // NFC 页面
  String get nfcStatus => locale.languageCode == 'zh' ? 'NFC 状态' : 'NFC Status';
  String get checkingNfcStatus =>
      locale.languageCode == 'zh' ? '检查 NFC 状态...' : 'Checking NFC status...';
  String get nfcNotAvailable => locale.languageCode == 'zh'
      ? '此设备不支持 NFC'
      : 'NFC not available on this device';
  String get nfcDisabled => locale.languageCode == 'zh'
      ? 'NFC 已禁用。请在设置中启用。'
      : 'NFC is disabled. Please enable it in settings.';
  String get readyToScanNfc =>
      locale.languageCode == 'zh' ? '准备扫描 NFC 标签' : 'Ready to scan NFC tags';
  String get nfcAvailableAndEnabled => locale.languageCode == 'zh'
      ? 'NFC 可用且已启用'
      : 'NFC is available and enabled';
  String get openNfcSettings =>
      locale.languageCode == 'zh' ? '打开 NFC 设置' : 'Open NFC Settings';
  String get currentTag => locale.languageCode == 'zh' ? '当前标签' : 'Current Tag';
  String get noTagDetected =>
      locale.languageCode == 'zh' ? '未检测到标签' : 'No tag detected';
  String get tagId => locale.languageCode == 'zh' ? '标签 ID' : 'Tag ID';
  String get content => locale.languageCode == 'zh' ? '内容' : 'Content';
  String get technology => locale.languageCode == 'zh' ? '技术类型' : 'Technology';
  String get timestamp => locale.languageCode == 'zh' ? '时间戳' : 'Timestamp';
  String get tagHistory => locale.languageCode == 'zh' ? '标签历史' : 'Tag History';
  String get noTagHistory =>
      locale.languageCode == 'zh' ? '暂无标签历史' : 'No tag history';
  String get clearHistory =>
      locale.languageCode == 'zh' ? '清空历史' : 'Clear History';
  String get nfcTips => locale.languageCode == 'zh'
      ? '• 确保 NFC 已启用\n• 将 NFC 卡片靠近设备背面\n• 支持多种 NFC 标签类型\n• 自动记录扫描历史'
      : '• Make sure NFC is enabled\n• Place NFC card near device back\n• Supports multiple NFC tag types\n• Automatically records scan history';

  // 扫码器页面
  String get scannerStatus =>
      locale.languageCode == 'zh' ? '扫码器状态' : 'Scanner Status';
  String get scannerNotConnected =>
      locale.languageCode == 'zh' ? '扫码器未连接' : 'Scanner not connected';
  String get scannerConnected =>
      locale.languageCode == 'zh' ? '扫码器已连接' : 'Scanner connected';
  String get startListening =>
      locale.languageCode == 'zh' ? '开始监听' : 'Start Listening';
  String get stopListening =>
      locale.languageCode == 'zh' ? '停止监听' : 'Stop Listening';
  String get listening =>
      locale.languageCode == 'zh' ? '监听中...' : 'Listening...';
  String get notListening =>
      locale.languageCode == 'zh' ? '未监听' : 'Not listening';
  String get lastScanData =>
      locale.languageCode == 'zh' ? '最近扫码数据' : 'Last Scan Data';
  String get noScanData =>
      locale.languageCode == 'zh' ? '暂无扫码数据' : 'No scan data';
  String get data => locale.languageCode == 'zh' ? '数据' : 'Data';
  String get scanCount => locale.languageCode == 'zh' ? '扫码次数' : 'Scan Count';
  String get scannerTips => locale.languageCode == 'zh'
      ? '• 连接硬件扫码头\n• 点击"开始监听"按钮\n• 扫描条码或二维码\n• 自动接收扫码数据'
      : '• Connect hardware scanner\n• Click "Start Listening" button\n• Scan barcode or QR code\n• Automatically receive scan data';

  // 扫码器配置
  String get customConfig => locale.languageCode == 'zh'
      ? '自定义配置（可选）'
      : 'Custom Configuration (Optional)';
  String get broadcastAction =>
      locale.languageCode == 'zh' ? '广播动作' : 'Broadcast Action';
  String get stringDataKey =>
      locale.languageCode == 'zh' ? '字符串数据键' : 'String Data Key';
  String get byteDataKey =>
      locale.languageCode == 'zh' ? '字节数据键' : 'Byte Data Key';
  String get applyConfig =>
      locale.languageCode == 'zh' ? '应用配置' : 'Apply Configuration';

  // 磁条卡页面
  String get msrTest => locale.languageCode == 'zh' ? '磁条卡测试' : 'MSR Test';
  String get msrStatus => locale.languageCode == 'zh' ? '磁条卡状态' : 'MSR Status';
  String get msrAvailable => locale.languageCode == 'zh' ? '可用' : 'Available';
  String get msrNotAvailable =>
      locale.languageCode == 'zh' ? '不可用' : 'Not Available';
  String get howToUse => locale.languageCode == 'zh' ? '使用说明' : 'How to Use';
  String get msrInstructions => locale.languageCode == 'zh'
      ? '1. 点击下方输入框\n2. 刷磁条卡\n3. 卡片数据将自动显示\n4. MSR 设备作为键盘输入'
      : '1. Tap the input field below\n2. Swipe a magnetic stripe card\n3. Card data will appear automatically\n4. MSR device works as keyboard input';
  String get swipeCardHere =>
      locale.languageCode == 'zh' ? '在此刷卡：' : 'Swipe Card Here:';
  String get cardDataPlaceholder => locale.languageCode == 'zh'
      ? '卡片数据将自动显示在此'
      : 'Card data will appear here automatically';
  String get clearInput => locale.languageCode == 'zh' ? '清空输入' : 'Clear Input';
  String get cardDataReceived =>
      locale.languageCode == 'zh' ? '已接收卡片数据' : 'Card data received';
  String get characters => locale.languageCode == 'zh' ? '个字符' : 'characters';
  String get technicalNotes =>
      locale.languageCode == 'zh' ? '技术说明' : 'Technical Notes';
  String get msrTechnicalNotes => locale.languageCode == 'zh'
      ? '• MSR 设备作为键盘输入设备工作\n• 无需特殊 API 调用即可读取数据\n• 数据格式取决于卡片和设备\n• 支持设备：Crane 1、Swan 2、M2-Pro'
      : '• MSR devices work as keyboard input devices\n• No special API calls needed to read data\n• Data format depends on card and device\n• Supported devices: Crane 1, Swan 2, M2-Pro';
  String get swipeCard =>
      locale.languageCode == 'zh' ? '请刷卡' : 'Please swipe card';
  String get cardData => locale.languageCode == 'zh' ? '卡片数据' : 'Card Data';
  String get noCardData =>
      locale.languageCode == 'zh' ? '暂无卡片数据' : 'No card data';
  String get msrTips => locale.languageCode == 'zh'
      ? '• MSR 设备作为键盘输入\n• 点击输入框\n• 刷磁条卡\n• 数据自动输入到输入框'
      : '• MSR device works as keyboard input\n• Click the input field\n• Swipe magnetic card\n• Data automatically enters the field';

  // 电子秤页面
  String get electronicScale =>
      locale.languageCode == 'zh' ? '电子秤' : 'Electronic Scale';
  String get scaleStatus =>
      locale.languageCode == 'zh' ? '电子秤状态' : 'Scale Status';
  String get scaleNotConnected =>
      locale.languageCode == 'zh' ? '电子秤未连接' : 'Scale not connected';
  String get scaleConnected =>
      locale.languageCode == 'zh' ? '电子秤已连接' : 'Scale connected';
  String get connectScale =>
      locale.languageCode == 'zh' ? '连接电子秤' : 'Connect Scale';
  String get disconnectScale =>
      locale.languageCode == 'zh' ? '断开电子秤' : 'Disconnect Scale';
  String get currentWeight =>
      locale.languageCode == 'zh' ? '当前重量' : 'Current Weight';
  String get noWeightData =>
      locale.languageCode == 'zh' ? '暂无重量数据' : 'No weight data';
  String get weight => locale.languageCode == 'zh' ? '重量' : 'Weight';
  String get unit => locale.languageCode == 'zh' ? '单位' : 'Unit';
  String get stable => locale.languageCode == 'zh' ? '稳定' : 'Stable';
  String get unstable => locale.languageCode == 'zh' ? '不稳定' : 'Unstable';
  String get overweight => locale.languageCode == 'zh' ? '超重' : 'Overweight';
  String get unknown => locale.languageCode == 'zh' ? '未知' : 'Unknown';
  String get tare => locale.languageCode == 'zh' ? '去皮' : 'Tare';
  String get zero => locale.languageCode == 'zh' ? '清零' : 'Zero';
  String get devicePath => locale.languageCode == 'zh' ? '设备路径' : 'Device Path';
  String get baudRate => locale.languageCode == 'zh' ? '波特率' : 'Baud Rate';
  String get failedToConnectScale =>
      locale.languageCode == 'zh' ? '连接电子秤失败' : 'Failed to connect scale';
  String get weightUnstable => locale.languageCode == 'zh'
      ? '重量不稳定，请稍候'
      : 'Weight unstable, please wait';
  String get scaleTips => locale.languageCode == 'zh'
      ? '• 选择串口设备路径\n• 设置正确的波特率\n• 点击"连接电子秤"\n• 放置物品进行称重\n• 稳定状态下可去皮/清零'
      : '• Select serial port device path\n• Set correct baud rate\n• Click "Connect Scale"\n• Place items for weighing\n• Tare/Zero available when stable';

  // 串口页面
  String get serialStatus =>
      locale.languageCode == 'zh' ? '串口状态' : 'Serial Status';
  String get serialNotOpen =>
      locale.languageCode == 'zh' ? '串口未打开' : 'Serial port not open';
  String get serialOpen =>
      locale.languageCode == 'zh' ? '串口已打开' : 'Serial port open';
  String get openSerial => locale.languageCode == 'zh' ? '打开串口' : 'Open Serial';
  String get closeSerial =>
      locale.languageCode == 'zh' ? '关闭串口' : 'Close Serial';
  String get sendData => locale.languageCode == 'zh' ? '发送数据' : 'Send Data';
  String get receivedData =>
      locale.languageCode == 'zh' ? '接收数据' : 'Received Data';
  String get noReceivedData =>
      locale.languageCode == 'zh' ? '暂无接收数据' : 'No received data';
  String get dataToSend =>
      locale.languageCode == 'zh' ? '要发送的数据' : 'Data to send';
  String get enterData =>
      locale.languageCode == 'zh' ? '输入数据...' : 'Enter data...';
  String get serialTips => locale.languageCode == 'zh'
      ? '• 选择串口路径和波特率\n• 点击"打开串口"\n• 输入数据并发送\n• 实时接收串口数据'
      : '• Select serial path and baud rate\n• Click "Open Serial"\n• Enter data and send\n• Receive serial data in real-time';

  // RFID 页面
  String get rfidStatus =>
      locale.languageCode == 'zh' ? 'RFID 状态' : 'RFID Status';
  String get rfidNotConnected =>
      locale.languageCode == 'zh' ? 'RFID 未连接' : 'RFID not connected';
  String get rfidConnected =>
      locale.languageCode == 'zh' ? 'RFID 已连接' : 'RFID connected';
  String get connectRfid =>
      locale.languageCode == 'zh' ? '连接 RFID' : 'Connect RFID';
  String get disconnectRfid =>
      locale.languageCode == 'zh' ? '断开 RFID' : 'Disconnect RFID';
  String get startReading =>
      locale.languageCode == 'zh' ? '开始读取' : 'Start Reading';
  String get stopReading =>
      locale.languageCode == 'zh' ? '停止读取' : 'Stop Reading';
  String get reading => locale.languageCode == 'zh' ? '读取中...' : 'Reading...';
  String get notReading => locale.languageCode == 'zh' ? '未读取' : 'Not reading';
  String get detectedTags =>
      locale.languageCode == 'zh' ? '检测到的标签' : 'Detected Tags';
  String get noTagsDetected =>
      locale.languageCode == 'zh' ? '未检测到标签' : 'No tags detected';
  String get epc => locale.languageCode == 'zh' ? 'EPC' : 'EPC';
  String get rssi => locale.languageCode == 'zh' ? 'RSSI' : 'RSSI';
  String get count => locale.languageCode == 'zh' ? '次数' : 'Count';
  String get clearTags => locale.languageCode == 'zh' ? '清空标签' : 'Clear Tags';
  String get batteryLevel =>
      locale.languageCode == 'zh' ? '电池电量' : 'Battery Level';
  String get charging => locale.languageCode == 'zh' ? '充电中' : 'Charging';
  String get notCharging =>
      locale.languageCode == 'zh' ? '未充电' : 'Not charging';
  String get rfidTips => locale.languageCode == 'zh'
      ? '• 仅支持 iMin Lark 1\n• 点击"连接 RFID"\n• 点击"开始读取"\n• 将 RFID 标签靠近设备\n• 查看检测到的标签列表'
      : '• Only supports iMin Lark 1\n• Click "Connect RFID"\n• Click "Start Reading"\n• Place RFID tags near device\n• View detected tags list';

  // 数码管页面
  String get segmentStatus =>
      locale.languageCode == 'zh' ? '数码管状态' : 'Segment Status';
  String get segmentNotConnected =>
      locale.languageCode == 'zh' ? '数码管未连接' : 'Segment not connected';
  String get segmentConnected =>
      locale.languageCode == 'zh' ? '数码管已连接' : 'Segment connected';
  String get findDevice => locale.languageCode == 'zh' ? '查找设备' : 'Find Device';
  String get requestPermission =>
      locale.languageCode == 'zh' ? '请求权限' : 'Request Permission';
  String get permission => locale.languageCode == 'zh' ? '权限' : 'Permission';
  String get connectSegment =>
      locale.languageCode == 'zh' ? '连接数码管' : 'Connect Segment';
  String get disconnectSegment =>
      locale.languageCode == 'zh' ? '断开数码管' : 'Disconnect Segment';
  String get displayData =>
      locale.languageCode == 'zh' ? '显示数据' : 'Display Data';
  String get dataToDisplay =>
      locale.languageCode == 'zh' ? '要显示的数据' : 'Data to Display';
  String get enterDataToDisplay =>
      locale.languageCode == 'zh' ? '输入文本（最多9个字符）' : 'Enter text (max 9 chars)';
  String get numbersLettersSupported => locale.languageCode == 'zh'
      ? '支持数字、字母和符号'
      : 'Numbers, letters, and symbols supported';
  String get alignment => locale.languageCode == 'zh' ? '对齐方式：' : 'Alignment:';
  String get leftAlign => locale.languageCode == 'zh' ? '左对齐' : 'Left';
  String get rightAlign => locale.languageCode == 'zh' ? '右对齐' : 'Right';
  String get send => locale.languageCode == 'zh' ? '发送' : 'Send';
  String get clearSegment =>
      locale.languageCode == 'zh' ? '清空显示' : 'Clear Display';
  String get fullDisplay =>
      locale.languageCode == 'zh' ? '全亮显示' : 'Full Display';
  String get full => locale.languageCode == 'zh' ? '全亮' : 'Full';
  String get deviceInformation =>
      locale.languageCode == 'zh' ? '设备信息' : 'Device Information';
  String get noDeviceFound =>
      locale.languageCode == 'zh' ? '未找到设备' : 'No device found';
  String get deviceFound =>
      locale.languageCode == 'zh' ? '找到设备：' : 'Device found:';
  String get noSegmentDeviceFound =>
      locale.languageCode == 'zh' ? '未找到数码管设备' : 'No segment device found';
  String get displayControl =>
      locale.languageCode == 'zh' ? '显示控制' : 'Display Control';
  String get history => locale.languageCode == 'zh' ? '历史记录' : 'History';
  String get noHistoryYet =>
      locale.languageCode == 'zh' ? '暂无历史记录' : 'No history yet';
  String get usbPermissionGranted =>
      locale.languageCode == 'zh' ? 'USB 权限已授予' : 'USB permission granted';
  String get usbPermissionDenied =>
      locale.languageCode == 'zh' ? 'USB 权限被拒绝' : 'USB permission denied';
  String get connectedToSegment =>
      locale.languageCode == 'zh' ? '已连接到数码管设备' : 'Connected to segment device';
  String get pleaseEnterData => locale.languageCode == 'zh'
      ? '请输入要显示的数据'
      : 'Please enter data to display';
  String get pleaseConnectFirst =>
      locale.languageCode == 'zh' ? '请先连接设备' : 'Please connect to device first';
  String get dataSent => locale.languageCode == 'zh' ? '数据已发送' : 'Data sent';
  String get displaySetToFull =>
      locale.languageCode == 'zh' ? '显示已设置为全亮' : 'Display set to full';
  String get findDeviceFailed =>
      locale.languageCode == 'zh' ? '查找设备失败' : 'Find device failed';
  String get requestPermissionFailed =>
      locale.languageCode == 'zh' ? '请求权限失败' : 'Request permission failed';
  String get connectFailed =>
      locale.languageCode == 'zh' ? '连接失败' : 'Connect failed';
  String get sendDataFailed =>
      locale.languageCode == 'zh' ? '发送数据失败' : 'Send data failed';
  String get clearFailed =>
      locale.languageCode == 'zh' ? '清空失败' : 'Clear failed';
  String get fullDisplayFailed =>
      locale.languageCode == 'zh' ? '全亮显示失败' : 'Full display failed';
  String get disconnectFailed =>
      locale.languageCode == 'zh' ? '断开失败' : 'Disconnect failed';
  String get clearDisplayAction =>
      locale.languageCode == 'zh' ? '清空显示' : 'Clear display';
  String get fullDisplayTest =>
      locale.languageCode == 'zh' ? '全亮显示（测试）' : 'Full display (test)';
  String get segmentTips => locale.languageCode == 'zh'
      ? '• 连接 USB 数码管设备\n• 点击"查找设备"\n• 授予 USB 权限\n• 点击"连接数码管"\n• 输入数据并显示'
      : '• Connect USB segment display\n• Click "Find Device"\n• Grant USB permission\n• Click "Connect Segment"\n• Enter data and display';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
