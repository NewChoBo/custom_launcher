import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/widgets/factories/widget_factory.dart';
import 'package:custom_launcher/widgets/launcher_widget.dart';

/// Factory for creating launcher widgets
class LauncherWidgetFactory extends WidgetFactory {
  @override
  String get widgetType => 'launcher';

  @override
  Widget createWidget(LayoutElement element) {
    return LauncherWidget(
      appName: element.getProperty<String>('appName'),
      displayName: element.getProperty<String>('displayName'),
      icon: element.getProperty<String>('icon'),
      width: _parseDimension(element.getProperty<dynamic>('width')),
      height: _parseDimension(element.getProperty<dynamic>('height')),
      style: element.getProperty<Map<String, dynamic>>('style'),
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
