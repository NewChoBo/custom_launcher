import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/ui_settings_tab.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/window_settings_tab.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/system_settings_tab.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/settings/layout_editor_tab.dart';

/// Settings page with tabbed interface
/// 탭 인터페이스를 가진 설정 페이지
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppSettings? _tempSettings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Launcher Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'UI Settings', icon: Icon(Icons.palette)),
            Tab(text: 'Window Settings', icon: Icon(Icons.window)),
            Tab(text: 'System Settings', icon: Icon(Icons.settings)),
            Tab(text: 'Layout Editor', icon: Icon(Icons.dashboard_customize)),
          ],
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          _tempSettings ??= settings;
          return TabBarView(
            controller: _tabController,
            children: [
              UISettingsTab(
                currentSettings: settings,
                tempSettings: _tempSettings,
                onSettingsChanged: _updateTempSettings,
              ),
              WindowSettingsTab(
                currentSettings: settings,
                tempSettings: _tempSettings,
                onSettingsChanged: _updateTempSettings,
              ),
              SystemSettingsTab(
                currentSettings: settings,
                tempSettings: _tempSettings,
                onSettingsChanged: _updateTempSettings,
              ),
              const LayoutEditorTab(),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSettings,
        tooltip: 'Save Settings',
        child: const Icon(Icons.save),
      ),
    );
  }

  /// Update temp settings
  void _updateTempSettings(AppSettings newSettings) {
    setState(() {
      _tempSettings = newSettings;
    });
  }

  /// Save settings to storage
  void _saveSettings() async {
    if (_tempSettings == null) return;

    try {
      await ref
          .read(settingsNotifierProvider.notifier)
          .saveSettings(_tempSettings!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
