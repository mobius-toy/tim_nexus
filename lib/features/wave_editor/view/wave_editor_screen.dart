import 'package:flutter/material.dart';

import '../../../shared/widgets/ambient_background.dart';

class WaveEditorScreen extends StatelessWidget {
  const WaveEditorScreen({super.key});

  static const String routeName = '/wave';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('波形工作台'),
      ),
      body: AmbientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.waves_outlined, color: Colors.white.withValues(alpha: 0.6), size: 80),
                const SizedBox(height: 24),
                Text(
                  '波形编辑器即将上线',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  '下一阶段会提供拖拽节点、预设、实时推送马达的能力。',
                  style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
