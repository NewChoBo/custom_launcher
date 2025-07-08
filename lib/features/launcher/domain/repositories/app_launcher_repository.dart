import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';

abstract class AppLauncherRepository {
  Future<bool> launchApp(String appName);
  Future<List<AppInfo>> getSupportedApps();
}