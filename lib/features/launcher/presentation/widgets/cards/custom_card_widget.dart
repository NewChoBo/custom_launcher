import 'package:flutter/material.dart';
import 'dart:io';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.imagePath = 'assets/images/discord-logo.png',
    this.title = 'title',
    this.subtitle = '',
    this.imageOpacity = 0.8,
    this.executablePath,
    this.arguments,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final double imageOpacity;
  final String? executablePath;
  final List<String>? arguments;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: _launchApplication,
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
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
                opacity: imageOpacity,
              ),
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
                        title,
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
                            subtitle,
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
      ),
    );
  }

  Future<void> _launchApplication() async {
    if (executablePath == null || executablePath!.isEmpty) {
      debugPrint('No executable path provided for $title');
      return;
    }

    try {
      debugPrint('Launching: $executablePath with args: $arguments');

      await Process.start(
        executablePath!,
        arguments ?? [],
        mode: ProcessStartMode.detached,
      );

      debugPrint('Successfully launched: $title');
    } catch (e) {
      debugPrint('Failed to launch $title: $e');
    }
  }
}
