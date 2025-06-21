import 'dart:io';
import 'dart:developer' as developer;
import 'package:custom_launcher/models/launcher_item.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service for launching applications and URLs
class LauncherService {
  /// Launch a launcher item (executable or URL)
  static Future<bool> launchItem(LauncherItem item) async {
    try {
      if (item.isExecutable) {
        return await _launchExecutable(item);
      } else if (item.isUrl) {
        return await _launchUrl(item);
      }
      return false;
    } catch (e) {
      developer.log('Error launching item ${item.name}: $e');
      return false;
    }
  }

  /// Launch an executable file
  static Future<bool> _launchExecutable(LauncherItem item) async {
    try {
      // Expand environment variables like %USERNAME%
      final expandedPath = _expandEnvironmentVariables(item.path);
      if (Platform.isWindows) {
        // Use Windows-specific launch method
        await Process.start('cmd', [
          '/c',
          'start',
          '""',
          expandedPath,
        ], runInShell: true);
        return true;
      } else {
        // For other platforms, use direct process start
        await Process.start(expandedPath, []);
        return true;
      }
    } catch (e) {
      developer.log('Error launching executable ${item.path}: $e');
      return false;
    }
  }

  /// Launch a URL
  static Future<bool> _launchUrl(LauncherItem item) async {
    try {
      final uri = Uri.parse(item.path);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      developer.log('Error launching URL ${item.path}: $e');
      return false;
    }
  }

  /// Expand Windows environment variables in path
  static String _expandEnvironmentVariables(String path) {
    String expandedPath = path;

    // Common Windows environment variables
    final envVars = {
      '%USERNAME%': Platform.environment['USERNAME'] ?? '',
      '%USERPROFILE%': Platform.environment['USERPROFILE'] ?? '',
      '%APPDATA%': Platform.environment['APPDATA'] ?? '',
      '%LOCALAPPDATA%': Platform.environment['LOCALAPPDATA'] ?? '',
      '%PROGRAMFILES%': Platform.environment['PROGRAMFILES'] ?? '',
      '%PROGRAMFILES(X86)%': Platform.environment['PROGRAMFILES(X86)'] ?? '',
      '%SYSTEMROOT%': Platform.environment['SYSTEMROOT'] ?? '',
      '%WINDIR%': Platform.environment['WINDIR'] ?? '',
    };

    envVars.forEach((variable, value) {
      expandedPath = expandedPath.replaceAll(variable, value);
    });

    return expandedPath;
  }

  /// Validate if an executable path exists
  static bool validateExecutablePath(String path) {
    try {
      final expandedPath = _expandEnvironmentVariables(path);
      final file = File(expandedPath);
      return file.existsSync();
    } catch (e) {
      return false;
    }
  }

  /// Validate if a URL is valid
  static bool validateUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Get the icon for an executable (Windows only)
  static Future<String?> getExecutableIcon(String path) async {
    // TODO: Implement icon extraction for Windows executables
    // This would require platform-specific code or a plugin
    return null;
  }
}
