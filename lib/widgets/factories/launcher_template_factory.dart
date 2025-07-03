import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/models/launcher_template.dart';
import 'package:custom_launcher/widgets/factories/widget_factory.dart';
import 'package:custom_launcher/widgets/templates/card_launcher_template.dart';
import 'package:custom_launcher/widgets/templates/icon_launcher_template.dart';
import 'package:custom_launcher/widgets/templates/list_launcher_template.dart';

/// Factory for creating launcher template widgets
class LauncherTemplateFactory extends WidgetFactory {
  final Map<String, LauncherTemplate> _templates = <String, LauncherTemplate>{};

  @override
  String get widgetType => 'launcher_template';

  /// Register available templates
  void registerTemplates(List<LauncherTemplate> templates) {
    _templates.clear();
    for (final LauncherTemplate template in templates) {
      _templates[template.id] = template;
    }
    debugPrint('Registered ${_templates.length} launcher templates');
  }

  /// Get registered template by ID
  LauncherTemplate? getTemplate(String templateId) {
    return _templates[templateId];
  }

  /// Get all registered templates
  List<LauncherTemplate> get availableTemplates => _templates.values.toList();

  @override
  Widget createWidget(LayoutElement element) {
    // Get template ID from element properties
    final String? templateId = element.getProperty<String>('templateId');
    if (templateId == null) {
      debugPrint(
        'Warning: No templateId provided for launcher_template widget',
      );
      return _createErrorWidget('No template ID specified');
    }

    // Get template configuration
    final LauncherTemplate? template = _templates[templateId];
    if (template == null) {
      debugPrint('Warning: Template not found: $templateId');
      return _createErrorWidget('Template not found: $templateId');
    }

    // Create launcher item from element properties
    final LauncherItem launcherItem = _createLauncherItem(element);

    // Create template widget based on type
    return _createTemplateWidget(template, launcherItem, element);
  }

  /// Create launcher item from layout element
  LauncherItem _createLauncherItem(LayoutElement element) {
    return LauncherItem(
      appName: element.getProperty<String>('appName') ?? '',
      displayName:
          element.getProperty<String>('displayName') ??
          element.getProperty<String>('appName') ??
          'Unknown App',
      icon: element.getProperty<String>('icon'),
      iconPath: element.getProperty<String>('iconPath'),
      customStyle: element.getProperty<Map<String, dynamic>>('customStyle'),
      metadata: element.getProperty<Map<String, dynamic>>('metadata'),
    );
  }

  /// Create template widget based on template type
  Widget _createTemplateWidget(
    LauncherTemplate template,
    LauncherItem item,
    LayoutElement element,
  ) {
    final double? width = _parseDimension(
      element.getProperty<dynamic>('width'),
    );
    final double? height = _parseDimension(
      element.getProperty<dynamic>('height'),
    );

    switch (template.type) {
      case LauncherTemplateType.card:
        return CardLauncherTemplate(
          item: item,
          template: template,
          width: width,
          height: height,
        );

      case LauncherTemplateType.icon:
        final double? size =
            _parseDimension(element.getProperty<dynamic>('size')) ??
            width ??
            height;
        return IconLauncherTemplate(item: item, template: template, size: size);

      case LauncherTemplateType.list:
        return ListLauncherTemplate(
          item: item,
          template: template,
          width: width,
          height: height,
        );

      case LauncherTemplateType.tile:
        // For now, use list template for tile type
        return ListLauncherTemplate(
          item: item,
          template: template,
          width: width,
          height: height,
        );
    }
  }

  /// Create error widget for debugging
  Widget _createErrorWidget(String message) {
    return Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error, color: Colors.red, size: 24),
          const SizedBox(height: 4),
          const Text(
            'Error',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Parse dimension value (number or "fill")
  double? _parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.toLowerCase() == 'fill') {
        return double.infinity;
      }
      return double.tryParse(value);
    }
    return null;
  }
}
