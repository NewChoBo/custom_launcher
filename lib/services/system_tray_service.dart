import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

/// System Tray management service
/// Handles system tray initialization, menu creation, and window controls

/// System Tray management service (tray_manager 기반)
/// Handles system tray initialization, menu creation, and window controls
class SystemTrayService with TrayListener {
  bool _isInitialized = false;

  /// Initialize system tray with icon and menu
  Future<void> initialize() async {
    try {
      await trayManager.setIcon(_getPlatformIconPath());
      await _setContextMenu();
      trayManager.addListener(this);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing system tray: $e');
    }
  }

  /// Get platform-appropriate icon file path

  String _getPlatformIconPath() {
    if (Platform.isWindows) {
      return 'assets/icons/app_icon.ico';
    } else if (Platform.isMacOS) {
      return 'assets/icons/app_icon.icns';
    } else {
      return 'assets/icons/app_icon.png';
    }
  }

  /// Create and set context menu for system tray (tray_manager)
  Future<void> _setContextMenu() async {
    final Menu menu = Menu(
      items: <MenuItem>[
        MenuItem(key: 'show', label: 'Show Window'),
        MenuItem(key: 'hide', label: 'Hide Window'),
        MenuItem.separator(),
        MenuItem(key: 'exit', label: 'Exit'),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  /// Tray event handler (tray_manager)
  @override
  void onTrayIconMouseDown() {
    toggleWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        showWindow();
        break;
      case 'hide':
        hideWindow();
        break;
      case 'exit':
        exitApplication();
        break;
    }
  }

  /// Show application window
  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// Hide application window
  Future<void> hideWindow() async {
    await windowManager.hide();
  }

  /// Toggle window visibility
  Future<void> toggleWindow() async {
    final bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await hideWindow();
    } else {
      await showWindow();
    }
  }

  /// Exit application and cleanup system tray
  Future<void> exitApplication() async {
    if (_isInitialized) {
      await trayManager.destroy();
    }
    exit(0);
  }

  /// Cleanup system tray resources
  Future<void> dispose() async {
    if (_isInitialized) {
      await trayManager.destroy();
    }
  }
}
