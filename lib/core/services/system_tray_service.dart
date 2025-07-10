import 'package:flutter/foundation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

class SystemTrayService with TrayListener {
  bool _isInitialized = false;

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

  String _getPlatformIconPath() {
    if (Platform.isWindows) {
      return 'assets/icons/app_icon.ico';
    } else if (Platform.isMacOS) {
      return 'assets/icons/app_icon.icns';
    } else {
      return 'assets/icons/app_icon.png';
    }
  }

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
    if (_isInitialized) {
      await trayManager.destroy();
    }
    exit(0);
  }

  Future<void> dispose() async {
    if (_isInitialized) {
      await trayManager.destroy();
    }
  }
}
