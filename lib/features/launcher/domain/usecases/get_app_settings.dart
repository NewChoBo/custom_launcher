import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class GetAppSettings extends UseCase<AppSettings> {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  @override
  Future<AppSettings> execute() async {
    return await repository.getSettings();
  }
}
