# Changelog

## 🎉 v1.0.0 - 2026-01-25 - **100% 完成度达成！**

### 项目里程碑
**所有 12 个硬件功能全部实现完成！**

### 完成功能列表
1. ✅ 双屏显示 (Display) - v0.1.0
2. ✅ 钱箱控制 (CashBox) - v0.2.0
3. ✅ 灯光控制 (Light) - v0.3.0
4. ✅ NFC 读卡 (NFC) - v0.4.0
5. ✅ 扫码器 (Scanner) - v0.5.0
6. ✅ 磁条卡 (MSR) - v0.6.0
7. ✅ 串口通信 (Serial) - v0.7.0
8. ✅ 电子秤 (Scale) - v0.8.0
9. ✅ 数码管显示 (Segment) - v0.9.0
10. ✅ 悬浮窗 (Floating Window) - v0.10.0
11. ✅ 摄像头扫码 (Camera Scan) - v0.11.0
12. ✅ RFID - v1.0.0

### 项目统计
- **完成度**: 100% (12/12)
- **代码行数**: ~10,500 行
- **开发时间**: 11 天
- **文档数量**: 22 个

---

## 1.0.0 - 2026-01-25

### Added - RFID 功能
- RFID 设备连接管理
- 标签连续读取和单次读取
- 标签写入（任意 Bank）
- 标签锁定（3种锁定类型）
- 标签销毁（Kill）
- 配置管理（功率/过滤/RSSI/Gen2Q/Session/Target/RfMode）
- 电池监控（电量/充电状态）
- 3个 EventChannel 实时数据流

### Features
- `IminRfid.connect()` - 连接 RFID 设备
- `IminRfid.disconnect()` - 断开连接
- `IminRfid.isConnected()` - 检查连接状态
- `IminRfid.startReading()` - 开始连续读取标签
- `IminRfid.stopReading()` - 停止读取标签
- `IminRfid.readTag()` - 读取指定标签数据
- `IminRfid.clearTags()` - 清空标签列表
- `IminRfid.writeTag()` - 写入标签数据
- `IminRfid.writeEpc()` - 写入 EPC 数据
- `IminRfid.lockTag()` - 锁定标签
- `IminRfid.killTag()` - 销毁标签
- `IminRfid.setPower()` - 设置读写功率
- `IminRfid.setFilter()` - 设置标签过滤器
- `IminRfid.clearFilter()` - 清除过滤器
- `IminRfid.setRssiFilter()` - 设置 RSSI 过滤器
- `IminRfid.setGen2Q()` - 设置 Gen2 Q 值
- `IminRfid.setSession()` - 设置会话模式
- `IminRfid.setTarget()` - 设置目标模式
- `IminRfid.setRfMode()` - 设置 RF 模式
- `IminRfid.getBatteryLevel()` - 获取电池电量
- `IminRfid.isCharging()` - 检查充电状态
- `IminRfid.tagStream` - 标签事件流
- `IminRfid.connectionStream` - 连接状态流
- `IminRfid.batteryStream` - 电池状态流

### Data Models
- `RfidEvent` - RFID 事件（标签/读取/写入/锁定/销毁/错误）
- `RfidTag` - RFID 标签（EPC/PC/TID/RSSI/Count/Frequency）
- `BatteryStatus` - 电池状态（电量/充电状态）
- `RfidBank` - 存储区域常量（Reserved/EPC/TID/USER）
- `LockObject` - 锁定对象常量（KillPassword/AccessPassword/EPC/TID/USER）
- `LockType` - 锁定类型常量（Unlock/Lock/PermanentLock）
- `SessionMode` - 会话模式常量（S0/S1/S2/S3）
- `TargetMode` - 目标模式常量（A/B/A->B/B->A）
- `RfMode` - RF 模式常量（11种模式）

### Technical Implementation
- `IminRfidSdk 1.0.5` for RFID operations
- `RFIDManager` singleton for device management
- `ReaderCall` callback interface for tag events
- 3 separate `EventChannel` for real-time data streaming
- `BroadcastReceiver` for connection status monitoring
- System properties for battery and connection status
- Automatic reconnection mechanism
- Tag deduplication using HashMap

