# TIM Nexus

TIM Nexus 是一套生产级的 `tim` SDK 集成样板，目标是让开发、产品、设计团队都能快速体验到真实上线质量的流程。从首次启动的权限引导，到深色科技风的设备控制中心，再到可视化的波形编辑器和二维码扫描功能，它完整演示了 TIM 在 Flutter 项目中的集成方式与最佳实践。

## 🚀 核心功能

### 📱 设备管理
- **设备发现**：实时扫描 TIM 兼容设备，展示信号强度、电量、固件信息
- **连接管理**：统一的连接状态机，支持重试与错误处理
- **实时监控**：电量、RSSI、日志的实时可视化

### 🎵 波形功能
- **二维码扫描**：扫描 tim_rhythm 导出的压缩波形数据
- **波形预览**：实时可视化波形形状和播放进度
- **播放控制**：支持播放、暂停、停止和进度控制
- **多种波形**：支持线性、缓入、缓出、保持、正弦等波形形状

### 🎨 用户体验
- **权限引导**：沉浸式 onboarding，逐步获取蓝牙、相机等权限
- **深色主题**：科技风的界面设计
- **实时反馈**：马达强度实时响应波形播放

## 📋 系统要求

- **Flutter**: 3.10+ 
- **Dart**: 3.0+
- **Android**: API 21+ (Android 5.0+)
- **iOS**: 12.0+
- **macOS**: 10.14+

## 🛠️ 安装与运行

### 1. 环境准备
```bash
# 安装 Flutter 3.10+
flutter --version

# 确保在 workspace 根目录
cd /path/to/tim_workspace
```

### 2. 依赖安装
```bash
# 安装项目依赖
cd tim_nexus
flutter pub get
```

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
   - 扫描包含 `TRD:` 前缀的二维码
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
- `QRScannerFullScreenModal` - 全屏扫描页面
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

## 🐛 故障排除

### 常见问题

#### 1. 蓝牙权限问题
**问题**：无法扫描到设备
**解决**：
- 检查蓝牙权限是否已授予
- 确保设备蓝牙已开启
- 重启应用重新请求权限

#### 2. 相机权限问题
**问题**：无法打开扫描页面
**解决**：
- 检查相机权限是否已授予
- 在系统设置中手动开启相机权限
- 重启应用重新请求权限

#### 3. 设备连接失败
**问题**：设备连接超时
**解决**：
- 确保设备在有效范围内
- 检查设备电量是否充足
- 尝试重启设备或应用

#### 4. 波形数据解析失败
**问题**：扫描后无法解析数据
**解决**：
- 确保二维码包含 `TRD:` 前缀
- 检查二维码是否完整清晰
- 验证数据格式是否正确

### 调试模式
```bash
# 启用详细日志
flutter run --verbose

# 查看设备日志
flutter logs
```

## 📄 许可证

本项目采用 MIT 许可证，详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进项目。

## 📞 支持

如有问题，请通过以下方式联系：
- 提交 GitHub Issue
- 发送邮件至项目维护者

---

> **提示**：此项目默认通过本地路径依赖引用 `tim` SDK，确保 workspace 中已有最新的 `tim` 仓库。下一步可以根据需要接入 CI/CD 与自动化测试。 
