import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/launcher_template.dart';

/// Service for managing launcher templates
class LauncherTemplateService {
  static LauncherTemplateService? _instance;
  static LauncherTemplateService get instance =>
      _instance ??= LauncherTemplateService._();

  LauncherTemplateService._();

  List<LauncherTemplate> _templates = <LauncherTemplate>[];
  bool _isInitialized = false;

  /// Get all available templates
  List<LauncherTemplate> get templates =>
      List<LauncherTemplate>.unmodifiable(_templates);

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize service by loading templates from JSON
  Future<void> initialize({
    String configPath = 'assets/config/launcher_templates.json',
  }) async {
    try {
      final String jsonString = await rootBundle.loadString(configPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      await _loadTemplates(jsonData);
      _isInitialized = true;

      debugPrint(
        'LauncherTemplateService initialized with ${_templates.length} templates',
      );
    } catch (e) {
      debugPrint('Error initializing LauncherTemplateService: $e');
      // Load default templates as fallback
      _loadDefaultTemplates();
      _isInitialized = true;
    }
  }

  /// Load templates from JSON data
  Future<void> _loadTemplates(Map<String, dynamic> jsonData) async {
    _templates.clear();

    final List<dynamic> templatesJson =
        jsonData['templates'] as List<dynamic>? ?? <dynamic>[];

    for (final dynamic templateJson in templatesJson) {
      try {
        final LauncherTemplate template = LauncherTemplate.fromJson(
          templateJson as Map<String, dynamic>,
        );
        _templates.add(template);
      } catch (e) {
        debugPrint('Error parsing template: $e');
      }
    }

    // Sort templates by name for consistent ordering
    _templates.sort(
      (LauncherTemplate a, LauncherTemplate b) => a.name.compareTo(b.name),
    );
  }

  /// Load default templates as fallback
  void _loadDefaultTemplates() {
    _templates = <LauncherTemplate>[
      const LauncherTemplate(
        id: 'default_card',
        name: 'Default Card',
        type: LauncherTemplateType.card,
        description: 'Standard card layout with icon and text',
        defaultStyle: <String, dynamic>{
          'width': 120.0,
          'height': 120.0,
          'elevation': 4.0,
          'borderRadius': 12.0,
          'padding': 16.0,
          'iconSize': 48.0,
          'fontSize': 12.0,
          'fontWeight': 'medium',
          'iconTextSpacing': 8.0,
          'maxLines': 2,
        },
        layout: <String, dynamic>{'direction': 'column', 'alignment': 'center'},
      ),
      const LauncherTemplate(
        id: 'compact_card',
        name: 'Compact Card',
        type: LauncherTemplateType.card,
        description: 'Smaller card layout for grid layouts',
        defaultStyle: <String, dynamic>{
          'width': 80.0,
          'height': 80.0,
          'elevation': 2.0,
          'borderRadius': 8.0,
          'padding': 8.0,
          'iconSize': 32.0,
          'fontSize': 10.0,
          'fontWeight': 'medium',
          'iconTextSpacing': 4.0,
          'maxLines': 1,
        },
        layout: <String, dynamic>{'direction': 'column', 'alignment': 'center'},
      ),
      const LauncherTemplate(
        id: 'simple_icon',
        name: 'Simple Icon',
        type: LauncherTemplateType.icon,
        description: 'Clean icon-only layout',
        defaultStyle: <String, dynamic>{
          'iconSize': 56.0,
          'borderRadius': 8.0,
          'hoverColor': '#F5F5F5',
        },
        layout: <String, dynamic>{'showTooltip': true},
      ),
      const LauncherTemplate(
        id: 'list_item',
        name: 'List Item',
        type: LauncherTemplateType.list,
        description: 'Horizontal list layout with icon and text',
        defaultStyle: <String, dynamic>{
          'width': 200.0,
          'height': 60.0,
          'borderRadius': 8.0,
          'padding': 12.0,
          'iconSize': 32.0,
          'titleFontSize': 14.0,
          'titleFontWeight': 'semibold',
          'iconTextSpacing': 12.0,
          'showBorder': false,
          'showTrailingIcon': true,
          'trailingIconSize': 16.0,
        },
        layout: <String, dynamic>{'direction': 'row', 'alignment': 'center'},
      ),
      const LauncherTemplate(
        id: 'detailed_list',
        name: 'Detailed List',
        type: LauncherTemplateType.list,
        description: 'List layout with subtitle support',
        defaultStyle: <String, dynamic>{
          'width': 250.0,
          'height': 70.0,
          'borderRadius': 8.0,
          'padding': 12.0,
          'iconSize': 36.0,
          'titleFontSize': 16.0,
          'titleFontWeight': 'semibold',
          'subtitleFontSize': 12.0,
          'subtitleFontWeight': 'normal',
          'iconTextSpacing': 12.0,
          'showBorder': true,
          'showSubtitle': true,
          'showTrailingIcon': true,
          'trailingIconSize': 18.0,
          'borderColor': '#E0E0E0',
          'borderWidth': 1.0,
        },
        layout: <String, dynamic>{'direction': 'row', 'alignment': 'center'},
      ),
    ];

    debugPrint('Loaded ${_templates.length} default templates');
  }

  /// Get template by ID
  LauncherTemplate? getTemplate(String id) {
    try {
      return _templates.firstWhere(
        (LauncherTemplate template) => template.id == id,
      );
    } catch (e) {
      debugPrint('Template not found: $id');
      return null;
    }
  }

  /// Get templates by type
  List<LauncherTemplate> getTemplatesByType(LauncherTemplateType type) {
    return _templates
        .where((LauncherTemplate template) => template.type == type)
        .toList();
  }

  /// Add custom template
  void addTemplate(LauncherTemplate template) {
    // Remove existing template with same ID
    _templates.removeWhere((LauncherTemplate t) => t.id == template.id);
    _templates.add(template);
    _templates.sort(
      (LauncherTemplate a, LauncherTemplate b) => a.name.compareTo(b.name),
    );
    debugPrint('Added custom template: ${template.id}');
  }

  /// Remove template by ID
  bool removeTemplate(String id) {
    final int initialLength = _templates.length;
    _templates.removeWhere((LauncherTemplate template) => template.id == id);
    final bool removed = _templates.length < initialLength;
    if (removed) {
      debugPrint('Removed template: $id');
    }
    return removed;
  }

  /// Export templates to JSON
  Map<String, dynamic> exportTemplates() {
    return <String, dynamic>{
      'templates': _templates
          .map((LauncherTemplate template) => template.toJson())
          .toList(),
      'metadata': <String, Object>{
        'version': '1.0',
        'createdAt': DateTime.now().toIso8601String(),
        'count': _templates.length,
      },
    };
  }

  /// Import templates from JSON
  Future<void> importTemplates(Map<String, dynamic> jsonData) async {
    await _loadTemplates(jsonData);
    debugPrint('Imported ${_templates.length} templates');
  }

  /// Reset to default templates
  void resetToDefaults() {
    _loadDefaultTemplates();
    debugPrint('Reset to default templates');
  }
}
