import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';
import 'package:custom_launcher/core/storage/file_service.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final AppLocalDataSource localDataSource;
  AppSettings? _cachedSettings;
  Map<String, Map<String, dynamic>> _appSettings = {};

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  AppSettings get settings {
    if (_cachedSettings == null) {
      throw Exception('Settings not initialized. Call initialize() first.');
    }
    return _cachedSettings!;
  }

  @override
  Future<AppSettings> getSettings() async {
    if (_cachedSettings != null) {
      return _cachedSettings!;
    }

    try {
      if (await FileService.instance.fileExists('app_settings.json')) {
        final data = await FileService.instance.readJsonFile(
          'app_settings.json',
        );
        _cachedSettings = AppSettings.fromJson(data);
        LogManager.instance.logger.info(
          'Loaded user settings from app_settings.json',
          tag: 'SettingsRepository',
        );
        return _cachedSettings!;
      }
    } catch (e) {
      LogManager.instance.logger.warn(
        'Failed to load user settings, falling back to default settings',
        tag: 'SettingsRepository',
        error: e,
      );
    }

    _cachedSettings = await localDataSource.getAppSettings();
    return _cachedSettings!;
  }

  @override
  Future<void> initialize() async {
    try {
      _cachedSettings = await localDataSource.getAppSettings();
      await _loadAppSettings();
    } catch (e) {
      throw Exception('Failed to initialize settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      _cachedSettings = settings;

      final settingsData = {
        'mode': settings.mode,
        'ui': {
          'showAppBar': settings.ui.showAppBar,
          'colors': {
            'appBarColor': settings.ui.colors.appBarColor,
            'backgroundColor': settings.ui.colors.backgroundColor,
          },
          'opacity': {
            'appBarOpacity': settings.ui.opacity.appBarOpacity,
            'backgroundOpacity': settings.ui.opacity.backgroundOpacity,
          },
        },
        'window': {
          'size': {
            'windowWidth': settings.window.size.windowWidth,
            'windowHeight': settings.window.size.windowHeight,
          },
          'position': {
            'horizontalPosition': settings.window.position.horizontalPosition,
            'verticalPosition': settings.window.position.verticalPosition,
            'margin': {
              'top': settings.window.position.margin.top,
              'right': settings.window.position.margin.right,
              'bottom': settings.window.position.margin.bottom,
              'left': settings.window.position.margin.left,
            },
          },
          'behavior': {
            'windowLevel': settings.window.behavior.windowLevel,
            'skipTaskbar': settings.window.behavior.skipTaskbar,
          },
        },
        'system': {'monitorIndex': settings.system.monitorIndex},
      };

      await FileService.instance.writeJsonFile(
        'app_settings.json',
        settingsData,
      );
      LogManager.instance.logger.info(
        'Saved user settings to app_settings.json',
        tag: 'SettingsRepository',
      );
    } catch (e, stackTrace) {
      LogManager.instance.logger.error(
        'Failed to save settings',
        tag: 'SettingsRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to save settings',
        details: 'Error writing settings to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAppSettings(
    String appId,
    Map<String, dynamic> appSettings,
  ) async {
    try {
      _appSettings[appId] = appSettings;

      final appSettingsData = {
        'appSettings': _appSettings,
        'version': '1.0.0',
        'lastModified': DateTime.now().toIso8601String(),
      };

      await FileService.instance.writeJsonFile(
        'app_individual_settings.json',
        appSettingsData,
      );
      LogManager.instance.logger.debug(
        'Updated app settings for $appId',
        tag: 'SettingsRepository',
      );
    } catch (e, stackTrace) {
      LogManager.instance.logger.error(
        'Failed to update app settings for $appId',
        tag: 'SettingsRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to update app settings',
        details: 'Error writing app settings to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<Map<String, dynamic>?> getAppSettings(String appId) async {
    return _appSettings[appId];
  }

  @override
  Future<void> deleteAppSettings(String appId) async {
    try {
      _appSettings.remove(appId);

      final appSettingsData = {
        'appSettings': _appSettings,
        'version': '1.0.0',
        'lastModified': DateTime.now().toIso8601String(),
      };

      await FileService.instance.writeJsonFile(
        'app_individual_settings.json',
        appSettingsData,
      );
      LogManager.instance.logger.debug(
        'Deleted app settings for $appId',
        tag: 'SettingsRepository',
      );
    } catch (e, stackTrace) {
      LogManager.instance.logger.error(
        'Failed to delete app settings for $appId',
        tag: 'SettingsRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to delete app settings',
        details: 'Error deleting app settings from file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _loadAppSettings() async {
    try {
      if (await FileService.instance.fileExists(
        'app_individual_settings.json',
      )) {
        final data = await FileService.instance.readJsonFile(
          'app_individual_settings.json',
        );
        if (data.containsKey('appSettings')) {
          _appSettings = Map<String, Map<String, dynamic>>.from(
            (data['appSettings'] as Map<String, dynamic>).map(
              (key, value) =>
                  MapEntry(key, Map<String, dynamic>.from(value as Map)),
            ),
          );
        }
        LogManager.instance.logger.debug(
          'Loaded app settings for ${_appSettings.length} apps',
          tag: 'SettingsRepository',
        );
      } else {
        LogManager.instance.logger.debug(
          'No app settings file found, starting with empty settings',
          tag: 'SettingsRepository',
        );
        _appSettings = {};
      }
    } catch (e) {
      LogManager.instance.logger.warn(
        'Failed to load app settings, starting with empty settings',
        tag: 'SettingsRepository',
        error: e,
      );
      _appSettings = {};
    }
  }
}
