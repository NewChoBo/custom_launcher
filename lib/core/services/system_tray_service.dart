import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:custom_launcher/main.dart';
import 'package:custom_launcher/features/launcher/presentation/pages/settings_page.dart';

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
        MenuItem(key: 'settings', label: 'Settings'),
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
      case 'settings':
        openSettings();
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

  Future<void> openSettings() async {
    // First ensure the window is visible
    await showWindow();

    // Wait a bit to ensure the window is fully shown
    await Future.delayed(const Duration(milliseconds: 100));

    // Navigate to settings page using the global navigator key
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
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
