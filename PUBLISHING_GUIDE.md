# Flutter 插件发布完整指南

## 目录

1. [发布前准备](#发布前准备)
2. [发布到 pub.dev](#发布到-pubdev)
3. [发布到私有仓库](#发布到私有仓库)
4. [发布到 GitHub](#发布到-github)
5. [版本管理](#版本管理)
6. [常见问题](#常见问题)

---

## 发布前准备

### 1. 完善 pubspec.yaml

```yaml
name: imin_hardware_plugin
description: iMin hardware plugin for Flutter, supporting printer, scanner, NFC, RFID, scale, and more.
version: 1.0.0
homepage: https://github.com/your-username/imin_hardware_plugin
repository: https://github.com/your-username/imin_hardware_plugin
issue_tracker: https://github.com/your-username/imin_hardware_plugin/issues

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  plugin:
    platforms:
      android:
        package: com.imin.hardware
        pluginClass: IminHardwarePlugin
```

### 2. 完善 README.md

创建详细的 README.md：

```markdown
# iMin Hardware Plugin

A Flutter plugin for iMin hardware devices, supporting printer, scanner, NFC, RFID, electronic scale, and more.

## Features

- 🖨️ **Printer**: Print text, images, barcodes, QR codes
- 📷 **Scanner**: Barcode and QR code scanning
- 💳 **NFC**: NFC card reading and writing
- 📡 **RFID**: RFID tag reading
- ⚖️ **Electronic Scale**: Weight measurement and pricing
- 💰 **Cash Drawer**: Cash drawer control
- 📺 **LED Display**: Customer display control
- 🪟 **Floating Window**: Floating window management

## Supported Devices

- iMin D4 series
- iMin M2 series
- iMin Swift series
- Other iMin Android devices

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Printer Example

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// Initialize printer
await IminPrinter.initPrinter();

// Print text
await IminPrinter.printText("Hello World");

// Print and feed paper
await IminPrinter.printAndFeedPaper(100);
```

### Scanner Example

```dart
// Start scanning
IminScanner.startScan();

// Listen to scan results
IminScanner.scanStream.listen((barcode) {
  print('Scanned: $barcode');
});
```

### Electronic Scale Example

```dart
// Connect to scale
await IminScaleNew.connectService();

// Start getting weight data
await IminScaleNew.getData();

// Listen to weight events
IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) {
    final data = event.data as ScaleWeightData;
    print('Weight: ${data.net}kg');
  }
});
```

## Documentation

For detailed documentation, see:
- [API Reference](https://pub.dev/documentation/imin_hardware_plugin/latest/)
- [Example App](https://github.com/your-username/imin_hardware_plugin/tree/main/example)

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0
- Android: minSdkVersion 21

## License

MIT License - see [LICENSE](LICENSE) file for details

## Support

- 📧 Email: support@example.com
- 🐛 Issues: [GitHub Issues](https://github.com/your-username/imin_hardware_plugin/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/your-username/imin_hardware_plugin/discussions)
```

### 3. 创建 CHANGELOG.md

```markdown
# Changelog

## 1.0.0 - 2024-02-02

### Added
- Initial release
- Printer support (text, images, barcodes, QR codes)
- Scanner support (barcode, QR code)
- NFC support (card reading/writing)
- RFID support (tag reading)
- Electronic scale support (weight measurement, pricing)
- Cash drawer control
- LED display control
- Floating window management

### Features
- Complete API documentation
- Example application
- Comprehensive error handling
- Event stream support

### Supported Devices
- iMin D4 series
- iMin M2 series
- iMin Swift series
```

### 4. 创建 LICENSE 文件

```
MIT License

Copyright (c) 2024 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

### 5. 创建 example 应用

确保 `example` 目录下有完整的示例应用：

```
example/
├── lib/
│   ├── main.dart
│   └── pages/
│       ├── printer_page.dart
│       ├── scanner_page.dart
│       ├── nfc_page.dart
│       ├── scale_page.dart
│       └── ...
├── pubspec.yaml
└── README.md
```

### 6. 代码质量检查

```bash
# 运行代码分析
flutter analyze

# 运行测试
flutter test

# 检查发布准备
flutter pub publish --dry-run
```

---

## 发布到 pub.dev

### 步骤 1: 注册 pub.dev 账号

1. 访问 https://pub.dev
2. 使用 Google 账号登录
3. 完善个人信息

### 步骤 2: 验证发布准备

```bash
cd FlutterApiTest

# 检查发布准备（不会真正发布）
flutter pub publish --dry-run
```

检查输出，确保没有错误或警告。

### 步骤 3: 发布插件

```bash
# 正式发布
flutter pub publish
```

系统会提示：
1. 确认包信息
2. 输入 `y` 确认
3. 在浏览器中完成 Google 账号验证
4. 等待发布完成

### 步骤 4: 验证发布

1. 访问 https://pub.dev/packages/imin_hardware_plugin
2. 检查包信息是否正确
3. 查看文档是否正常显示

### 发布后维护

```bash
# 更新版本
# 1. 修改 pubspec.yaml 中的 version
# 2. 更新 CHANGELOG.md
# 3. 重新发布

flutter pub publish
```

---

## 发布到私有仓库

### 方案 1: 使用 Git 依赖

#### 1. 推送到 Git 仓库

```bash
cd FlutterApiTest

# 初始化 Git（如果还没有）
git init

# 添加远程仓库
git remote add origin https://github.com/your-username/imin_hardware_plugin.git

# 提交代码
git add .
git commit -m "Initial commit"
git push -u origin main

# 创建版本标签
git tag v1.0.0
git push origin v1.0.0
```

#### 2. 在其他项目中使用

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/your-username/imin_hardware_plugin.git
      ref: v1.0.0  # 或者使用 branch: main
```

### 方案 2: 使用私有 pub 服务器

#### 1. 搭建私有 pub 服务器

使用 [unpub](https://github.com/bytedance/unpub):

```bash
# 安装 unpub
dart pub global activate unpub

# 启动服务器
unpub --database mongodb://localhost:27017/dart_pub
```

#### 2. 配置发布地址

创建 `~/.pub-cache/credentials.json`:

```json
{
  "accessToken": "your-access-token",
  "refreshToken": "your-refresh-token",
  "tokenEndpoint": "http://your-server.com/api/oauth/token",
  "scopes": ["openid", "https://pub.dartlang.org/api/scopes/version:create"],
  "expiration": 1234567890000
}
```

#### 3. 发布到私有服务器

```bash
flutter pub publish --server=http://your-server.com
```

#### 4. 在其他项目中使用

```yaml
# pubspec.yaml
dependencies:
  imin_hardware_plugin: ^1.0.0

# 配置私有仓库
# 在项目根目录创建 .pub-cache/credentials.json
```

### 方案 3: 使用本地路径

```yaml
dependencies:
  imin_hardware_plugin:
    path: ../imin_hardware_plugin
```

---

## 发布到 GitHub

### 1. 创建 GitHub 仓库

```bash
# 在 GitHub 上创建新仓库
# 然后在本地：

cd FlutterApiTest
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your-username/imin_hardware_plugin.git
git push -u origin main
```

### 2. 创建 Release

```bash
# 创建标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

在 GitHub 上：
1. 进入仓库页面
2. 点击 "Releases"
3. 点击 "Create a new release"
4. 选择标签 `v1.0.0`
5. 填写 Release 标题和说明
6. 上传编译好的文件（可选）
7. 点击 "Publish release"

### 3. 添加 GitHub Actions

创建 `.github/workflows/publish.yml`:

```yaml
name: Publish

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: dart-lang/setup-dart@v1
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Run tests
        run: flutter test
      
      - name: Publish to pub.dev
        run: flutter pub publish --force
        env:
          PUB_CREDENTIALS: ${{ secrets.PUB_CREDENTIALS }}
```

---

## 版本管理

### 语义化版本

遵循 [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.0.0 → 1.0.1  (补丁版本：bug 修复)
1.0.1 → 1.1.0  (次版本：新功能，向后兼容)
1.1.0 → 2.0.0  (主版本：破坏性变更)
```

### 版本更新流程

```bash
# 1. 修改代码
# 2. 更新版本号
# 编辑 pubspec.yaml
version: 1.0.1

# 3. 更新 CHANGELOG.md
## 1.0.1 - 2024-02-03
### Fixed
- Fixed scale callback issue

# 4. 提交代码
git add .
git commit -m "Release v1.0.1"
git tag v1.0.1
git push origin main
git push origin v1.0.1

# 5. 发布
flutter pub publish
```

### 预发布版本

```yaml
# pubspec.yaml
version: 1.1.0-beta.1
```

```bash
flutter pub publish --dry-run
flutter pub publish
```

---

## 常见问题

### Q1: 发布失败：Package validation failed

**原因**: 代码质量问题或配置错误

**解决**:
```bash
# 运行检查
flutter pub publish --dry-run

# 查看具体错误
flutter analyze
```

### Q2: 发布失败：Authentication failed

**原因**: 未登录或凭证过期

**解决**:
```bash
# 清除凭证
rm ~/.pub-cache/credentials.json

# 重新发布（会提示登录）
flutter pub publish
```

### Q3: 如何撤回已发布的版本？

**答**: pub.dev 不支持删除已发布的版本，但可以：

1. 发布新版本修复问题
2. 标记版本为 "discontinued"（联系 pub.dev 支持）

### Q4: 如何更新插件文档？

**答**: 文档会自动从代码注释生成

```dart
/// 打印文本
///
/// [text] 要打印的文本内容
/// 
/// 示例:
/// ```dart
/// await IminPrinter.printText("Hello World");
/// ```
Future<void> printText(String text) async {
  // ...
}
```

### Q5: 如何添加示例图片？

在 README.md 中：

```markdown
## Screenshots

<img src="https://raw.githubusercontent.com/your-username/imin_hardware_plugin/main/screenshots/printer.png" width="300">
```

### Q6: 如何设置最低 Flutter 版本？

```yaml
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.0.0"
```

### Q7: 如何处理 Android 权限？

在 README.md 中说明：

```markdown
## Android Setup

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```

---

## 发布检查清单

发布前确认：

- [ ] pubspec.yaml 配置完整
- [ ] README.md 详细清晰
- [ ] CHANGELOG.md 已更新
- [ ] LICENSE 文件存在
- [ ] example 应用完整可运行
- [ ] 代码通过 `flutter analyze`
- [ ] 测试通过 `flutter test`
- [ ] `flutter pub publish --dry-run` 无错误
- [ ] 版本号符合语义化版本规范
- [ ] Git 标签已创建
- [ ] 文档注释完整

---

## 推荐工具

### 1. 版本管理

```bash
# 安装 cider（版本管理工具）
dart pub global activate cider

# 更新版本
cider bump patch  # 1.0.0 → 1.0.1
cider bump minor  # 1.0.1 → 1.1.0
cider bump major  # 1.1.0 → 2.0.0
```

### 2. 文档生成

```bash
# 生成 API 文档
dart doc .

# 查看文档
open doc/api/index.html
```

### 3. 代码格式化

```bash
# 格式化代码
dart format .

# 检查格式
dart format --set-exit-if-changed .
```

---

## 总结

发布 Flutter 插件的完整流程：

1. **准备阶段**
   - 完善 pubspec.yaml
   - 编写 README.md
   - 创建 CHANGELOG.md
   - 添加 LICENSE
   - 完善示例应用

2. **质量检查**
   - 运行 `flutter analyze`
   - 运行 `flutter test`
   - 运行 `flutter pub publish --dry-run`

3. **发布**
   - 发布到 pub.dev: `flutter pub publish`
   - 或发布到 Git: `git push` + `git tag`
   - 或发布到私有服务器

4. **维护**
   - 更新版本号
   - 更新 CHANGELOG
   - 重新发布

遵循这个指南，你的 Flutter 插件就可以成功发布了！
