import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Window management service for desktop applications
/// Handles window initialization, configuration, and lifecycle
class WindowService {
  /// Initialize window manager with settings-based configuration
  static Future<void> initialize([AppSettings? settings]) async {
    final config = settings ?? const AppSettings();

    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(config.windowWidth, config.windowHeight),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: config.skipTaskbar,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);
        // Window remains fully opaque, UI elements will handle transparency
      },
    );
  }
}
