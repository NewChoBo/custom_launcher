import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
      ),
      body: settingsAsync.when(
        data: (settings) {
          _tempSettings ??= settings;
          return TabBarView(
            controller: _tabController,
            children: [
              _buildUISettings(settings),
              _buildWindowSettings(settings),
              _buildSystemSettings(settings),
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

  Widget _buildUISettings(AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Interface'),
        SwitchListTile(
          title: const Text('Show App Bar'),
          subtitle: const Text('Display the top application bar'),
          value: _tempSettings?.ui.showAppBar ?? settings.ui.showAppBar,
          onChanged: (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    ui: _tempSettings!.ui.copyWith(showAppBar: value),
                  ) ??
                  settings.copyWith(
                    ui: settings.ui.copyWith(showAppBar: value),
                  );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Colors'),
        _buildColorPicker(
          'App Bar Color',
          _tempSettings?.ui.colors.appBarColor ??
              settings.ui.colors.appBarColor,
          (color) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    ui: _tempSettings!.ui.copyWith(
                      colors: _tempSettings!.ui.colors.copyWith(
                        appBarColor: color,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    ui: settings.ui.copyWith(
                      colors: settings.ui.colors.copyWith(appBarColor: color),
                    ),
                  );
            });
          },
        ),
        _buildColorPicker(
          'Background Color',
          _tempSettings?.ui.colors.backgroundColor ??
              settings.ui.colors.backgroundColor,
          (color) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    ui: _tempSettings!.ui.copyWith(
                      colors: _tempSettings!.ui.colors.copyWith(
                        backgroundColor: color,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    ui: settings.ui.copyWith(
                      colors: settings.ui.colors.copyWith(
                        backgroundColor: color,
                      ),
                    ),
                  );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Opacity'),
        _buildOpacitySlider(
          'App Bar Opacity',
          _tempSettings?.ui.opacity.appBarOpacity ??
              settings.ui.opacity.appBarOpacity,
          (opacity) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    ui: _tempSettings!.ui.copyWith(
                      opacity: _tempSettings!.ui.opacity.copyWith(
                        appBarOpacity: opacity,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    ui: settings.ui.copyWith(
                      opacity: settings.ui.opacity.copyWith(
                        appBarOpacity: opacity,
                      ),
                    ),
                  );
            });
          },
        ),
        _buildOpacitySlider(
          'Background Opacity',
          _tempSettings?.ui.opacity.backgroundOpacity ??
              settings.ui.opacity.backgroundOpacity,
          (opacity) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    ui: _tempSettings!.ui.copyWith(
                      opacity: _tempSettings!.ui.opacity.copyWith(
                        backgroundOpacity: opacity,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    ui: settings.ui.copyWith(
                      opacity: settings.ui.opacity.copyWith(
                        backgroundOpacity: opacity,
                      ),
                    ),
                  );
            });
          },
        ),
      ],
    );
  }

  Widget _buildWindowSettings(AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Window Size'),
        _buildTextInputField(
          'Window Width',
          _tempSettings?.window.size.windowWidth ??
              settings.window.size.windowWidth,
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      size: _tempSettings!.window.size.copyWith(
                        windowWidth: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      size: settings.window.size.copyWith(windowWidth: value),
                    ),
                  );
            });
          },
        ),
        _buildTextInputField(
          'Window Height',
          _tempSettings?.window.size.windowHeight ??
              settings.window.size.windowHeight,
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      size: _tempSettings!.window.size.copyWith(
                        windowHeight: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      size: settings.window.size.copyWith(windowHeight: value),
                    ),
                  );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Window Position'),
        _buildDropdown(
          'Horizontal Position',
          _tempSettings?.window.position.horizontalPosition ??
              settings.window.position.horizontalPosition,
          ['left', 'center', 'right'],
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      position: _tempSettings!.window.position.copyWith(
                        horizontalPosition: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      position: settings.window.position.copyWith(
                        horizontalPosition: value,
                      ),
                    ),
                  );
            });
          },
        ),
        _buildDropdown(
          'Vertical Position',
          _tempSettings?.window.position.verticalPosition ??
              settings.window.position.verticalPosition,
          ['top', 'center', 'bottom'],
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      position: _tempSettings!.window.position.copyWith(
                        verticalPosition: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      position: settings.window.position.copyWith(
                        verticalPosition: value,
                      ),
                    ),
                  );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Window Behavior'),
        _buildDropdown(
          'Window Level',
          _tempSettings?.window.behavior.windowLevel ??
              settings.window.behavior.windowLevel,
          ['normal', 'alwaysOnTop', 'alwaysBelow'],
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      behavior: _tempSettings!.window.behavior.copyWith(
                        windowLevel: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      behavior: settings.window.behavior.copyWith(
                        windowLevel: value,
                      ),
                    ),
                  );
            });
          },
        ),
        SwitchListTile(
          title: const Text('Skip Taskbar'),
          subtitle: const Text('Hide window from taskbar'),
          value:
              _tempSettings?.window.behavior.skipTaskbar ??
              settings.window.behavior.skipTaskbar,
          onChanged: (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    window: _tempSettings!.window.copyWith(
                      behavior: _tempSettings!.window.behavior.copyWith(
                        skipTaskbar: value,
                      ),
                    ),
                  ) ??
                  settings.copyWith(
                    window: settings.window.copyWith(
                      behavior: settings.window.behavior.copyWith(
                        skipTaskbar: value,
                      ),
                    ),
                  );
            });
          },
        ),
      ],
    );
  }

  Widget _buildSystemSettings(AppSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('Monitor Settings'),
        _buildNumberField(
          'Monitor Index',
          _tempSettings?.system.monitorIndex ?? settings.system.monitorIndex,
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(
                    system: _tempSettings!.system.copyWith(monitorIndex: value),
                  ) ??
                  settings.copyWith(
                    system: settings.system.copyWith(monitorIndex: value),
                  );
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSectionTitle('Mode Settings'),
        _buildDropdown(
          'Application Mode',
          _tempSettings?.mode ?? settings.mode,
          ['development', 'production', 'debug'],
          (value) {
            setState(() {
              _tempSettings =
                  _tempSettings?.copyWith(mode: value) ??
                  settings.copyWith(mode: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildColorPicker(
    String title,
    String currentColor,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentColor),
      trailing: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _parseColor(currentColor),
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      onTap: () => _showColorPicker(context, currentColor, onChanged),
    );
  }

  Widget _buildOpacitySlider(
    String title,
    double value,
    Function(double) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: 0.0,
        max: 1.0,
        divisions: 10,
        label: (value * 100).round().toString() + '%',
        onChanged: onChanged,
      ),
      trailing: Text('${(value * 100).round()}%'),
    );
  }

  Widget _buildTextInputField(
    String title,
    String value,
    Function(String) onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value),
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String title,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    // 현재 값이 옵션에 없으면 첫 번째 옵션을 기본값으로 사용
    final String safeValue = options.contains(value) ? value : options.first;

    return ListTile(
      title: Text(title),
      subtitle: DropdownButtonFormField<String>(
        value: safeValue,
        items: options.map((option) {
          return DropdownMenuItem<String>(value: option, child: Text(option));
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildNumberField(String title, int value, Function(int) onChanged) {
    return ListTile(
      title: Text(title),
      subtitle: TextField(
        controller: TextEditingController(text: value.toString()),
        onChanged: (text) {
          final intValue = int.tryParse(text);
          if (intValue != null) {
            onChanged(intValue);
          }
        },
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Color _parseColor(String hexString) {
    if (hexString.isEmpty) return Colors.transparent;
    final String hex = hexString.replaceFirst('#', '');
    if (hex.length != 6) return Colors.transparent;
    final int argbValue = int.parse('FF$hex', radix: 16);
    return Color(argbValue);
  }

  void _showColorPicker(
    BuildContext context,
    String currentColor,
    Function(String) onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: currentColor),
                onChanged: onChanged,
                decoration: const InputDecoration(
                  labelText: 'Hex Color (e.g., #FF0000)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Preset Colors:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#FF0000',
                      '#00FF00',
                      '#0000FF',
                      '#FFFF00',
                      '#FF00FF',
                      '#00FFFF',
                      '#FFFFFF',
                      '#000000',
                      '#808080',
                      '#FFA500',
                      '#800080',
                      '#008000',
                    ].map((color) {
                      return GestureDetector(
                        onTap: () {
                          onChanged(color);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
