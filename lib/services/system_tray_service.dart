import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

/// System Tray management service
/// Handles system tray initialization, menu creation, and window controls
class SystemTrayService {
  final SystemTray _systemTray = SystemTray();

  /// Initialize system tray with icon and menu
  Future<void> initialize() async {
    try {
      await _initSystemTray();
      await _createContextMenu();
      _registerEventHandlers();
    } catch (e) {
      debugPrint('Error initializing system tray: $e');
    }
  }

  /// Initialize system tray with platform-specific icon
  Future<void> _initSystemTray() async {
    String iconPath = _getPlatformIconPath();

    await _systemTray.initSystemTray(
      title: 'Custom Launcher',
      iconPath: iconPath,
      toolTip: 'Custom Launcher - Click to show/hide',
    );
  }

  /// Get platform-appropriate icon file path
  String _getPlatformIconPath() {
    return Platform.isWindows
        ? 'assets/icons/app_icon.ico'
        : Platform.isMacOS
        ? 'assets/icons/app_icon.icns'
        : 'assets/icons/app_icon.png';
  }

  /// Create and set context menu for system tray
  Future<void> _createContextMenu() async {
    final Menu menu = Menu();
    await menu.buildFrom(<MenuItemBase>[
      MenuItemLabel(
        label: 'Show Window',
        onClicked: (MenuItemBase menuItem) => showWindow(),
      ),
      MenuItemLabel(
        label: 'Hide Window',
        onClicked: (MenuItemBase menuItem) => hideWindow(),
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (MenuItemBase menuItem) => exitApplication(),
      ),
    ]);

    await _systemTray.setContextMenu(menu);
  }

  /// Register system tray event handlers
  void _registerEventHandlers() {
    _systemTray.registerSystemTrayEventHandler((String eventName) {
      debugPrint('System tray event: $eventName');
      if (eventName == kSystemTrayEventClick) {
        toggleWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
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
    await _systemTray.destroy();
    exit(0);
  }

  /// Cleanup system tray resources
  Future<void> dispose() async {
    await _systemTray.destroy();
  }
}
