import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';

class GetSupportedApps {
  final AppRepository repository;

  GetSupportedApps(this.repository);

  Future<List<AppInfo>> call() async {
    // This is a placeholder implementation. 
    // The actual logic for getting supported apps should be implemented here.
    return await repository.getAppInfoList();
  }
}
