import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/permissions/permission_coordinator.dart';
import 'core/routing/app_router.dart';
import 'core/services/tim_gateway.dart';
import 'core/theme/app_theme.dart';

class TimNexusApp extends StatelessWidget {
  const TimNexusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => TimGateway()),
        ChangeNotifierProvider(create: (_) => PermissionCoordinator()),
      ],
      child: MaterialApp(
        title: 'TIM Nexus',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        initialRoute: AppRouter.initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
