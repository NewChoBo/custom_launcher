import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

/// Abstract base class for widget factories
abstract class WidgetFactory {
  /// The type of widget this factory creates
  String get widgetType;

  /// Create a widget from a layout element
  Widget createWidget(LayoutElement element);
}
