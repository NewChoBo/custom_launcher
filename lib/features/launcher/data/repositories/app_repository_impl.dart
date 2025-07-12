import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:custom_launcher/core/storage/file_service.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource localDataSource;
  List<AppModel> _apps = [];
  bool _isLoaded = false;

  AppRepositoryImpl({required this.localDataSource});

  Future<void> _loadAppsIfNeeded() async {
    if (_isLoaded) return;

    try {
      final String response = await rootBundle.loadString(
        'assets/config/app_data.json',
      );
      final data = json.decode(response);
      _apps = (data['apps'] as List)
          .map((e) => AppModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      throw Exception('Failed to load app data: $e');
    }
  }

  @override
  Future<List<AppModel>> getApps() async {
    await _loadAppsIfNeeded();
    return List.from(_apps);
  }

  @override
  Future<List<AppInfo>> getAppInfoList() async {
    return await localDataSource.getAppInfoList();
  }

  @override
  Future<AppModel?> getAppById(String id) async {
    await _loadAppsIfNeeded();
    try {
      return _apps.firstWhere((app) => app.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AppModel>> getSupportedApps() async {
    await _loadAppsIfNeeded();
    return _apps.where((app) => app.isEnabled).toList();
  }

  @override
  Future<void> addApp(AppModel app) async {
    await _loadAppsIfNeeded();
    _apps.add(app);
    await _saveApps();
  }

  @override
  Future<void> updateApp(AppModel app) async {
    await _loadAppsIfNeeded();
    final index = _apps.indexWhere((a) => a.id == app.id);
    if (index != -1) {
      _apps[index] = app;
      await _saveApps();
    }
  }

  @override
  Future<void> deleteApp(String id) async {
    await _loadAppsIfNeeded();
    _apps.removeWhere((app) => app.id == id);
    await _saveApps();
  }

  @override
  Future<AppSettings> getAppSettings() async {
    return await localDataSource.getAppSettings();
  }

  @override
  Future<void> launchApp(String appId) async {
    final app = await getAppById(appId);
    if (app == null || app.executablePath == null) {
      throw Exception('App not found or no executable path: $appId');
    }

    try {
      await Process.start(
        app.executablePath!,
        app.arguments ?? [],
        mode: ProcessStartMode.detached,
      );
    } catch (e) {
      throw Exception('Failed to launch app $appId: $e');
    }
  }

  @override
  Future<void> updateLastLaunched(String appId) async {
    final app = await getAppById(appId);
    if (app != null) {
      final updatedApp = app.copyWith(
        lastLaunched: DateTime.now(),
        launchCount: app.launchCount + 1,
      );
      await updateApp(updatedApp);
    }
  }

  Future<void> _saveApps() async {
    try {
      final appData = {
        'apps': _apps.map((app) => app.toJson()).toList(),
        'version': '1.0.0',
        'lastModified': DateTime.now().toIso8601String(),
      };

      await fileService.writeJsonFile('user_apps.json', appData);
      LogManager.info(
        'Saved ${_apps.length} apps to user_apps.json',
        tag: 'AppRepository',
      );
    } catch (e, stackTrace) {
      LogManager.error(
        'Failed to save apps',
        tag: 'AppRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to save app data',
        details: 'Error writing app data to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
