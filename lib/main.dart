import 'package:flutter/material.dart';
import 'package:custom_launcher/services/window_service.dart';
import 'package:custom_launcher/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window for desktop
  await WindowService.initialize();

  runApp(const MyApp());
}
