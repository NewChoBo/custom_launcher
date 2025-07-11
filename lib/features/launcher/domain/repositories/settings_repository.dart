import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  AppSettings get settings;
  Future<void> initialize();
}