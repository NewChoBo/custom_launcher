import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/settings_helpers.dart';

/// System Settings tab widget
/// 모니터 인덱스, 애플리케이션 모드 설정을 관리하는 탭 위젯
class SystemSettingsTab extends StatelessWidget {
  final AppSettings currentSettings;
  final AppSettings? tempSettings;
  final Function(AppSettings) onSettingsChanged;

  const SystemSettingsTab({
    super.key,
    required this.currentSettings,
    required this.tempSettings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settings = tempSettings ?? currentSettings;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsHelpers.buildSectionTitle(context, 'Monitor Settings'),
        SettingsHelpers.buildNumberField(
          'Monitor Index',
          settings.system.monitorIndex,
          (value) {
            _updateSettings(
              settings.copyWith(
                system: settings.system.copyWith(monitorIndex: value),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SettingsHelpers.buildSectionTitle(context, 'Mode Settings'),
        SettingsHelpers.buildDropdown(
          'Application Mode',
          settings.mode,
          ['development', 'production', 'debug'],
          (value) {
            _updateSettings(settings.copyWith(mode: value));
          },
        ),
      ],
    );
  }

  void _updateSettings(AppSettings newSettings) {
    onSettingsChanged(newSettings);
  }
}
