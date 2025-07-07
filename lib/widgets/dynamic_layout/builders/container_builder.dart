import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

class ContainerBuilder {
  static Widget build(
    LayoutElement element,
    Widget Function(LayoutElement) buildWidget,
    double? Function(dynamic) parseDimension,
    Color Function(String) parseColor,
  ) {
    final Map<String, dynamic>? paddingMap = element
        .getProperty<Map<String, dynamic>>('padding');
    final Map<String, dynamic>? decorationMap = element
        .getProperty<Map<String, dynamic>>('decoration');
    EdgeInsetsGeometry? padding;
    if (paddingMap != null) {
      final LayoutPadding layoutPadding = LayoutPadding.fromMap(paddingMap);
      if (layoutPadding.all != null) {
        padding = EdgeInsets.all(layoutPadding.all!);
      } else {
        padding = EdgeInsets.only(
          top: layoutPadding.top ?? 0,
          bottom: layoutPadding.bottom ?? 0,
          left: layoutPadding.left ?? 0,
          right: layoutPadding.right ?? 0,
        );
      }
    }
    Decoration? decoration;
    if (decorationMap != null) {
      final LayoutDecoration layoutDecoration = LayoutDecoration.fromMap(
        decorationMap,
      );
      decoration = BoxDecoration(
        color: layoutDecoration.color != null
            ? parseColor(layoutDecoration.color!)
            : null,
        borderRadius: layoutDecoration.borderRadius != null
            ? BorderRadius.circular(layoutDecoration.borderRadius!)
            : null,
      );
    }
    final width = element.getProperty<dynamic>('width');
    final height = element.getProperty<dynamic>('height');
    return Container(
      width: parseDimension(width),
      height: parseDimension(height),
      padding: padding,
      decoration: decoration,
      child: element.child != null ? buildWidget(element.child!) : null,
    );
  }
}
