# iMin 硬件插件

[![pub package](https://img.shields.io/pub/v/imin_hardware_plugin.svg)](https://pub.dev/packages/imin_hardware_plugin)
[![GitHub](https://img.shields.io/github/stars/iminsoftware/FlutterApiTest?style=social)](https://github.com/iminsoftware/FlutterApiTest)

[English](README.md) | [中文文档](README_CN.md)

一个全面的 Flutter 插件，用于控制 iMin POS 设备的硬件功能。

## 功能特性

| 模块 | 说明 |
|------|------|
| 📺 Display | 副屏显示控制 |
| 💰 Cashbox | 钱箱控制 |
| 💡 Light | LED 指示灯 |
| 💳 NFC | NFC 卡片读取 |
| 📷 Scanner | 条码/二维码扫描 |
| 💳 MSR | 磁条卡读取 |
| ⚖️ Scale | 电子秤 (Android 13+) |
| 🔌 Serial | 串口通信 |
| 🔢 Segment | 数码管显示 |
| 🪟 Floating Window | 悬浮窗口 |
| 📸 Camera | 相机扫描 |
| 📡 RFID | RFID 标签操作 |
| 📱 Device | 设备信息 |

## 支持设备

iMin D4、M2-Pro、Swan、Swift、Crane、Lark、Falcon 系列

## 安装

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

```bash
flutter pub get
```

## 快速开始

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// 扫描器
IminScanner.startScan();
IminScanner.scanStream.listen((code) => print('扫描结果: $code'));

// NFC
IminNfc.startNfc();
IminNfc.nfcStream.listen((tag) => print('NFC: ${tag.id}'));

// 电子秤
await IminScaleNew.connectService();
await IminScaleNew.getData();
IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) print('重量: ${event.data.net}kg');
});
```

## 文档

### 📖 完整指南

- [副屏显示模块](docs/DISPLAY_CN.md) - 副屏显示控制
- [钱箱模块](docs/CASHBOX_CN.md) - 钱箱操作
- [LED 灯模块](docs/LIGHT_CN.md) - LED 指示灯控制
- [NFC 模块](docs/NFC_CN.md) - NFC 卡片读取
- [扫描器模块](docs/SCANNER_CN.md) - 条码扫描
- [MSR 模块](docs/MSR_CN.md) - 磁条卡读取
- [电子秤模块](docs/SCALE_CN.md) - 电子秤称重
- [串口模块](docs/SERIAL_CN.md) - 串口通信
- [数码管模块](docs/SEGMENT_CN.md) - 数码管显示
- [悬浮窗模块](docs/FLOATING_WINDOW_CN.md) - 悬浮窗口
- [相机模块](docs/CAMERA_CN.md) - 相机扫描
- [RFID 模块](docs/RFID_CN.md) - RFID 操作
- [设备模块](docs/DEVICE_CN.md) - 设备信息

## 示例应用

查看 [example](example/) 目录获取完整示例应用。

## 系统要求

- Flutter >=3.3.0
- Dart >=3.0.0
- Android minSdkVersion 21
- iMin POS 设备

## 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.NFC" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
```

## 支持

- 📧 [GitHub Issues](https://github.com/iminsoftware/FlutterApiTest/issues)
- 📖 [文档](https://pub.dev/packages/imin_hardware_plugin)
- 🌐 [官网](https://www.imin.sg)

## 许可证

MIT License - 查看 [LICENSE](LICENSE)

---

由 [iMin Technology](https://www.imin.sg) 用 ❤️ 制作
