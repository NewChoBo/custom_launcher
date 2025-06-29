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
    final File file = await _getLocalSettingsFile();
    if (await file.exists()) {
      final String jsonString = await file.readAsString();
      _settings = AppSettings.fromMap(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
      return;
    }
    try {
      final String jsonString = await rootBundle.loadString(_assetsPath);
      _settings = AppSettings.fromMap(
        jsonDecode(jsonString) as Map<String, dynamic>,
      );
    } catch (e) {
      _settings = const AppSettings();
    }
  }

  Future<File> _getLocalSettingsFile() async {
    return File('${Directory.current.path}/$_localFileName');
  }
}
