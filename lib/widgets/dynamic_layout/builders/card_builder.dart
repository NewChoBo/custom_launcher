import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

class CardBuilder {
  static Widget build(
    LayoutElement element,
    Widget Function(LayoutElement) buildWidget,
  ) {
    final double? elevation = element
        .getProperty<num>('elevation', 1)
        ?.toDouble();
    return Card(
      elevation: elevation,
      child: element.child != null ? buildWidget(element.child!) : null,
    );
  }
}
