import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/app_settings.dart';

class SettingsService {
  static const String _assetsPath = 'assets/config/app_settings.json';
  static const String _localFileName = 'app_settings.json';

  AppSettings _settings = const AppSettings();

  AppSettings get settings => _settings;

  Future<void> initialize() async {
    try {
      await _loadSettings();
      debugPrint('Settings loaded: $_settings');
    } catch (e) {
      debugPrint('Error loading settings, using defaults: $e');
      _settings = const AppSettings();
    }
  }

  Future<void> _loadSettings() async {
    final File localFile = await _getLocalSettingsFile();
    if (await localFile.exists()) {
      debugPrint('Loading settings from local file: ${localFile.path}');
      final String jsonString = await localFile.readAsString();
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      _settings = AppSettings.fromMap(jsonMap);
      return;
    }

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

  Future<File> _getLocalSettingsFile() async {
    final Directory currentDir = Directory.current;
    return File('${currentDir.path}/$_localFileName');
  }
}
