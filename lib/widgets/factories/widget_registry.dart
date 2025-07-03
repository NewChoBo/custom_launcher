import 'package:flutter/material.dart';
import 'package:custom_launcher/widgets/factories/widget_factory.dart';

/// Registry for managing widget factories
class WidgetRegistry {
  static final WidgetRegistry _instance = WidgetRegistry._internal();
  factory WidgetRegistry() => _instance;
  WidgetRegistry._internal();

  final Map<String, WidgetFactory> _factories = <String, WidgetFactory>{};

  /// Register a widget factory
  void registerFactory(WidgetFactory factory) {
    _factories[factory.widgetType.toLowerCase()] = factory;
    debugPrint('Registered widget factory: ${factory.widgetType}');
  }

  /// Create widget from layout element
  Widget? createWidget(dynamic element) {
    if (element == null) return null;

    final String type = element.type?.toLowerCase() ?? '';
    final WidgetFactory? factory = _factories[type];

    if (factory != null) {
      return factory.createWidget(element);
    }

    debugPrint('No factory found for widget type: $type');
    return null;
  }

  /// Get list of supported widget types
  List<String> get supportedTypes => _factories.keys.toList();
}
