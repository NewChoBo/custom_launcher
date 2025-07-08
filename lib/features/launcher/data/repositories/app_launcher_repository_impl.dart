import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_assets_config.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';

import 'package:custom_launcher/features/launcher/domain/repositories/app_launcher_repository.dart';

class AppLauncherRepositoryImpl implements AppLauncherRepository {
  static final AppLauncherRepositoryImpl _instance = AppLauncherRepositoryImpl._internal();
  factory AppLauncherRepositoryImpl() => _instance;
  AppLauncherRepositoryImpl._internal();

  AppAssetsConfig? _assetsConfig;
  bool _isConfigLoaded = false;

  Future<void> _loadAssetsConfig() async {
    if (_isConfigLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/config/app_assets.json',
      );
      _assetsConfig = AppAssetsConfig.fromJson(jsonString);
      _isConfigLoaded = true;
      debugPrint('App assets config loaded successfully');
    } catch (e) {
      debugPrint('Failed to load app assets config: $e');
      _assetsConfig = const AppAssetsConfig(apps: <String, CustomAppInfo>{});
      _isConfigLoaded = true;
    }
  }

  Future<bool> launchApp(String appName) async {
    try {
      await _loadAssetsConfig();
      debugPrint('Attempting to launch: $appName');

      final String? executablePath = _getExecutablePath(appName);
      if (executablePath == null) {
        debugPrint('Unknown application: $appName');
        return false;
      }

      final ProcessResult result = await Process.run(
        executablePath,
        <String>[],
        runInShell: true,
      );

      if (result.exitCode == 0) {
        debugPrint('Successfully launched: $appName');
        return true;
      } else {
        debugPrint('Failed to launch $appName: ${result.stderr}');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching $appName: $e');
      return false;
    }
  }

  String? _getExecutablePath(String appName) {
    if (!Platform.isWindows) {
      debugPrint('Currently only Windows is supported');
      return null;
    }

    return _assetsConfig?.getExecutablePath(appName);
  }

  Future<List<AppInfo>> getSupportedApps() async {
    await _loadAssetsConfig();

    final List<AppInfo> apps = <AppInfo>[];

    if (_assetsConfig != null) {
      for (final MapEntry<String, CustomAppInfo> entry
          in _assetsConfig!.apps.entries) {
        apps.add(
          AppInfo(
            name: entry.key,
            displayName: entry.value.displayName,
            icon: entry.value.icon,
            description: entry.value.description,
          ),
        );
      }
    }

    return apps;
  }
}


