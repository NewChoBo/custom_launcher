import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

class SaveSettings extends UseCaseWithParams<void, AppSettings> {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  @override
  Future<void> execute(AppSettings params) async {
    await repository.saveSettings(params);
  }
}
