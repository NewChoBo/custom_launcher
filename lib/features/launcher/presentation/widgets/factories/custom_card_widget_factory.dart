import 'package:flutter/material.dart';
import 'dart:io';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/cards/custom_card_widget.dart';

class CustomCardWidgetFactory {
  Widget? createWidget(LayoutElement element) {
    if (element.type.toLowerCase() != 'custom_card') {
      return null;
    }
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

    final List<String> arguments =
        argumentsRaw?.map((dynamic e) => e.toString()).toList() ?? <String>[];

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
