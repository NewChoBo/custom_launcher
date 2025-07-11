import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

abstract class AppRepository {
  Future<List<AppInfo>> getAppInfoList();
  Future<AppSettings> getAppSettings();
}
