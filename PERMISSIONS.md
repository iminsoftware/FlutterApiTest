# 权限配置说明

## Android 权限

### 1. 双屏显示权限

```xml
<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**用途**:
- `SYSTEM_ALERT_WINDOW` - 允许应用在其他应用上层显示窗口（副屏显示）
- `INTERNET` - 允许网络访问（加载网络图片和视频）

**申请方式**:
- Android 6.0+ 需要动态申请悬浮窗权限
- 系统会自动引导用户到设置页面授权

### 2. USB 灯光控制权限

```xml
<uses-feature android:name="android.hardware.usb.host" android:required="false"/>
```

**用途**:
- 允许应用作为 USB 主机访问 USB 设备
- 用于连接和控制 USB 灯光设备

**申请方式**:
- 静态声明：在 AndroidManifest.xml 中声明（已配置）
- 动态请求：在代码中请求 USB 权限（LightHandler.kt 已实现）
- 用户授权：系统会弹出对话框，用户点击"确定"即可

**权限流程**:
```
1. 应用调用 IminLight.connect()
   ↓
2. LightHandler 检测到 USB 设备
   ↓
3. 检查是否已有权限
   ↓
4. 如果没有权限，请求权限（弹出系统对话框）
   ↓
5. 用户点击"确定"授权
   ↓
6. BroadcastReceiver 接收权限授予事件
   ↓
7. 自动连接 USB 设备
```

**注意事项**:
- `android:required="false"` 表示没有 USB 功能的设备也能安装应用
- USB 权限是临时的，拔出设备后权限会失效
- 重新插入设备需要再次授权（除非勾选"默认使用此应用"）

### 3. 其他硬件权限（待添加）

根据后续功能开发，可能需要添加：

```xml
<!-- NFC 权限 -->
<uses-permission android:name="android.permission.NFC"/>
<uses-feature android:name="android.hardware.nfc" android:required="false"/>

<!-- 摄像头权限（摄像头扫码） -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-feature android:name="android.hardware.camera" android:required="false"/>

<!-- 蓝牙权限（蓝牙设备） -->
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
```

## Flutter 权限申请最佳实践

### 1. 静态权限（AndroidManifest.xml）

在 `android/src/main/AndroidManifest.xml` 中声明所有需要的权限。

### 2. 动态权限（Kotlin/Java 代码）

对于危险权限（如相机、位置等），需要在运行时请求：

```kotlin
// 示例：请求相机权限
if (ContextCompat.checkSelfPermission(activity, Manifest.permission.CAMERA)
    != PackageManager.PERMISSION_GRANTED) {
    ActivityCompat.requestPermissions(activity,
        arrayOf(Manifest.permission.CAMERA),
        REQUEST_CAMERA_PERMISSION)
}
```

### 3. USB 权限（特殊处理）

USB 权限通过 UsbManager 请求：

```kotlin
val usbManager = context.getSystemService(Context.USB_SERVICE) as UsbManager
val pendingIntent = PendingIntent.getBroadcast(context, 0, Intent(ACTION_USB_PERMISSION), flags)
usbManager.requestPermission(device, pendingIntent)
```

### 4. Flutter 插件权限处理

对于 Flutter 插件：
- **Plugin 的 AndroidManifest.xml**：声明插件需要的权限
- **App 的 AndroidManifest.xml**：会自动合并插件的权限声明
- **Native 代码**：在 Handler 中处理权限请求逻辑
- **Flutter 代码**：调用 API 时自动触发权限请求

## 常见问题

### Q: 为什么 USB 权限每次都要授权？

A: USB 权限是临时的，设备断开后权限失效。可以在授权对话框中勾选"默认使用此应用"来避免重复授权。

### Q: 如何测试权限申请流程？

A: 
1. 卸载应用重新安装
2. 清除应用数据
3. 在设置中撤销已授予的权限

### Q: 权限被拒绝后如何处理？

A: 应该引导用户到设置页面手动开启权限：

```kotlin
val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
intent.data = Uri.parse("package:${context.packageName}")
context.startActivity(intent)
```

## 参考资料

- [Android 权限文档](https://developer.android.com/guide/topics/permissions/overview)
- [USB 主机模式](https://developer.android.com/guide/topics/connectivity/usb/host)
- [Flutter 权限处理](https://docs.flutter.dev/platform-integration/android/platform-views)
