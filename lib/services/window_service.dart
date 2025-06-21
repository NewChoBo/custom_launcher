import 'package:window_manager/window_manager.dart';
import 'package:flutter/material.dart';

/// Window management service for desktop applications
/// Handles window initialization, configuration, and lifecycle
class WindowService {
  /// Initialize window manager with desktop-specific settings
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);
      },
    );
  }
}
