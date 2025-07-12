import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';

import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/dynamic_layout.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title, required this.onHideToTray});

  final String title;
  final Future<void> Function() onHideToTray;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Color? _parseColor(String hexString, double opacity) {
    if (hexString.isEmpty) return null;
    final String hex = hexString.replaceFirst('#', '');
    if (hex.length != 6) return null;
    final int argbValue = int.parse('FF$hex', radix: 16);
    return Color.fromARGB(
      (opacity * 255).round(),
      (argbValue >> 16) & 0xFF, // Red component
      (argbValue >> 8) & 0xFF, // Green component
      argbValue & 0xFF, // Blue component
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsAsyncValue = ref.watch(settingsNotifierProvider);

    return appSettingsAsyncValue.when(
      data: (appSettings) {
        final Color backgroundColor =
            _parseColor(
              appSettings.ui.colors.backgroundColor,
              appSettings.ui.opacity.backgroundOpacity,
            ) ??
            Colors.transparent;

        final Color? appBarColor = _parseColor(
          appSettings.ui.colors.appBarColor,
          appSettings.ui.opacity.appBarOpacity,
        );

        debugPrint(
          'Background: ${appSettings.ui.colors.backgroundColor} -> $backgroundColor',
        );
        debugPrint(
          'AppBar: ${appSettings.ui.colors.appBarColor} -> $appBarColor',
        );

        return Scaffold(
          appBar: appSettings.ui.showAppBar
              ? AppBar(
                  backgroundColor:
                      appBarColor ??
                      Theme.of(context).colorScheme.inversePrimary.withOpacity(
                        appSettings.ui.opacity.appBarOpacity,
                      ),
                  title: Text(widget.title),
                  actions: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.minimize),
                      onPressed: widget.onHideToTray,
                      tooltip: 'Hide to System Tray',
                    ),
                  ],
                )
              : null,
          backgroundColor: backgroundColor,
          body: const DynamicLayout(),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading settings...'),
            ],
          ),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading settings: $err',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(settingsNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
