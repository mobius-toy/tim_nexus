import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.overlay,
  });

  final Widget child;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),
          ),
          Positioned.fill(child: child),
          if (overlay != null) Positioned.fill(child: overlay!),
        ],
      ),
    );
  }
}
