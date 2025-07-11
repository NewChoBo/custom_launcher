import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

class ExpandedBuilder {
  static Widget build(
    LayoutElement element,
    Widget Function(LayoutElement) buildWidget,
  ) {
    final int? flex = element.getProperty<int>('flex');
    final LayoutElement? child = element.child;
    if (child == null) {
      debugPrint('Expanded widget requires a child element');
      return const SizedBox.shrink();
    }
    return Expanded(flex: flex ?? 1, child: buildWidget(child));
  }
}
