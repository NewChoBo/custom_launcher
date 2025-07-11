import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';

/// Abstract repository for launching and listing supported apps.
abstract class AppLauncherRepository {
  /// Returns a list of supported apps for the launcher.
  Future<List<AppInfo>> getSupportedApps();
}
