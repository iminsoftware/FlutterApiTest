# 测试指南

## 验证步骤

### 1. 环境检查

```bash
# 检查 Flutter 版本
flutter --version

# 检查 Android Studio / SDK
flutter doctor -v
```

### 2. 安装依赖

```bash
cd FlutterApiTest/example
flutter pub get
```

### 3. 运行项目

```bash
# 连接 iMin 设备或模拟器
flutter devices

# 运行应用
flutter run
```

### 4. 测试双屏显示功能

**前提条件：**
- iMin 设备需要连接副屏
- 需要授予悬浮窗权限（Android 6.0+）

**测试步骤：**
1. 打开应用，点击 "Dual Screen Display"
2. 查看状态：应该显示 "Secondary display detected"
3. 点击 "Enable Display" 按钮
4. 副屏应该显示内容
5. 在文本框输入文字，点击 "Show Text"
6. 副屏应该显示输入的文字
7. 点击 "Clear Display" 清空副屏
8. 点击 "Disable Display" 关闭副屏

### 5. 常见问题

**问题 1: 找不到副屏**
- 检查副屏是否正确连接
- 检查设备型号是否支持副屏

**问题 2: 权限被拒绝**
- 进入设置 → 应用 → iMin Hardware Demo → 权限
- 开启 "显示在其他应用上层" 权限

**问题 3: Gradle 构建失败**
- 检查 Android Studio 版本（建议 Hedgehog 2023.1.1+）
- 检查 Java 版本（需要 Java 17）
- 清理缓存：`flutter clean && cd android && ./gradlew clean`

**问题 4: JAR 包找不到**
- 检查 `android/libs/` 目录是否有 JAR 包
- 检查 `build.gradle` 中的依赖配置

### 6. 调试日志

```bash
# 查看 Android 日志
flutter logs

# 或使用 adb
adb logcat | grep -i "DisplayHandler\|IminHardware"
```

### 7. 预期结果

✅ 应用正常启动
✅ 主页面显示10个功能按钮
✅ 点击 "Dual Screen Display" 进入测试页面
✅ 能检测到副屏
✅ 能开启/关闭副屏
✅ 能在副屏显示文字
✅ 能清空副屏内容

### 8. 下一步

如果双屏显示功能测试通过：
1. ✅ 标记双屏功能为完成
2. 🚀 开始实现钱箱控制功能
3. 🚀 开始实现灯光控制功能
4. 🚀 逐步实现其他功能

如果测试失败：
1. 查看错误日志
2. 检查配置文件
3. 修复问题后重新测试
