import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/settings_helpers.dart';

/// Window Settings tab widget
/// 윈도우 크기, 위치, 동작 설정을 관리하는 탭 위젯
class WindowSettingsTab extends StatelessWidget {
  final AppSettings currentSettings;
  final AppSettings? tempSettings;
  final Function(AppSettings) onSettingsChanged;

  const WindowSettingsTab({
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
        SettingsHelpers.buildSectionTitle(context, 'Window Size'),
        SettingsHelpers.buildTextInputField(
          'Window Width',
          settings.window.size.windowWidth,
          (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  size: settings.window.size.copyWith(windowWidth: value),
                ),
              ),
            );
          },
        ),
        SettingsHelpers.buildTextInputField(
          'Window Height',
          settings.window.size.windowHeight,
          (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  size: settings.window.size.copyWith(windowHeight: value),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SettingsHelpers.buildSectionTitle(context, 'Window Position'),
        SettingsHelpers.buildDropdown(
          'Horizontal Position',
          settings.window.position.horizontalPosition,
          ['left', 'center', 'right'],
          (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  position: settings.window.position.copyWith(
                    horizontalPosition: value,
                  ),
                ),
              ),
            );
          },
        ),
        SettingsHelpers.buildDropdown(
          'Vertical Position',
          settings.window.position.verticalPosition,
          ['top', 'center', 'bottom'],
          (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  position: settings.window.position.copyWith(
                    verticalPosition: value,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        SettingsHelpers.buildSectionTitle(context, 'Window Behavior'),
        SettingsHelpers.buildDropdown(
          'Window Level',
          settings.window.behavior.windowLevel,
          ['normal', 'alwaysOnTop', 'alwaysBelow'],
          (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  behavior: settings.window.behavior.copyWith(
                    windowLevel: value,
                  ),
                ),
              ),
            );
          },
        ),
        SwitchListTile(
          title: const Text('Skip Taskbar'),
          subtitle: const Text('Hide window from taskbar'),
          value: settings.window.behavior.skipTaskbar,
          onChanged: (value) {
            _updateSettings(
              settings.copyWith(
                window: settings.window.copyWith(
                  behavior: settings.window.behavior.copyWith(
                    skipTaskbar: value,
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
