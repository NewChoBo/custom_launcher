import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

abstract class AppRepository {
  // 앱 정보 조회
  Future<List<AppModel>> getApps();
  Future<List<AppInfo>> getAppInfoList();
  Future<AppModel?> getAppById(String id);
  Future<List<AppModel>> getSupportedApps();

  // 앱 관리 (CRUD)
  Future<void> addApp(AppModel app);
  Future<void> updateApp(AppModel app);
  Future<void> deleteApp(String id);

  // 설정 조회
  Future<AppSettings> getAppSettings();

  // 앱 실행 관련
  Future<void> launchApp(String appId);
  Future<void> updateLastLaunched(String appId);
}