### Permissions
- No additional permissions required (RFID device access)

### Supported Devices
- iMin Lark 1 (with RFID module)

### Usage Example
```dart
// Connect to RFID device
await IminRfid.connect();

// Start reading tags
await IminRfid.startReading();

// Listen to tag stream
IminRfid.tagStream.listen((event) {
  if (event.isTag) {
    final tag = event.tag!;
    print('EPC: ${tag.epc}, RSSI: ${tag.rssi}');
  }
});

// Write EPC
await IminRfid.writeEpc(
  newEpc: 'E200123456789012',
  password: '00000000',
);

// Lock tag
await IminRfid.lockTag(
  lockObject: LockObject.epc,
  lockType: LockType.lock,
  password: '00000000',
);
```

---

## 0.11.0 - 2026-01-23

### Added
- Segment display (digital tube) API for customer-facing displays
- USB device connection and permission management
- Support for left and right text alignment
- Display clear and full test functions

### Features
- `IminSegment.findDevice()` - Find segment display USB device
- `IminSegment.requestPermission()` - Request USB device permission
- `IminSegment.connect()` - Connect to segment display
- `IminSegment.sendData()` - Send data to display (max 9 characters)
- `IminSegment.clear()` - Clear display content
- `IminSegment.full()` - Set display to full (test mode)
- `IminSegment.disconnect()` - Disconnect from device

### Technical Implementation
- USB communication with custom protocol (0xFC header)
- Checksum validation for data integrity
- Background reading thread for device responses
- USB permission broadcast receiver
- Support for PID 8455 / VID 16701 devices

### Protocol Details
- Header: 0xFC 0xFC
- Commands: 0x00 (right align), 0x01 (left align), 0x03 (clear), 0x04 (full)
- Data format: [header(2)] [len(1)] [cmd(1)] [data(n)] [checksum(1)]
- Max data length: 9 characters

### Permissions
- USB device access (automatic permission request)
- USB host feature required

### Supported Devices
- iMin devices with segment display support
- USB segment displays with PID 8455 / VID 16701

### Usage Example
```dart
// Find and connect to device
final result = await IminSegment.findDevice();
if (result['found']) {
  await IminSegment.requestPermission();
  await IminSegment.connect();
  
  // Display price
  await IminSegment.sendData('12.50', align: 'right');
  
  // Clear display
  await IminSegment.clear();
}
```

## 0.8.0 - 2026-01-19

### Added
- Electronic scale API for weight measurement
- Real-time weight data stream using EventChannel
- Weight stability detection (stable/unstable/overweight)
- Tare and zero functions

### Features
- `IminScale.connect()` - Connect to electronic scale with custom device path
- `IminScale.disconnect()` - Disconnect from scale
- `IminScale.tare()` - Remove peel (tare function)
- `IminScale.zero()` - Turn zero (calibration)
- `IminScale.weightStream` - Stream of weight data (EventChannel)
- `ScaleData` class with weight and status
- `ScaleStatus` enum (stable, unstable, overweight, unknown)

### Technical Implementation
- `NeoStraElectronicSDK` for scale communication
- Serial port communication (ttyS1-4, ttyUSB0)
- `ElectronicCallback` interface for real-time data
- `EventChannel` for weight data streaming
- Status-based UI color coding (green/orange/red)

### Device Support
- Multiple serial port paths: /dev/ttyS1-4, /dev/ttyUSB0
- Default baud rate: 9600
- Real-time weight updates
- Automatic stability detection

---

## 0.7.0 - 2026-01-17

### Added
- Serial port communication API for universal serial device control
- Real-time serial data stream using EventChannel
- Support for multiple baud rates (9600-115200)
- Background reading thread for continuous data reception
- Hex and text data transmission support

