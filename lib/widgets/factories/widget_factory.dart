import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

/// Abstract factory for creating widgets from layout configuration
abstract class WidgetFactory {
  Widget createWidget(LayoutElement element);
  String get widgetType;
}
