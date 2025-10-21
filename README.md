# TIM Nexus

## 🚀 核心功能

### 📱 设备管理
- **设备发现**：实时扫描 TIM 兼容设备，展示信号强度、电量、固件信息
- **连接管理**：统一的连接状态机，支持重试与错误处理
- **实时监控**：电量、RSSI、日志的实时可视化

### 🎵 波形功能
- **二维码扫描**：扫描 https://mobius-toy.github.io/tim_rhythm 导出的波形数据
- **波形预览**：实时可视化波形形状和播放进度
- **播放控制**：支持播放、暂停、停止和进度控制
- **多种波形**：支持线性、缓入、缓出、正弦等波形形状

## 📋 系统要求
- **Flutter**: 3.35.0+
- **Dart**: 3.9.2+
- **Android**: API 21+ (Android 5.0+)
- **iOS**: 12.0+
- **macOS**: 10.14+

### 3. 权限配置

#### Android 权限
应用会自动请求以下权限：
- `BLUETOOTH_SCAN` - 蓝牙设备扫描
- `BLUETOOTH_CONNECT` - 蓝牙设备连接
- `CAMERA` - 二维码扫描
- `INTERNET` - 网络访问

#### iOS 权限
在 `ios/Runner/Info.plist` 中已配置：
- `NSBluetoothAlwaysUsageDescription` - 蓝牙权限
- `NSCameraUsageDescription` - 相机权限

### 4. 运行应用
```bash
# 调试模式运行
flutter run

# 构建发布版本
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 📖 使用指南

### 🔍 设备连接
1. **启动应用**：首次启动会引导获取必要权限
2. **扫描设备**：在设备列表页面扫描附近的 TIM 设备
3. **选择设备**：点击目标设备进行连接
4. **连接成功**：进入设备会话页面

### 📱 波形扫描与播放
1. **扫描二维码**：
   - 在设备会话页面点击"扫描二维码导入波形数据"
   - 扫描 https://mobius-toy.github.io/tim_rhythm 生成的二维码
   - 扫描成功后自动退出并导入数据

2. **波形预览**：
   - 导入成功后波形预览区域自动显示波形形状
   - 显示波形段数量和总时长信息

3. **播放控制**：
   - **播放**：开始波形播放，马达实时响应
   - **暂停**：暂停当前播放
   - **停止**：停止播放并重置进度

### 🎵 波形数据格式

#### 支持的二维码格式
```
TRD:[base64编码的压缩二进制数据]
```

#### 压缩数据格式
- **总时长**：4字节，毫秒
- **波形段**：每个段包含
  - 形状代码：1字节 (0=linear, 1=easeIn, 2=easeOut, 3=hold)
  - 起始强度：1字节 (0-100，转换为0-1)
  - 结束强度：1字节 (0-100，转换为0-1)
  - 时长：4字节，毫秒

#### 波形形状类型
- **linear**：线性变化
- **easeIn**：缓入效果
- **easeOut**：缓出效果
- **hold**：保持强度
- **sine**：正弦波变化

## 🏗️ 项目架构

### 📁 目录结构
```
lib/
├── app.dart                    # 应用入口
├── core/
│   ├── models/
│   │   └── waveform.dart       # 波形数据模型
│   ├── services/
│   │   └── tim_gateway.dart    # TIM 设备网关
│   └── theme/
│       └── app_theme.dart      # 应用主题
├── features/
│   ├── device_discovery/       # 设备发现
│   ├── session/               # 设备会话
│   ├── qr_scanner/            # 二维码扫描
│   ├── waveform_preview/      # 波形预览
│   └── wave_editor/           # 波形编辑器
└── shared/
    └── widgets/               # 共享组件
```

### 🔧 核心组件

#### 设备管理
- `DeviceDiscoveryController` - 设备扫描控制器
- `DeviceSessionController` - 设备会话控制器
- `TimGateway` - TIM 设备通信网关

#### 波形功能
- `QRScannerController` - 二维码扫描控制器
- `WaveformPreviewController` - 波形预览控制器
- `WaveformData` - 波形数据模型
- `WaveSegment` - 波形段模型

#### UI 组件
- `QRScannerFullScreenModal` - 扫描二维码页面
- `WaveformPreviewWidget` - 波形预览组件
- `DeviceSessionScreen` - 设备会话页面

## 🔧 开发指南

### 添加新的波形形状
1. 在 `WaveShape` 枚举中添加新类型
2. 在 `transformWaveShape` 函数中实现变换逻辑
3. 更新压缩数据解析逻辑

### 自定义扫描功能
1. 修改 `QRScannerController` 的扫描逻辑
2. 更新数据解析格式
3. 调整 UI 显示效果

### 扩展设备功能
1. 在 `TimGateway` 中添加新的设备命令
2. 更新 `DeviceSessionController` 的状态管理
3. 添加相应的 UI 控制组件

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。