### Features
- `IminSerial.open()` - Open serial port with custom path and baud rate
- `IminSerial.close()` - Close serial port
- `IminSerial.write()` - Write byte data to serial port
- `IminSerial.isOpen()` - Check if serial port is open
- `IminSerial.dataStream` - Stream of serial data (EventChannel)
- `SerialData` class with data, bytes, and text conversion

### Technical Implementation
- `NeoStra SerialPort SDK` for serial communication
- `libiminSerialPort.so` native library (4 architectures)
- Background reading thread for continuous data reception
- `EventChannel` for real-time data streaming
- Automatic resource cleanup on port close

### Dependencies
- Added `NeoStraElectronicSDK-3-v1.3_2302281129.jar`
- Added `libiminSerialPort.so` for arm64-v8a, armeabi-v7a, x86, x86_64

### Permissions
- No additional permissions required (serial port access)

### Supported Devices
- All iMin devices with serial ports

### Common Use Cases
- Electronic scale communication
- Printer control
- Scanner integration
- Custom serial device control

## 0.6.0 - 2026-01-17

### Added
- MSR (Magnetic Stripe Reader) API for reading magnetic stripe cards
- Simple keyboard input-based card reading
- MSR availability checking

### Features
- `IminMsr.isAvailable()` - Check if MSR functionality is available
- Automatic card data reception through keyboard input
- No special API calls needed for reading card data

### Technical Implementation
- MSR devices work as keyboard input devices
- Card data automatically appears in focused text fields
- Minimal API surface for maximum simplicity

### Usage
```dart
// Simply use a TextField to receive MSR input
TextField(
  controller: _msrController,
  onSubmitted: (value) {
    // Process card data
    print('Card data: $value');
  },
)
```

### Permissions
- No additional permissions required

### Supported Devices
- iMin Crane 1, Swan 2, M2-Pro

## 0.5.0 - 2026-01-17

### Added
- Hardware scanner API for barcode/QR code scanning
- Real-time scan result stream using EventChannel
- Support for multiple barcode formats (QR Code, EAN, Code128, etc.)
- Scanner device connection status monitoring
- Custom broadcast configuration for different scanner models
- Scan history management with timestamp tracking

### Features
- `IminScanner.configure()` - Configure custom broadcast parameters
- `IminScanner.startListening()` - Start listening for scan broadcasts
- `IminScanner.stopListening()` - Stop listening for scan broadcasts
- `IminScanner.isConnected()` - Check scanner device connection status
- `IminScanner.scanStream` - Stream of scanner events (EventChannel)
- `ScanResult` class with data, label type, and raw bytes
- Device connection/disconnection event notifications

### Technical Implementation
- `BroadcastReceiver` for receiving scan results from hardware scanner
- `SystemProperties` for querying scanner connection status
- `EventChannel` for real-time scan data streaming
- Configurable broadcast actions and extra keys for compatibility

### Broadcast Configuration
- Default action: `com.imin.scanner.api.RESULT_ACTION`
- String data key: `decode_data_str`
- Byte data key: `decode_data`
- Label type key: `com.imin.scanner.api.label_type`

### Permissions
- No additional permissions required (USB scanner)

### Supported Devices
- iMin Crane 1, Swan 2, Swift 1/2 Ultra, Lark 1, Falcon 2, M2-Pro

## 0.4.0 - 2026-01-17

### Added
- NFC reader API for reading NFC tags
- Real-time NFC tag stream using EventChannel
- Support for reading NFC ID (card number) and NDEF content
- NFC status checking and settings navigation
- Activity lifecycle management for NFC foreground dispatch
- Scan history with timestamp tracking

### Features
- `IminNfc.isAvailable()` - Check if NFC hardware is available
- `IminNfc.isEnabled()` - Check if NFC is enabled
- `IminNfc.openSettings()` - Open NFC settings page
- `IminNfc.tagStream` - Stream of NFC tags (EventChannel)
- `NfcTag` class with formatted ID display
- Automatic foreground dispatch management

