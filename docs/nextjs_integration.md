# Tim Nexus 集成 Tim Rhythm Web 使用说明

## 🎯 概述

Tim Nexus 现在使用 Tim Rhythm Web (Next.js) 作为波形编辑器，提供现代化的 Web 体验。

## 🏗️ 技术架构

### 技术栈
- **前端**: Next.js 15 + shadcn/ui + TypeScript
- **样式**: Tailwind CSS
- **蓝牙**: Web Bluetooth API
- **部署**: 静态导出 (Static Export)

### 文件结构
```
tim_nexus/
├── assets/
│   └── rhythm/              # Next.js 静态导出产物
│       ├── index.html       # 主页面
│       ├── _next/           # Next.js 静态资源
│       └── _next/static/    # JS/CSS 文件
└── lib/
    └── core/services/
        └── local_web_server.dart  # 本地 Web 服务器
```

## 🚀 部署流程

### 1. 构建 Tim Rhythm Web
```bash
cd /Users/ddd/GitHub/tim_workspace/tim_rhythm_web
npm run build
```

### 2. 部署到 Tim Nexus
```bash
# 使用部署脚本
./deploy_to_nexus.sh

# 或手动部署
mkdir -p ../tim_nexus/assets/rhythm
cp -r out/* ../tim_nexus/assets/rhythm/
```

### 3. 更新 Flutter 资源
```bash
cd ../tim_nexus
flutter pub get
```

## 🔧 本地 Web 服务器

### 功能特性
- **静态文件服务**: 提供 Next.js 静态导出文件
- **CORS 支持**: 跨域资源共享
- **资源映射**: 自动处理静态资源路径
- **错误处理**: 优雅的错误处理

### 路径映射
```
/ → assets/rhythm/index.html
/_next/* → assets/rhythm/_next/*
/public/* → assets/rhythm/public/*
/api/* → 404 (静态导出不支持 API 路由)
```

## 📱 使用方式

### 在 Tim Nexus 中
1. 打开波形编辑器页面
2. 系统自动加载 Next.js 版本
3. 标题栏显示：`波形工作台`

### 功能特性
- **波形编辑**: 可视化波形编辑界面
- **预设模板**: 心跳、波浪、脉冲等预设
- **播放控制**: 播放、暂停、停止、进度控制
- **蓝牙连接**: Web Bluetooth API 设备连接
- **实时预览**: Canvas 绘制的波形可视化

## 🐛 故障排除

### 常见问题

1. **Next.js 构建产物加载失败**
   - 检查 `assets/rhythm/index.html` 是否存在
   - 确认静态导出构建成功
   - 查看控制台错误信息

2. **资源路径错误**
   - 检查 `pubspec.yaml` 中的 assets 配置
   - 确认路径映射正确
   - 验证文件权限

3. **JavaScript 通道通信失败**
   - 检查 WebView 设置
   - 确认 JavaScript 已启用
   - 查看控制台日志

### 调试步骤

1. **查看服务器日志**
   ```dart
   print('请求路径: $path');
   print('尝试加载资源: $assetPath');
   ```

2. **检查资源加载**
   ```dart
   print('✅ 提供资源: $assetPath (${bytes.length} bytes)');
   print('❌ 加载资源失败: $assetPath - $e');
   ```

## 🔄 开发流程

### 开发模式
1. 在 `tim_rhythm_web` 中开发
2. 使用 `npm run dev` 进行本地开发
3. 测试完成后构建生产版本

### 部署模式
1. 运行 `npm run build` 构建静态导出
2. 使用 `deploy_to_nexus.sh` 部署
3. 在 Tim Nexus 中测试集成效果

## 📊 优势

### Next.js 版本优势
- **更好的 Web 体验**: 原生字体支持，无 FOUT 问题
- **更快的加载速度**: 更轻量的 JavaScript 包
- **更丰富的组件**: shadcn/ui 提供更多选择
- **更好的开发体验**: TypeScript 类型安全
- **更现代的架构**: React Hooks + 现代 Web 技术

### 性能对比
| 特性 | Next.js | Flutter Web (已废弃) |
|------|---------|---------------------|
| 加载速度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 字体渲染 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 交互体验 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 开发效率 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 生态系统 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

## 🎉 总结

Tim Nexus 现在完全使用 Next.js 作为波形编辑器，提供了：
- **现代化**: 使用最新的 Web 技术栈
- **高性能**: 更快的加载和渲染速度
- **易维护**: 清晰的代码结构和类型安全
- **可扩展**: 丰富的组件库和生态系统

---

**Tim Nexus + Tim Rhythm Web** - 让波形创作更简单 🎵
