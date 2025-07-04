import 'package:flutter/material.dart';
import 'package:custom_launcher/services/window_service.dart';
import 'package:custom_launcher/services/launcher_config_service.dart';
import 'package:custom_launcher/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize launcher configuration service
  final LauncherConfigService launcherConfigService = LauncherConfigService();
  await launcherConfigService.initialize();

  // Initialize window with layout configuration
  await WindowService.initializeWithConfig(launcherConfigService);

  runApp(MyApp(launcherConfigService: launcherConfigService));
}
