import 'package:flutter/material.dart';
import 'package:custom_launcher/services/window_service.dart';
import 'package:custom_launcher/services/settings_service.dart';

import 'package:window_manager/window_manager.dart';
import 'package:custom_launcher/services/system_tray_service.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/pages/home_page.dart';
import 'package:custom_launcher/pages/demo_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SettingsService settingsService = SettingsService();
  await settingsService.initialize();
  await WindowService.initialize(settingsService.settings);

  runApp(MyApp(settings: settingsService.settings));
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
