import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

abstract class AppLocalDataSource {
  Future<List<AppInfo>> getAppInfoList();
  Future<AppSettings> getAppSettings();
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  @override
  Future<List<AppInfo>> getAppInfoList() async {
    final String response = await rootBundle.loadString('assets/config/app_assets.json');
    final data = await json.decode(response);
    final List<AppInfo> appInfoList = [];
    if (data['apps'] is Map) {
      data['apps'].forEach((key, value) {
        appInfoList.add(AppInfo.fromJson(value as Map<String, dynamic>));
      });
    }
    return appInfoList;
  }

  @override
  Future<AppSettings> getAppSettings() async {
    final String response = await rootBundle.loadString('assets/config/app_settings.json');
    final data = await json.decode(response);
    return AppSettings.fromJson(data as Map<String, dynamic>);
  }
}
