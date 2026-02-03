# 国际化适配指南

## 概述

本文档说明如何为 FlutterApiTest 的各个页面添加中英文国际化支持。

## 更新日期

2026-01-26

## 已完成的工作

### 1. 国际化文件扩展

已在 `example/lib/l10n/app_localizations.dart` 中添加了所有页面需要的翻译：

- ✅ 主页面（HomePage）
- ✅ 双屏显示页面（DisplayPage）
- ✅ 钱箱页面（CashBoxPage）
- ✅ 灯光控制页面（LightPage）
- ✅ NFC 页面（NfcPage）
- ✅ 扫码器页面（ScannerPage）
- ✅ 磁条卡页面（MsrPage）
- ✅ 电子秤页面（ScalePage）
- ✅ 串口页面（SerialPage）
- ✅ RFID 页面（RfidPage）
- ✅ 数码管页面（SegmentPage）
- ✅ 摄像头扫码页面（CameraScanPage）
- ✅ 悬浮窗页面（FloatingWindowPage）

### 2. 新增翻译数量

- **总计**: 150+ 个翻译键值对
- **中文**: 完整支持
- **英文**: 完整支持

## 使用方法

### 1. 导入国际化

在页面顶部导入：

```dart
import '../l10n/app_localizations.dart';
```

### 2. 获取本地化对象

在 `build` 方法中：

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  
  // 使用翻译
  return Text(l10n.status);
}
```

### 3. 替换硬编码文本

**之前**:
```dart
Text('NFC Status')
```

**之后**:
```dart
Text(l10n.nfcStatus)
```

## 完整示例：NFC 页面改造

### 改造前

```dart
setState(() {
  _statusMessage = 'NFC not available on this device';
});
```

### 改造后

```dart
setState(() {
  _statusMessage = l10n.nfcNotAvailable;
});
```

### 完整代码示例

```dart
import 'package:flutter/material.dart';
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';
import '../l10n/app_localizations.dart';

class NfcPage extends StatefulWidget {
  const NfcPage({super.key});

  @override
  State<NfcPage> createState() => _NfcPageState();
}

class _NfcPageState extends State<NfcPage> {
  bool _isAvailable = false;
  bool _isEnabled = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkNfcStatus();
  }

  Future<void> _checkNfcStatus() async {
    final l10n = AppLocalizations.of(context);
    
    setState(() {
      _statusMessage = l10n.checkingNfcStatus;
    });

    try {
      final available = await IminNfc.isAvailable();
      final enabled = await IminNfc.isEnabled();

      if (mounted) {
        setState(() {
          _isAvailable = available;
          _isEnabled = enabled;
          _statusMessage = _getStatusMessage();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = '${l10n.error}: $e';
        });
      }
    }
  }

  String _getStatusMessage() {
    final l10n = AppLocalizations.of(context);
    
    if (!_isAvailable) {
      return l10n.nfcNotAvailable;
    }
    if (!_isEnabled) {
      return l10n.nfcDisabled;
    }
    return l10n.readyToScanNfc;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nfcReader),
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
                    l10n.nfcStatus,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_statusMessage),
                ],
              ),
            ),
          ),
          
          // Open Settings Button
          if (!_isEnabled)
            ElevatedButton(
              onPressed: () => IminNfc.openSettings(),
              child: Text(l10n.openNfcSettings),
            ),
          
          // Tips Card
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
                        l10n.tips,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.nfcTips),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 可用的翻译键

### 通用翻译

- `status` - 状态
- `checking` - 检查中...
- `ready` - 就绪
- `connected` / `disconnected` - 已连接 / 未连接
- `open` / `closed` - 打开 / 关闭
- `enable` / `disable` - 启用 / 禁用
- `connect` / `disconnect` - 连接 / 断开
- `tips` - 提示
- `error` - 错误
- `clear` - 清空

### NFC 页面

- `nfcStatus` - NFC 状态
- `checkingNfcStatus` - 检查 NFC 状态...
- `nfcNotAvailable` - 此设备不支持 NFC
- `nfcDisabled` - NFC 已禁用。请在设置中启用。
- `readyToScanNfc` - 准备扫描 NFC 标签
- `nfcAvailableAndEnabled` - NFC 可用且已启用
- `openNfcSettings` - 打开 NFC 设置
- `currentTag` - 当前标签
- `noTagDetected` - 未检测到标签
- `tagId` - 标签 ID
- `content` - 内容
- `technology` - 技术类型
- `timestamp` - 时间戳
- `tagHistory` - 标签历史
- `noTagHistory` - 暂无标签历史
- `clearHistory` - 清空历史
- `nfcTips` - NFC 使用提示

### 扫码器页面

- `scannerStatus` - 扫码器状态
- `scannerNotConnected` / `scannerConnected` - 扫码器未连接 / 已连接
- `startListening` / `stopListening` - 开始监听 / 停止监听
- `listening` / `notListening` - 监听中... / 未监听
- `lastScanData` - 最近扫码数据
- `noScanData` - 暂无扫码数据
- `data` - 数据
- `scanCount` - 扫码次数
- `scannerTips` - 扫码器使用提示

### 磁条卡页面

