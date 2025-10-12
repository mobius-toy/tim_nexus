# TIM Nexus

TIM Nexus 是一套生产级的 `tim` SDK 集成样板，目标是让开发、产品、设计团队都能快速体验到真实上线质量的流程。从首次启动的权限引导，到深色科技风的设备控制中心，再到可视化的波形编辑器，它完整演示了 TIM 在 Flutter 项目中的集成方式与最佳实践。

## 核心模块
- **Launch & Permissions**：沉浸式 onboarding，逐步获取蓝牙、定位、通知等权限。
- **Device Discovery**：实时扫描 TIM 兼容设备，展示信号、电量、固件信息。
- **Connection Pipeline**：统一的连接状态机，展示重试与错误处理。
- **Waveform Studio**：拖拽式波形编辑，生成 PWM 序列驱动马达。
- **Telemetry Hub**：电量、RSSI、日志的实时可视化。

详细架构说明见 `docs/architecture.md`。

## 本地运行
1. 安装 Flutter 3.10+。
2. 在 workspace 根目录执行 `flutter pub get`。
3. 使用真实的 `tim` 设备或在调试模式下运行内置的模拟器（后续补充）。

> 提示：此项目默认通过本地路径依赖引用 `tim` SDK，确保 workspace 中已有最新的 `tim` 仓库。下一步可以根据需要接入 CI/CD 与自动化测试。 
