import 'dart:io';
import 'package:flutter/services.dart';

class LocalWebServer {
  static HttpServer? _server;
  static final int _port = 8081;

  static Future<void> startServer() async {
    if (_server != null) {
      print('服务器已在运行');
      return;
    }

    try {
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, _port);
      print('本地 Web 服务器启动在 http://localhost:$_port');
      print('使用模式: Next.js 静态导出');

      // 在后台处理请求，不阻塞主线程
      _server!.listen((HttpRequest request) {
        _handleRequest(request);
      });
    } catch (e) {
      print('启动服务器失败: $e');
    }
  }

  static void _handleRequest(HttpRequest request) {
    final String path = request.uri.path;
    print('请求路径: $path');

    // 设置 CORS 头
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = 200;
      request.response.close();
      return;
    }

    try {
      _handleNextJSRequest(request, path);
    } catch (e) {
      print('处理请求失败: $e');
      request.response.statusCode = 500;
      request.response.write('Internal Server Error');
      request.response.close();
    }
  }

  static void _handleNextJSRequest(HttpRequest request, String path) {
    print('处理 Next.js 请求: $path');

    if (path == '/' || path == '/index.html') {
      // 加载静态导出的 index.html
      _serveAsset(request, 'assets/rhythm/index.html', 'text/html');
    } else if (path.startsWith('/_next/')) {
      // 处理 Next.js 的静态资源
      final String assetPath = path.substring(1); // 移除开头的斜杠
      final String fullAssetPath = 'assets/rhythm/$assetPath';
      _serveAsset(request, fullAssetPath, _getContentType(path));
    } else if (path.startsWith('/public/')) {
      // 处理 public 目录的资源
      final String assetPath = path.substring(1); // 移除开头的斜杠
      final String fullAssetPath = 'assets/rhythm/$assetPath';
      _serveAsset(request, fullAssetPath, _getContentType(path));
    } else if (path.startsWith('/api/')) {
      // 处理 API 路由（静态导出不支持）
      request.response.statusCode = 404;
      request.response.write('API routes not supported in static export');
      request.response.close();
    } else if (path.startsWith('/')) {
      // 处理其他路径，尝试从静态导出目录加载
      final String fileName = path.substring(1);
      final String assetPath = 'assets/rhythm/$fileName';
      _serveAsset(request, assetPath, _getContentType(path));
    } else {
      request.response.statusCode = 404;
      request.response.write('Not Found');
      request.response.close();
    }
  }

  static void _serveAsset(HttpRequest request, String assetPath, String contentType) async {
    try {
      print('尝试加载资源: $assetPath');

      // 尝试从 Flutter assets 加载
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      request.response.headers.add('Content-Type', contentType);
      request.response.headers.add('Content-Length', bytes.length.toString());
      request.response.add(bytes);
      request.response.close();

      print('✅ 提供资源: $assetPath (${bytes.length} bytes)');
    } catch (e) {
      print('❌ 加载资源失败: $assetPath - $e');
      request.response.statusCode = 404;
      request.response.write('Asset not found: $assetPath');
      request.response.close();
    }
  }

  static String _getContentType(String path) {
    if (path.endsWith('.html')) return 'text/html';
    if (path.endsWith('.js')) return 'application/javascript';
    if (path.endsWith('.css')) return 'text/css';
    if (path.endsWith('.json')) return 'application/json';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    if (path.endsWith('.wasm')) return 'application/wasm';
    if (path.endsWith('.otf')) return 'font/otf';
    if (path.endsWith('.ttf')) return 'font/ttf';
    if (path.endsWith('.woff')) return 'font/woff';
    if (path.endsWith('.woff2')) return 'font/woff2';
    if (path.endsWith('.bin')) return 'application/octet-stream';
    if (path.endsWith('.map')) return 'application/json'; // Source maps
    return 'application/octet-stream';
  }

  static Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print('服务器已停止');
    }
  }

  static String get baseUrl => 'http://localhost:$_port';
}
