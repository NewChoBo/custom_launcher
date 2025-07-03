import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Settings management service
/// Loads application settings from assets or local file
class SettingsService {
  static const String _assetsPath = 'assets/config/app_settings.json';
  static const String _localFileName = 'app_settings.json';

  AppSettings _settings = const AppSettings();

  /// Current application settings
  AppSettings get settings => _settings;

  /// Initialize and load settings from assets or local file
  Future<void> initialize() async {
    try {
      await _loadSettings();
      debugPrint('Settings loaded: $_settings');
    } catch (e) {
      debugPrint('Error loading settings, using defaults: $e');
      _settings = const AppSettings();
    }
  }

  /// Load settings from assets first, then local file if exists
  Future<void> _loadSettings() async {
    // Try to load local settings file first (user customizations)
    final File localFile = await _getLocalSettingsFile();
    if (await localFile.exists()) {
      debugPrint('Loading settings from local file: ${localFile.path}');
      final String jsonString = await localFile.readAsString();
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      _settings = AppSettings.fromMap(jsonMap);
      return;
    }

    // If no local file, load from assets
    try {
      debugPrint('Loading settings from assets: $_assetsPath');
      final String jsonString = await rootBundle.loadString(_assetsPath);
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      _settings = AppSettings.fromMap(jsonMap);
    } catch (e) {
      debugPrint('Assets settings not found, using defaults: $e');
      _settings = const AppSettings();
    }
  }

  /// Get local settings file reference
  Future<File> _getLocalSettingsFile() async {
    // Use current directory for local settings file
    final Directory currentDir = Directory.current;
    return File('${currentDir.path}/$_localFileName');
  }
}
