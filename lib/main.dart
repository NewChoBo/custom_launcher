import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/infrastructure/window_service.dart';
import 'package:custom_launcher/core/providers/app_providers.dart'; // Import the new providers file

import 'package:window_manager/window_manager.dart';
import 'package:custom_launcher/core/infrastructure/system_tray_service.dart';

import 'package:custom_launcher/features/launcher/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window service with a placeholder for now, will be refactored later
  // await WindowService.initialize(getAppSettings.call()); // This line will be removed or refactored

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
  final SystemTrayService _systemTrayService = SystemTrayService();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _systemTrayService.initialize();
    _initializeWindowSettings(); // New method to handle async initialization
  }

  Future<void> _initializeWindowSettings() async {
    final appSettings = await ref.read(getAppSettingsProvider.future);
    await WindowService.initialize(appSettings);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _systemTrayService.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await _systemTrayService.hideWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettingsAsyncValue = ref.watch(
      getAppSettingsProvider,
    ); // Watch the provider

    return appSettingsAsyncValue.when(
      data: (appSettings) {
        return MaterialApp(
          title: 'Custom Launcher',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: HomePage(
            title: 'Custom Launcher',
            onHideToTray: _systemTrayService.hideWindow,
          ),
        );
      },
      loading: () =>
          const CircularProgressIndicator(), // Show loading indicator
      error: (err, stack) => Text('Error: $err'), // Show error message
    );
  }
}
