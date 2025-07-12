import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

class CustomCard extends ConsumerWidget {
  const CustomCard({super.key, required this.appId});

  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appListAsync = ref.watch(appListNotifierProvider);

    return appListAsync.when(
      data: (apps) {
        final AppModel? app = apps.cast<AppModel?>().firstWhere(
          (app) => app?.id == appId,
          orElse: () => null,
        );

        if (app == null) {
          return const SizedBox.shrink();
        }

        return _buildCard(context, ref, app);
      },
      loading: () => const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'Error loading app: $appId',
          style: const TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, AppModel app) {
    return InkWell(
      onTap: () => _launchApplication(ref, app),
      splashColor: Colors.white24,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2123).withValues(alpha: 0.5),
            borderRadius: BorderRadius.zero,
            image: _getBackgroundImage(app),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        app.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        app.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (app.lastLaunched != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Last launched: ${_formatDateTime(app.lastLaunched!)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (app.launchCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${app.launchCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DecorationImage? _getBackgroundImage(AppModel app) {
    final String? imagePath = app.customBackgroundImage ?? app.imagePath;

    if (imagePath != null) {
      return DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
        opacity: 0.8,
      );
    }

    return null;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _launchApplication(WidgetRef ref, AppModel app) async {
    if (app.executablePath == null || app.executablePath!.isEmpty) {
      debugPrint('No executable path provided for ${app.title}');
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('No executable path configured for ${app.title}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!app.isEnabled) {
      debugPrint('App ${app.title} is disabled');
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('${app.title} is disabled'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      debugPrint(
        'Launching: ${app.executablePath} with args: ${app.arguments}',
      );

      // AppListNotifier의 launchApp 메서드 사용
      await ref.read(appListNotifierProvider.notifier).launchApp(app.id);

      debugPrint('Successfully launched: ${app.title}');
    } catch (e) {
      debugPrint('Failed to launch ${app.title}: $e');
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(
          content: Text('Failed to launch ${app.title}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
