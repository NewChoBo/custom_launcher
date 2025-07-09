import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/infrastructure/window_service.dart';
import 'package:custom_launcher/features/launcher/data/repositories/settings_repository_impl.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/get_app_settings.dart';

import 'package:window_manager/window_manager.dart';
import 'package:custom_launcher/core/infrastructure/system_tray_service.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/presentation/pages/home_page.dart';
import 'package:custom_launcher/features/launcher/presentation/pages/demo_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SettingsRepositoryImpl settingsRepository = SettingsRepositoryImpl();
  final GetAppSettings getAppSettings = GetAppSettings(settingsRepository);
  await settingsRepository.initialize();
  await WindowService.initialize(getAppSettings.call());

  runApp(
    ProviderScope(
      child: MyApp(settings: getAppSettings.call()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.settings});

  final AppSettings settings;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final SystemTrayService _systemTrayService = SystemTrayService();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _systemTrayService.initialize();
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
    return MaterialApp(
      title: 'Custom Launcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: widget.settings.mode == 'demo'
          ? const DemoPage()
          : HomePage(
              title: 'Custom Launcher',
              onHideToTray: _systemTrayService.hideWindow,
              settings: widget.settings,
            ),
    );
  }
}
