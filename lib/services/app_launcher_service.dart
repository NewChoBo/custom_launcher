import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/app_paths_config.dart';

/// Service for launching external applications
class AppLauncherService {
  static final AppLauncherService _instance = AppLauncherService._internal();
  factory AppLauncherService() => _instance;
  AppLauncherService._internal();

  AppPathsConfig? _pathsConfig;
  bool _isConfigLoaded = false;

  /// Load application paths configuration
  Future<void> _loadPathsConfig() async {
    if (_isConfigLoaded) return;

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/config/app_paths.json',
      );
      _pathsConfig = AppPathsConfig.fromJson(jsonString);
      _isConfigLoaded = true;
      debugPrint('App paths config loaded successfully');
    } catch (e) {
      debugPrint('Failed to load app paths config: $e');
      // Use empty configuration if loading fails
      _pathsConfig = const AppPathsConfig(
        defaultPaths: <String, String>{},
        searchPaths: <String, List<String>>{},
        customApps: <String, CustomAppInfo>{},
      );
      _isConfigLoaded = true;
    }
  }

  /// Launch an application by name
  Future<bool> launchApp(String appName) async {
    try {
      await _loadPathsConfig();
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

  /// Get executable path for known applications
  String? _getExecutablePath(String appName) {
    if (!Platform.isWindows) {
      debugPrint('Currently only Windows is supported');
      return null;
    }

    // Use JSON configuration
    return _pathsConfig?.getExecutablePath(appName);
  }

  /// Get list of supported applications
  Future<List<AppInfo>> getSupportedApps() async {
    await _loadPathsConfig();

    final List<AppInfo> apps = <AppInfo>[];

    if (_pathsConfig != null) {
      // All apps are now in customApps section
      for (final MapEntry<String, CustomAppInfo> entry
          in _pathsConfig!.customApps.entries) {
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

/// Application information model
class AppInfo {
  final String name;
  final String displayName;
  final String icon;
  final String description;

  const AppInfo({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
  });
}
