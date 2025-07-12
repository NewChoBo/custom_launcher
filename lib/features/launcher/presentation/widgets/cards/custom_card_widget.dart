import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

class CustomCard extends ConsumerWidget {
  const CustomCard({
    super.key,
    required this.appId,
  });

  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appDataRepository = ref.watch(appDataRepositoryProvider);
    final AppModel? app = appDataRepository.getAppById(appId);

    if (app == null) {
      return const SizedBox.shrink(); // Or a placeholder for not found app
    }

    return InkWell(
      onTap: () => _launchApplication(app.executablePath, app.arguments, app.title),
      splashColor: Colors.white24,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        clipBehavior: Clip.hardEdge,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2123).withValues(alpha: 0.5),
            borderRadius: BorderRadius.zero,
            image: app.imagePath != null
                ? DecorationImage(
                    image: AssetImage(app.imagePath!),
                    fit: BoxFit.cover,
                    opacity: 0.8,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      app.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Text(
                          app.subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchApplication(String? executablePath, List<String>? arguments, String title) async {
    if (executablePath == null || executablePath.isEmpty) {
      debugPrint('No executable path provided for $title');
      return;
    }

    try {
      debugPrint('Launching: $executablePath with args: $arguments');

      await Process.start(
        executablePath,
        arguments ?? [],
        mode: ProcessStartMode.detached,
      );

      debugPrint('Successfully launched: $title');
    } catch (e) {
      debugPrint('Failed to launch $title: $e');
    }
  }
}