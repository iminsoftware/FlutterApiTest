# 使用 Git 依赖安装指南

由于发布到 pub.dev 需要 Google 账号认证，如果无法访问 Google，可以直接使用 Git 依赖方式安装此插件。

## 安装方法

### 方法 1: 使用最新版本（推荐）

在你的 Flutter 项目的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
```

然后运行：

```bash
flutter pub get
```

### 方法 2: 使用特定版本

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: v1.0.0  # 使用特定的版本标签
```

### 方法 3: 使用特定分支

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: main  # 或其他分支名
```

### 方法 4: 使用特定 commit

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: abc123def456  # commit hash
```

## 完整示例

```yaml
name: my_pos_app
description: My POS application

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 使用 Git 依赖安装 iMin 硬件插件
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: v1.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

## 使用示例

安装完成后，就可以在代码中使用了：

```dart
import 'package:imin_hardware_plugin/imin_hardware_plugin.dart';

// 打印机示例
await IminPrinter.initPrinter();
await IminPrinter.printText("Hello World");

// 扫描器示例
IminScanner.startScan();
IminScanner.scanStream.listen((barcode) {
  print('Scanned: $barcode');
});

// 电子秤示例
await IminScaleNew.connectService();
await IminScaleNew.getData();
IminScaleNew.eventStream.listen((event) {
  if (event.isWeight) {
    print('Weight: ${event.data.net}kg');
  }
});
```

## 更新插件

### 更新到最新版本

```bash
# 删除依赖缓存
flutter pub cache repair

# 重新获取依赖
flutter pub get
```

### 更新到特定版本

修改 `pubspec.yaml` 中的 `ref` 值：

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://github.com/iminsoftware/FlutterApiTest.git
      ref: v1.1.0  # 更新版本号
```

然后运行：

```bash
flutter pub get
```

## 查看可用版本

访问 GitHub 仓库查看所有版本：

https://github.com/iminsoftware/FlutterApiTest/tags

## 优势

使用 Git 依赖的优势：

1. ✅ **无需 Google 账号** - 不需要访问 pub.dev
2. ✅ **直接从源码安装** - 获取最新代码
3. ✅ **支持私有仓库** - 可以使用私有 Git 仓库
4. ✅ **灵活的版本控制** - 可以使用分支、标签或 commit

## 注意事项

1. **首次安装较慢** - 需要克隆整个仓库
2. **需要 Git** - 确保系统已安装 Git
3. **网络要求** - 需要能访问 GitHub

## 如果无法访问 GitHub

### 使用 Gitee 镜像（如果有）

```yaml
dependencies:
  imin_hardware_plugin:
    git:
      url: https://gitee.com/iminsoftware/FlutterApiTest.git
```

### 使用本地路径

如果已经下载了源码：

```yaml
dependencies:
  imin_hardware_plugin:
    path: ../FlutterApiTest
```

## 常见问题

### Q1: 安装失败：Git not found

**A**: 需要安装 Git

```bash
# Windows
# 下载并安装：https://git-scm.com/download/win

# Mac
brew install git

# Linux
sudo apt-get install git
```

### Q2: 安装很慢

**A**: 可能是网络问题，尝试：

1. 使用 VPN
2. 配置 Git 代理
3. 使用 Gitee 镜像

### Q3: 如何查看已安装的版本？

**A**: 查看 `pubspec.lock` 文件：

```yaml
imin_hardware_plugin:
  dependency: "direct main"
  description:
    path: "."
    ref: v1.0.0
    resolved-ref: abc123def456
    url: "https://github.com/iminsoftware/FlutterApiTest.git"
  source: git
  version: "1.0.0"
```

### Q4: 如何切换到 pub.dev 版本？

**A**: 如果将来发布到了 pub.dev，修改 `pubspec.yaml`：

```yaml
dependencies:
  imin_hardware_plugin: ^1.0.0  # 使用 pub.dev 版本
```

## 开发者指南

如果你想贡献代码：

```bash
# 1. Fork 仓库
# 2. 克隆到本地
git clone https://github.com/your-username/FlutterApiTest.git

# 3. 创建分支
git checkout -b feature/my-feature

# 4. 修改代码
# 5. 提交
git add .
git commit -m "Add my feature"

# 6. 推送
git push origin feature/my-feature

# 7. 创建 Pull Request
```

## 支持

- 📧 Issues: https://github.com/iminsoftware/FlutterApiTest/issues
- 📖 文档: https://github.com/iminsoftware/FlutterApiTest/blob/main/README.md
- 💬 讨论: https://github.com/iminsoftware/FlutterApiTest/discussions

## 许可证

MIT License - 详见 [LICENSE](https://github.com/iminsoftware/FlutterApiTest/blob/main/LICENSE) 文件
