import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class SystemTrayService {
  final SystemTray _systemTray = SystemTray();
  Future<void> initialize() async {
    try {
      await _initSystemTray();
      await _createContextMenu();
      _registerEventHandlers();
    } catch (e) {
      debugPrint('Error initializing system tray: $e');
    }
  }

  Future<void> _initSystemTray() async {
    String iconPath = _getPlatformIconPath();

    await _systemTray.initSystemTray(
      title: 'Custom Launcher',
      iconPath: iconPath,
      toolTip: 'Custom Launcher - Click to show/hide',
    );
  }

  String _getPlatformIconPath() {
    return Platform.isWindows
        ? 'assets/icons/app_icon.ico'
        : Platform.isMacOS
        ? 'assets/icons/app_icon.icns'
        : 'assets/icons/app_icon.png';
  }

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

  Future<void> showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> hideWindow() async {
    await windowManager.hide();
  }

  Future<void> toggleWindow() async {
    final bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await hideWindow();
    } else {
      await showWindow();
    }
  }

  Future<void> exitApplication() async {
    await _systemTray.destroy();
    exit(0);
  }

  Future<void> dispose() async {
    await _systemTray.destroy();
  }
}
