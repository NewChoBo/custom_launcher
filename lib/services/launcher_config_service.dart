import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/launcher_config.dart';
import 'package:custom_launcher/models/layout_config.dart';

/// Launcher configuration service
/// Manages launcher definitions and layout configurations
class LauncherConfigService {
  static const String _launchersPath = 'assets/config/launchers.json';
  static const String _defaultLayoutPath = 'assets/config/layout_config.json';

  LauncherConfig? _launcherConfig;
  LayoutConfig? _currentLayout;
  final Map<String, LayoutConfig> _layoutCache = <String, LayoutConfig>{};

  /// Current launcher configuration
  LauncherConfig? get launcherConfig => _launcherConfig;

  /// Current layout configuration
  LayoutConfig? get currentLayout => _currentLayout;

  /// Get current layout (alias for currentLayout getter)
  LayoutConfig? getCurrentLayout() => _currentLayout;

  /// Get layout by name from cache or load it
  LayoutConfig? getLayout(String layoutName) {
    // First check cache
    if (_layoutCache.containsKey(layoutName)) {
      return _layoutCache[layoutName];
    }

    // Try to determine path from name
    final String layoutPath = _getLayoutPath(layoutName);

    // Try to load synchronously from cache or return null
    return _layoutCache[layoutPath];
  }

  /// Get layout path from layout name
  String _getLayoutPath(String layoutName) {
    switch (layoutName.toLowerCase()) {
      case 'main':
      case 'default':
        return 'assets/config/layout_config.json';
      case 'gaming':
        return 'assets/config/gaming_layout.json';
      case 'work':
        return 'assets/config/work_layout.json';
      default:
        return 'assets/config/$layoutName.json';
    }
  }

  /// Available layouts cache
  Map<String, LayoutConfig> get layoutCache => Map.unmodifiable(_layoutCache);

  /// Initialize service and load configurations
  Future<void> initialize() async {
    try {
      debugPrint('Starting launcher configuration initialization...');
      await _loadLauncherConfig();
      await _loadDefaultLayout();
      debugPrint('Launcher configurations loaded successfully');
      debugPrint(
        'Available launchers: ${_launcherConfig?.launchers.keys.join(', ') ?? 'none'}',
      );
      debugPrint('Current layout: ${_currentLayout?.metadata.title ?? 'none'}');
    } catch (e) {
      debugPrint('Error loading launcher configurations: $e');
      rethrow;
    }
  }

  /// Load launcher definitions from assets
  Future<void> _loadLauncherConfig() async {
    try {
      debugPrint('Loading launcher config from: $_launchersPath');
      final String jsonString = await rootBundle.loadString(_launchersPath);
      debugPrint('Launcher config JSON loaded, length: ${jsonString.length}');
      _launcherConfig = LauncherConfig.fromJson(jsonString);
      debugPrint('Loaded ${_launcherConfig!.launchers.length} launchers');
    } catch (e) {
      debugPrint('Error loading launcher config: $e');
      throw Exception('Failed to load launcher configuration: $e');
    }
  }

  /// Load default layout configuration
  Future<void> _loadDefaultLayout() async {
    try {
      debugPrint('Loading default layout from: $_defaultLayoutPath');
      final String jsonString = await rootBundle.loadString(_defaultLayoutPath);
      debugPrint('Default layout JSON loaded, length: ${jsonString.length}');
      final LayoutConfig layout = LayoutConfig.fromJson(jsonString);
      _currentLayout = layout;
      _layoutCache['default'] = layout;
      debugPrint('Loaded default layout: ${layout.metadata.title}');
      debugPrint('Layout structure loaded successfully');
    } catch (e) {
      debugPrint('Error loading default layout: $e');
      throw Exception('Failed to load default layout: $e');
    }
  }