### Technical Implementation
- Plugin implements `ActivityAware` for lifecycle management
- `onNewIntentListener` for receiving NFC intents
- `EventChannel` for real-time tag data streaming
- `ActivityLifecycleCallbacks` for automatic foreground dispatch

### Permissions
- Added `android.permission.NFC` permission
- Added `android.hardware.nfc` feature (optional)
- Activity `launchMode="singleTop"` for onNewIntent handling

### Supported Devices
- iMin Crane 1, Swan 1/2, Swift 1/2/2 Ultra, Lark 1, Falcon 2, M2-Pro

## 0.3.0 - 2026-01-17

### Added
- Light control API for USB LED indicator lights
- Support for red and green lights
- USB device connection management
- USB permissions configuration

### Features
- `IminLight.connect()` - Connect to USB light device
- `IminLight.turnOnGreen()` - Turn on green light
- `IminLight.turnOnRed()` - Turn on red light
- `IminLight.turnOff()` - Turn off all lights
- `IminLight.disconnect()` - Disconnect from light device

### Permissions
- Added `android.hardware.usb.host` feature for USB device access
- Automatic USB permission request handling

### Supported Devices
- iMin Crane 1, M2-Pro

## 0.2.0 - 2026-01-17

### Added
- Cash box control API
- Real-time cash box status monitoring
- Voltage configuration support (9V/12V/24V)

### Features
- `IminCashBox.open()` - Open cash drawer
- `IminCashBox.getStatus()` - Get cash box status (open/closed)
- `IminCashBox.setVoltage()` - Set cash box voltage

### Supported Devices
- iMin Crane 1, Swan 1/2/3, Falcon 2, D4, M2-Pro

## 0.1.0 - 2026-01-15

### Added
- Initial release
- Secondary display control API
- Support for text, image, and video display on secondary screen
- Example app demonstrating display features

### Features
- `IminDisplay.isAvailable()` - Check if secondary display exists
- `IminDisplay.enable()` - Enable secondary display
- `IminDisplay.disable()` - Disable secondary display
- `IminDisplay.showText()` - Display text on secondary screen
- `IminDisplay.showImage()` - Display image on secondary screen
- `IminDisplay.playVideo()` - Play video on secondary screen
- `IminDisplay.clear()` - Clear secondary display content

### Supported Devices
- iMin Crane 1, Swan 1/2/3, Swift 1/2, Lark 1, Falcon 2, D4, M2-Pro


---

## 0.11.0 - 2026-01-23

### Added - 摄像头扫码功能
- 完整移植 scanlibrary 模块（ZXing + CameraX）
- 支持 17 种条码/二维码格式
- 自定义扫码配置（格式/提示/闪光灯/提示音/超时）
- 便捷扫码方法（快速扫码/仅二维码/仅条形码/全格式）

### Features
- `CameraScanApi.scan()` - 自定义扫码
- `CameraScanApi.scanQuick()` - 快速扫码（默认格式）
- `CameraScanApi.scanQRCode()` - 仅扫描二维码
- `CameraScanApi.scanBarcode()` - 仅扫描条形码
- `CameraScanApi.scanAll()` - 扫描所有格式

### Supported Formats
- 一维码（12种）: CODE_128, CODE_39, CODE_93, CODABAR, EAN_8, EAN_13, UPC_A, UPC_E, ITF, RSS_14, RSS_EXPANDED, UPC_EAN_EXTENSION
- 二维码（5种）: QR_CODE, DATA_MATRIX, PDF_417, AZTEC, MAXICODE

---

## 0.10.0 - 2026-01-22

### Added - 悬浮窗功能
- 系统悬浮窗显示
- 悬浮窗内容实时更新
- 悬浮窗位置设置
- 触摸拖动支持

### Features
- `FloatingWindowApi.show()` - 显示悬浮窗
- `FloatingWindowApi.hide()` - 隐藏悬浮窗
- `FloatingWindowApi.isShowing()` - 检查显示状态
- `FloatingWindowApi.updateText()` - 更新文本内容
- `FloatingWindowApi.setPosition()` - 设置窗口位置
