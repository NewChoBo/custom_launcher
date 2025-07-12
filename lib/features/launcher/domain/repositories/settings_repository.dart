import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  // 설정 조회
  AppSettings get settings;
  Future<AppSettings> getSettings();

  // 설정 저장
  Future<void> saveSettings(AppSettings settings);
  Future<void> initialize();

  // 개별 앱 설정 관리
  Future<void> updateAppSettings(
    String appId,
    Map<String, dynamic> appSettings,
  );
  Future<Map<String, dynamic>?> getAppSettings(String appId);
  Future<void> deleteAppSettings(String appId);
}