  /// Load layout configuration from assets
  Future<LayoutConfig> loadLayout(String layoutPath) async {
    // Check cache first
    if (_layoutCache.containsKey(layoutPath)) {
      return _layoutCache[layoutPath]!;
    }

    try {
      final String jsonString = await rootBundle.loadString(layoutPath);
      final LayoutConfig layout = LayoutConfig.fromJson(jsonString);
      _layoutCache[layoutPath] = layout;
      debugPrint('Loaded layout: ${layout.metadata.title}');
      return layout;
    } catch (e) {
      debugPrint('Error loading layout from $layoutPath: $e');
      throw Exception('Failed to load layout: $e');
    }
  }

  /// Switch to a different layout
  Future<void> switchLayout(String layoutPath) async {
    try {
      final LayoutConfig layout = await loadLayout(layoutPath);
      _currentLayout = layout;
      debugPrint('Switched to layout: ${layout.metadata.title}');
    } catch (e) {
      debugPrint('Error switching layout: $e');
      throw Exception('Failed to switch layout: $e');
    }
  }

  /// Get launcher by ID
  LauncherItem? getLauncher(String id) {
    return _launcherConfig?.getLauncher(id);
  }

  /// Get launchers by category
  List<LauncherItem> getLaunchersByCategory(String category) {
    return _launcherConfig?.getLaunchersByCategory(category) ??
        <LauncherItem>[];
  }

  /// Get resolved launcher action with inheritance
  LauncherAction? getResolvedAction(String launcherId, String actionType) {
    final LauncherItem? launcher = getLauncher(launcherId);
    return launcher?.getResolvedAction(actionType);
  }

  /// Get launcher image path with fallback
  String getLauncherImagePath(String launcherId, String imageType) {
    final LauncherItem? launcher = getLauncher(launcherId);
    return launcher?.getImagePath(imageType) ?? '';
  }

  /// Execute launcher action
  Future<bool> executeLauncher(
    String launcherId,
    String actionType, {
    Map<String, String>? overrides,
  }) async {
    try {
      final LauncherAction? action = getResolvedAction(launcherId, actionType);
      if (action == null || !action.isExecutable) {
        debugPrint('Cannot execute launcher: action not found or incomplete');
        return false;
      }

      final String target = overrides?['target'] ?? action.target!;
      final List<String> arguments = action.arguments ?? <String>[];
      final String? workingDirectory =
          overrides?['workingDirectory'] ?? action.workingDirectory;

      debugPrint('Executing: $target with args: $arguments');

      // Execute the application
      final Process process = await Process.start(
        target,
        arguments,
        workingDirectory: workingDirectory?.isNotEmpty == true
            ? workingDirectory
            : null,
        mode: ProcessStartMode.detached,
      );

      // Detach from process to let it run independently
      process.exitCode.then((int code) {
        debugPrint('Process exited with code: $code');
      });

      return true;
    } catch (e) {
      debugPrint('Error executing launcher: $e');
      return false;
    }
  }

  /// Get all available layout files
  Future<List<String>> getAvailableLayouts() async {
    // This could be expanded to scan asset directory
    return <String>[
      'assets/config/layout_config.json',
      'assets/config/gaming_layout.json',
      'assets/config/work_layout.json',
    ];
  }

  /// Preload common layouts
  Future<void> preloadLayouts() async {
    final List<String> layouts = await getAvailableLayouts();
    for (final String layoutPath in layouts) {
      try {
        await loadLayout(layoutPath);
      } catch (e) {
        debugPrint('Failed to preload layout $layoutPath: $e');
      }
    }
  }

  /// Get layout metadata without fully loading
  Future<LayoutMetadata?> getLayoutMetadata(String layoutPath) async {
    try {
      final String jsonString = await rootBundle.loadString(layoutPath);
      final Map<String, dynamic> json = jsonDecode(jsonString);
      final Map<String, dynamic>? metadata =
          json['metadata'] as Map<String, dynamic>?;
      if (metadata != null) {
        return LayoutMetadata.fromMap(metadata);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting layout metadata: $e');
      return null;
    }
  }
}
