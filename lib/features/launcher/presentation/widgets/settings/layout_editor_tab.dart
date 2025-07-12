import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/visual_layout_editor.dart';

/// Layout Editor tab widget
/// 비주얼 레이아웃 에디터를 관리하는 탭 위젯
class LayoutEditorTab extends ConsumerWidget {
  const LayoutEditorTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layoutConfigAsync = ref.watch(layoutNotifierProvider);

    return layoutConfigAsync.when(
      data: (layoutConfig) => VisualLayoutEditor(
        initialConfig: layoutConfig,
        onLayoutChanged: (config) {
          ref.read(layoutNotifierProvider.notifier).saveLayoutConfig(config);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layout changes saved!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading layout configuration...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Error loading layout: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(layoutNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
