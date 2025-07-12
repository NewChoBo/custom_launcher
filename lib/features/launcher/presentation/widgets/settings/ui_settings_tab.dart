import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/settings_helpers.dart';

/// UI Settings tab widget
/// 인터페이스 색상, 투명도, 표시 옵션을 관리하는 탭 위젯
class UISettingsTab extends StatelessWidget {
  final AppSettings currentSettings;
  final AppSettings? tempSettings;
  final Function(AppSettings) onSettingsChanged;

  const UISettingsTab({
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
        SettingsHelpers.buildSectionTitle(context, 'Interface'),
        SwitchListTile(
          title: const Text('Show App Bar'),
          subtitle: const Text('Display the top application bar'),
          value: settings.ui.showAppBar,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(ui: settings.ui.copyWith(showAppBar: value)),
            );
          },
        ),
        const SizedBox(height: 16),
        SettingsHelpers.buildSectionTitle(context, 'Colors'),
        SettingsHelpers.buildColorPicker(
          context,
          'App Bar Color',
          settings.ui.colors.appBarColor,
          (color) {
            _updateSettings(
              settings.copyWith(
                ui: settings.ui.copyWith(
                  colors: settings.ui.colors.copyWith(appBarColor: color),
                ),
              ),
            );
          },
        ),
        SettingsHelpers.buildColorPicker(
          context,
          'Background Color',
          settings.ui.colors.backgroundColor,
          (color) {
            _updateSettings(
              settings.copyWith(
                ui: settings.ui.copyWith(
                  colors: settings.ui.colors.copyWith(backgroundColor: color),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SettingsHelpers.buildSectionTitle(context, 'Opacity'),
        SettingsHelpers.buildOpacitySlider(
          'App Bar Opacity',
          settings.ui.opacity.appBarOpacity,
          (opacity) {
            _updateSettings(
              settings.copyWith(
                ui: settings.ui.copyWith(
                  opacity: settings.ui.opacity.copyWith(appBarOpacity: opacity),
                ),
              ),
            );
          },
        ),
        SettingsHelpers.buildOpacitySlider(
          'Background Opacity',
          settings.ui.opacity.backgroundOpacity,
          (opacity) {
            _updateSettings(
              settings.copyWith(
                ui: settings.ui.copyWith(
                  opacity: settings.ui.opacity.copyWith(
                    backgroundOpacity: opacity,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _updateSettings(AppSettings newSettings) {
    onSettingsChanged(newSettings);
  }
}
