import 'package:flutter/material.dart';

import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/scanner/view/scanner_screen.dart';
import '../../features/session/view/device_session_screen.dart';
import '../../features/wave_editor/view/wave_editor_screen.dart';

class AppRouter {
  static const String initialRoute = OnboardingScreen.routeName;
  static const String scannerRoute = ScannerScreen.routeName;
  static const String sessionRoute = DeviceSessionScreen.routeName;
  static const String waveEditorRoute = WaveEditorScreen.routeName;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case OnboardingScreen.routeName:
        return _build(settings, const OnboardingScreen());
      case ScannerScreen.routeName:
        return _build(settings, const ScannerScreen());
      case DeviceSessionScreen.routeName:
        final args = settings.arguments;
        return _build(
          settings,
          DeviceSessionScreen(
            deviceId: args is DeviceSessionArguments ? args.deviceId : null,
          ),
        );
      case WaveEditorScreen.routeName:
        final deviceId = settings.arguments as String?;
        return _build(settings, WaveEditorScreen(deviceId: deviceId));
      default:
        return _build(
          settings,
          const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }

  static MaterialPageRoute<dynamic> _build(RouteSettings settings, Widget child) => MaterialPageRoute<dynamic>(
    settings: settings,
    builder: (_) => child,
  );
}
