import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

class IconBuilder {
  static Widget build(
    LayoutElement element,
    IconData Function(String) parseIconData,
    Color Function(String) parseColor,
  ) {
    final String iconName = element.getProperty<String>('icon') ?? 'help';
    final double? size = element.getProperty<num>('size', 24)?.toDouble();
    final String? colorString = element.getProperty<String>('color');
    return Icon(
      parseIconData(iconName),
      size: size,
      color: colorString != null ? parseColor(colorString) : null,
    );
  }
}
