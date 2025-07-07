import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

class TextBuilder {
  static Widget build(
    LayoutElement element,
    Color Function(String) parseColor,
    FontWeight? Function(String?) parseFontWeight,
    TextAlign? Function(String?) parseTextAlign,
  ) {
    final String text = element.getProperty<String>('text') ?? 'No text';
    final Map<String, dynamic>? styleMap = element
        .getProperty<Map<String, dynamic>>('style');
    final String? textAlign = element.getProperty<String>('textAlign');
    TextStyle? style;
    if (styleMap != null) {
      final LayoutStyle layoutStyle = LayoutStyle.fromMap(styleMap);
      style = TextStyle(
        fontSize: layoutStyle.fontSize,
        fontWeight: parseFontWeight(layoutStyle.fontWeight),
        color: layoutStyle.color != null
            ? parseColor(layoutStyle.color!)
            : null,
      );
    }
    return Text(text, style: style, textAlign: parseTextAlign(textAlign));
  }
}
