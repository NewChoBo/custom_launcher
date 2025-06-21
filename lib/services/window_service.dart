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

        // Configure window level based on settings
        await _configureWindowLevel(config.windowLevel);

        // Window remains fully opaque, UI elements will handle transparency
      },
    );
  }

  /// Configure window level (z-order) based on settings
  static Future<void> _configureWindowLevel(WindowLevel level) async {
    try {
      debugPrint('Configuring window level: $level');

      switch (level) {
        case WindowLevel.alwaysOnTop:
          debugPrint('Setting window to always on top');
          // First disable bottom if available
          try {
            await windowManager.setAlwaysOnBottom(false);
          } catch (e) {
            debugPrint('setAlwaysOnBottom not available or failed: $e');
          }

          // Add small delay to ensure previous setting is applied
          await Future.delayed(const Duration(milliseconds: 50));

          // Then enable top
          await windowManager.setAlwaysOnTop(true);
          debugPrint('Always on top enabled');
          break;

        case WindowLevel.alwaysBelow:
          debugPrint('Setting window to always below');
          // First disable top
          await windowManager.setAlwaysOnTop(false);

          // Add small delay
          await Future.delayed(const Duration(milliseconds: 50));

          try {
            await windowManager.setAlwaysOnBottom(true);
            debugPrint('Always below enabled');
          } catch (e) {
            debugPrint('setAlwaysOnBottom not supported on this platform: $e');
          }
          break;

        case WindowLevel.normal:
          debugPrint('Setting window to normal level');
          // Disable both
          await windowManager.setAlwaysOnTop(false);
          try {
            await windowManager.setAlwaysOnBottom(false);
          } catch (e) {
            debugPrint('setAlwaysOnBottom not available: $e');
          }
          debugPrint('Normal window level set');
          break;
      }
    } catch (e) {
      debugPrint('Error configuring window level: $e');
    }
  }
}
