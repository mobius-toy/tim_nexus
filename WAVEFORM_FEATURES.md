# Tim Nexus - 波形数据扫描和播放功能

## 新增功能

### 1. 二维码扫描功能
- 在设备会话页面添加了二维码扫描按钮
- 点击按钮打开全屏扫描页面
- 进入页面后自动开启扫描功能
- 仅识别前缀为 "TRD:" 的二维码
- 支持解析压缩的二进制波形数据格式
- 扫描成功后自动退出扫描页面
- 自动检查和请求相机权限
- 权限被拒绝时显示友好的错误提示和设置引导

### 2. 波形数据导入
- 支持从二维码导入波形数据
- 移除了预设波形按钮，专注于二维码扫描功能

### 3. 波形预览功能
- 实时波形可视化显示
- 支持播放进度显示
- 网格背景和时间轴
- 播放进度指示器

### 4. 波形播放控制
- 播放/暂停/停止控制
- 进度条拖拽定位
- 实时强度计算和马达控制
- 播放状态同步显示

## 技术实现

### 数据模型
- `WaveSegment`: 波形段模型，包含强度、时长、形状等属性
- `WaveformData`: 完整波形数据，包含多个波形段和总时长
- `WaveShape`: 波形形状枚举（线性、缓入、缓出、保持、正弦）
- `fromCompressedData`: 支持解析压缩的二进制波形数据格式

### 核心组件
- `QRScannerFullScreenModal`: 全屏二维码扫描页面组件
- `QRScannerModal`: 二维码扫描模态框组件（已弃用）
- `QRScannerWidget`: 二维码扫描器组件（已弃用）
- `WaveformPreviewWidget`: 波形预览组件
- `DeviceSessionController`: 设备会话控制器，集成波形播放功能

### 波形变换算法
- 支持多种波形形状的数学变换
- 实时强度计算和插值
- 播放进度同步

## 使用方法

1. **连接设备**：在设备会话页面连接目标设备
2. **导入波形**：
   - 点击"扫描二维码导入波形数据"按钮打开全屏扫描页面
   - 页面会自动开启扫描功能
   - 扫描包含 "TRD:" 前缀的二维码
   - 扫描成功后页面自动退出，波形数据自动导入到预览区域
3. **预览波形**：导入成功后，波形预览区域自动显示波形形状
4. **播放控制**：使用播放控制按钮控制波形播放
5. **实时反馈**：播放时马达会实时响应波形强度

## 文件结构

```
lib/
├── core/
│   ├── models/
│   │   └── waveform.dart              # 波形数据模型
│   └── utils/
│       └── waveform_data_generator.dart # 示例数据生成器
├── features/
│   ├── qr_scanner/
│   │   ├── controller/
│   │   │   └── qr_scanner_controller.dart
│   │   └── view/
│   │       ├── qr_scanner_fullscreen_modal.dart # 新的全屏扫描页面
│   │       ├── qr_scanner_modal.dart            # 已弃用
│   │       └── qr_scanner_widget.dart           # 已弃用
│   ├── waveform_preview/
│   │   ├── controller/
│   │   │   └── waveform_preview_controller.dart
│   │   └── view/
│   │       └── waveform_preview_widget.dart
│   └── session/
│       ├── controller/
│       │   └── device_session_controller.dart # 集成波形功能
│       └── view/
│           └── device_session_screen.dart      # 更新UI
```

## 依赖包

- `mobile_scanner: ^5.0.0` - 二维码扫描功能（替代了有兼容性问题的 qr_code_scanner）
- `provider: ^6.1.2` - 状态管理
- `tim` - 设备通信库

## 注意事项

- 二维码扫描功能需要相机权限
- 首次使用时会自动请求相机权限
- 权限被拒绝时可以通过设置页面重新授权
- 仅识别前缀为 "TRD:" 的二维码
- 支持解析 tim_rhythm 导出的压缩波形数据格式
- 波形播放需要设备连接状态
- 播放过程中会实时控制马达强度
- 支持多种波形形状的数学变换
- 使用 `mobile_scanner` 替代了 `qr_code_scanner` 以解决 Android 构建兼容性问题
