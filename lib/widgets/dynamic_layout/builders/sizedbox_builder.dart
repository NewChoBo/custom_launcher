import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';

class SizedBoxBuilder {
  static Widget build(LayoutElement element) {
    final double? width = element.getProperty<num>('width')?.toDouble();
    final double? height = element.getProperty<num>('height')?.toDouble();
    return SizedBox(width: width, height: height);
  }
}
