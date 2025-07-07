import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/widgets/dynamic_layout/builders/spacing_util.dart';

class ColumnBuilder {
  static Widget build(
    LayoutElement element,
    Widget Function(LayoutElement) buildWidget,
  ) {
    final double? spacing =
        element.getProperty<double>('spacing') ??
        element.getProperty<int>('spacing')?.toDouble();
    final String? mainAxisSize = element.getProperty<String>('mainAxisSize');
    final String? mainAlignment = element.getProperty<String>(
      'mainAxisAlignment',
    );
    final List<Widget> children =
        element.children?.map(buildWidget).toList() ?? <Widget>[];
    return Column(
      mainAxisSize: mainAxisSize == 'max' || mainAlignment == 'start'
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: _parseMainAxisAlignment(mainAlignment),
      crossAxisAlignment: _parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      children: spacing != null
          ? SpacingUtil.addSpacing(children, spacing, true)
          : children,
    );
  }

  static MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }
}
