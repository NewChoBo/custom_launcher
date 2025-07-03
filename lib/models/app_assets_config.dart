import 'dart:convert';
import 'dart:io';

/// Configuration model for application assets
class AppAssetsConfig {
  final Map<String, CustomAppInfo> apps;

  const AppAssetsConfig({required this.apps});

  factory AppAssetsConfig.fromMap(Map<String, dynamic> map) {
    return AppAssetsConfig(
      apps: (map['apps'] as Map<String, dynamic>? ?? <String, dynamic>{}).map(
        (String key, value) =>
            MapEntry(key, CustomAppInfo.fromMap(value as Map<String, dynamic>)),
      ),
    );
  }

  factory AppAssetsConfig.fromJson(String source) {
    return AppAssetsConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  /// Get executable path for an app
  String? getExecutablePath(String appName) {
    final String lowerName = appName.toLowerCase();

    // Check apps
    if (apps.containsKey(lowerName)) {
      return _findExecutableInPaths(apps[lowerName]!.paths);
    }

    return null;
  }

  /// Find first existing executable in paths
  String? _findExecutableInPaths(List<String> paths) {
    for (String path in paths) {
      final String expandedPath = _expandEnvironmentVariables(path);

      if (_fileExists(expandedPath)) {
        return expandedPath;
      }
    }
    return null;
  }

  /// Expand environment variables in path
  String _expandEnvironmentVariables(String path) {
    String expandedPath = path;

    // Replace %USERNAME%
    final String? username = _getEnvironmentVariable('USERNAME');
    if (username != null) {
      expandedPath = expandedPath.replaceAll('%USERNAME%', username);
    }

    // Replace %USERPROFILE%
    final String? userProfile = _getEnvironmentVariable('USERPROFILE');
    if (userProfile != null) {
      expandedPath = expandedPath.replaceAll('%USERPROFILE%', userProfile);
    }

    return expandedPath;
  }

  /// Check if file exists
  bool _fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Get environment variable
  String? _getEnvironmentVariable(String name) {
    try {
      return Platform.environment[name];
    } catch (e) {
      return null;
    }
  }
}

/// Custom application information
class CustomAppInfo {
  final String name;
  final String displayName;
  final String icon;
  final String description;
  final List<String> paths;

  const CustomAppInfo({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.description,
    required this.paths,
  });

  factory CustomAppInfo.fromMap(Map<String, dynamic> map) {
    return CustomAppInfo(
      name: map['name'] as String,
      displayName: map['displayName'] as String,
      icon: map['icon'] as String,
      description: map['description'] as String,
      paths: List<String>.from(map['paths'] ?? <dynamic>[]),
    );
  }
}
