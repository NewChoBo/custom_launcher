import 'package:flutter/material.dart';
import 'package:custom_launcher/services/window_service.dart';
import 'package:custom_launcher/services/settings_service.dart';
import 'package:custom_launcher/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();

  // Initialize window with settings
  await WindowService.initialize(settingsService.settings);

  runApp(MyApp(settings: settingsService.settings));
}
