import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/cards/custom_card_widget.dart';

class CustomCardWidgetFactory {
  Widget? createWidget(LayoutElement element) {
    if (element.type.toLowerCase() != 'custom_card') {
      return null;
    }
    final String appId = element.getProperty<String>('app_id') ?? '';

    return CustomCard(
      appId: appId,
    );
  }
}