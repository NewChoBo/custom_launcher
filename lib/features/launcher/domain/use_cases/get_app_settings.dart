import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';

class GetAppSettings {
  final AppRepository repository;

  GetAppSettings(this.repository);

  Future<AppSettings> call() async {
    return await repository.getAppSettings();
  }
}
