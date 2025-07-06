import 'package:flutter/material.dart';
import 'dart:io';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/widgets/factories/widget_factory.dart';
import 'package:custom_launcher/widgets/cards/custom_card_widget.dart';

/// Factory for creating CustomCard widgets from layout configuration
class CustomCardWidgetFactory extends WidgetFactory {
  @override
  String get widgetType => 'custom_card';

  @override
  Widget createWidget(LayoutElement element) {
    final String title = element.getProperty<String>('title') ?? 'title';
    final String subtitle = element.getProperty<String>('subtitle') ?? '';
    final String imagePath =
        element.getProperty<String>('imagePath') ??
        'assets/images/discord-logo.png';
    final double imageOpacity =
        element.getProperty<num>('imageOpacity')?.toDouble() ?? 0.8;
    final String executablePath =
        element.getProperty<String>('executablePath') ?? 'calc.exe';
    final List<dynamic>? argumentsRaw = element.getProperty<List<dynamic>>(
      'arguments',
    );

    // Convert dynamic list to List<String>
    final List<String> arguments =
        argumentsRaw?.map((e) => e.toString()).toList() ?? <String>[];

    // Handle environment variables in executablePath
    String processedPath = executablePath;
    if (processedPath.contains('%USERNAME%')) {
      final String? username = Platform.environment['USERNAME'];
      if (username != null) {
        processedPath = processedPath.replaceAll('%USERNAME%', username);
      }
    }

    return CustomCard(
      title: title,
      subtitle: subtitle,
      imagePath: imagePath,
      imageOpacity: imageOpacity,
      executablePath: processedPath,
      arguments: arguments,
    );
  }
}
