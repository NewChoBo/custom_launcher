import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_launcher_repository.dart';

class GetSupportedApps {
  final AppLauncherRepository repository;

  GetSupportedApps(this.repository);

  Future<List<AppInfo>> call() {
    return repository.getSupportedApps();
  }
}