- `msrStatus` - 磁条卡状态
- `msrAvailable` / `msrNotAvailable` - 磁条卡读卡器可用 / 不可用
- `swipeCard` - 请刷卡
- `cardData` - 卡片数据
- `noCardData` - 暂无卡片数据
- `msrTips` - 磁条卡使用提示

### 电子秤页面

- `scaleStatus` - 电子秤状态
- `scaleNotConnected` / `scaleConnected` - 电子秤未连接 / 已连接
- `connectScale` / `disconnectScale` - 连接电子秤 / 断开电子秤
- `currentWeight` - 当前重量
- `noWeightData` - 暂无重量数据
- `weight` - 重量
- `unit` - 单位
- `stable` / `unstable` / `overweight` - 稳定 / 不稳定 / 超重
- `tare` / `zero` - 去皮 / 清零
- `devicePath` - 设备路径
- `baudRate` - 波特率
- `scaleTips` - 电子秤使用提示

### 串口页面

- `serialStatus` - 串口状态
- `serialNotOpen` / `serialOpen` - 串口未打开 / 已打开
- `openSerial` / `closeSerial` - 打开串口 / 关闭串口
- `sendData` - 发送数据
- `receivedData` - 接收数据
- `noReceivedData` - 暂无接收数据
- `dataToSend` - 要发送的数据
- `enterData` - 输入数据...
- `serialTips` - 串口使用提示

### RFID 页面

- `rfidStatus` - RFID 状态
- `rfidNotConnected` / `rfidConnected` - RFID 未连接 / 已连接
- `connectRfid` / `disconnectRfid` - 连接 RFID / 断开 RFID
- `startReading` / `stopReading` - 开始读取 / 停止读取
- `reading` / `notReading` - 读取中... / 未读取
- `detectedTags` - 检测到的标签
- `noTagsDetected` - 未检测到标签
- `epc` - EPC
- `rssi` - RSSI
- `count` - 次数
- `clearTags` - 清空标签
- `batteryLevel` - 电池电量
- `charging` / `notCharging` - 充电中 / 未充电
- `rfidTips` - RFID 使用提示

### 数码管页面

- `segmentStatus` - 数码管状态
- `segmentNotConnected` / `segmentConnected` - 数码管未连接 / 已连接
- `findDevice` - 查找设备
- `requestPermission` - 请求权限
- `connectSegment` / `disconnectSegment` - 连接数码管 / 断开数码管
- `displayData` - 显示数据
- `dataToDisplay` - 要显示的数据
- `enterDataToDisplay` - 输入要显示的数据（最多9个字符）
- `leftAlign` / `rightAlign` - 左对齐 / 右对齐
- `clearSegment` - 清空显示
- `fullDisplay` - 全亮显示
- `segmentTips` - 数码管使用提示

## 改造步骤

### 步骤 1: 导入国际化

在每个页面文件顶部添加：

```dart
import '../l10n/app_localizations.dart';
```

### 步骤 2: 获取本地化对象

在需要使用翻译的地方：

```dart
final l10n = AppLocalizations.of(context);
```

### 步骤 3: 替换所有硬编码文本

使用查找替换功能，将英文文本替换为对应的翻译键。

### 步骤 4: 测试

1. 切换系统语言到中文，验证显示
2. 切换系统语言到英文，验证显示
3. 确保所有文本都已翻译

## 注意事项

1. **Context 依赖**: `AppLocalizations.of(context)` 需要在 `build` 方法或有 `context` 的地方调用
2. **动态文本**: 对于包含变量的文本，使用字符串插值：
   ```dart
   Text('${l10n.error}: $errorMessage')
   ```
3. **多行文本**: 提示信息使用 `\n` 换行
4. **一致性**: 确保相同含义的文本使用相同的翻译键

## 待完成的页面

以下页面需要应用国际化（翻译已准备好，只需替换硬编码文本）：

- [ ] NFC 页面 (`nfc_page.dart`)
- [ ] 扫码器页面 (`scanner_page.dart`)
- [ ] 磁条卡页面 (`msr_page.dart`)
- [ ] 电子秤页面 (`scale_page.dart`)
- [ ] 串口页面 (`serial_page.dart`)
- [ ] RFID 页面 (`rfid_page.dart`)
- [ ] 数码管页面 (`segment_page.dart`)

已完成的页面：

- [x] 主页面 (`main.dart`)
- [x] 双屏显示页面 (`display_page.dart`)
- [x] 钱箱页面 (`cashbox_page.dart`)
- [x] 灯光控制页面 (`light_page.dart`)
- [x] 摄像头扫码页面 (`camera_scan_page.dart`)
- [x] 悬浮窗页面 (`floating_window_page.dart`)

## 贡献指南

如果要为其他页面添加国际化支持：

1. 检查 `app_localizations.dart` 中是否已有需要的翻译
2. 如果没有，先添加翻译键值对
3. 在页面中导入并使用翻译
4. 测试中英文显示
5. 更新本文档的完成状态

## 总结

所有翻译已准备就绪，只需在各个页面中应用即可。这将大大提升应用的国际化体验，让中英文用户都能流畅使用。
