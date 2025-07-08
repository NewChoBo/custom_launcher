import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';

class GetAppSettings {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  AppSettings call() {
    return repository.settings;
  }
}