import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Settings management service
/// Loads application settings from assets or local file
class SettingsService {
  static const String _assetsPath = 'assets/config/app_settings.yaml';
  static const String _localFileName = 'app_settings.yaml';

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
    final localFile = await _getLocalSettingsFile();

    if (await localFile.exists()) {
      debugPrint('Loading settings from local file: ${localFile.path}');
      final yamlString = await localFile.readAsString();
      final yamlMap = loadYaml(yamlString) as Map;
      final settingsMap = Map<String, dynamic>.from(yamlMap);
      _settings = AppSettings.fromMap(settingsMap);
      return;
    }

    // If no local file, load from assets
    try {
      debugPrint('Loading settings from assets: $_assetsPath');
      final yamlString = await rootBundle.loadString(_assetsPath);
      final yamlMap = loadYaml(yamlString) as Map;
      final settingsMap = Map<String, dynamic>.from(yamlMap);
      _settings = AppSettings.fromMap(settingsMap);

      // Create local copy for user to customize
      await _createLocalSettingsFile(localFile, yamlString);
    } catch (e) {
      debugPrint('Assets settings not found, using defaults: $e');
      _settings = const AppSettings();

      // Create example settings file
      await _createExampleSettingsFile(localFile);
    }
  }

  /// Get local settings file reference
  Future<File> _getLocalSettingsFile() async {
    // Use current directory for local settings file
    final currentDir = Directory.current;
    return File('${currentDir.path}/$_localFileName');
  }

  /// Create local copy of settings file for user customization
  Future<void> _createLocalSettingsFile(File file, String content) async {
    try {
      await file.writeAsString(content);
      debugPrint('Local settings file created at: ${file.path}');
      debugPrint('You can now customize settings by editing this file.');
    } catch (e) {
      debugPrint('Error creating local settings file: $e');
    }
  }

  /// Create example settings file for user reference
  Future<void> _createExampleSettingsFile(File file) async {
    try {
      const exampleSettings = AppSettings(
        backgroundOpacity: 0.9,
        appBarOpacity: 0.8,
        windowWidth: 800.0,
        windowHeight: 600.0,
        skipTaskbar: true,
      );

      // Create YAML content
      final yamlContent =
          '''# Custom Launcher Settings
# Configure transparency and window behavior

# UI Transparency (0.0 = fully transparent, 1.0 = fully opaque)
backgroundOpacity: ${exampleSettings.backgroundOpacity}
appBarOpacity: ${exampleSettings.appBarOpacity}

# Window Size
windowWidth: ${exampleSettings.windowWidth}
windowHeight: ${exampleSettings.windowHeight}

# Behavior
skipTaskbar: ${exampleSettings.skipTaskbar}
''';

      await file.writeAsString(yamlContent);
      debugPrint('Example settings file created at: ${file.path}');
    } catch (e) {
      debugPrint('Error creating example settings file: $e');
    }
  }
}
