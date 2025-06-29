import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/widgets/frame_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.onHideToTray,
    required this.settings,
  });

  final String title;
  final Future<void> Function() onHideToTray;
  final AppSettings settings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Color? _parseColor(String hexString, double opacity) {
    try {
      if (hexString.isEmpty) return null;

      String hex = hexString.replaceFirst('#', '');
      if (!RegExp(r'^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$').hasMatch(hex))
        return null;

      if (hex.length == 6) hex = 'FF$hex';

      final Color baseColor = Color(int.parse(hex, radix: 16));

      return baseColor.withValues(alpha: opacity);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        _parseColor(
          widget.settings.backgroundColor,
          widget.settings.backgroundOpacity,
        ) ??
        Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: const FrameLayout(),
    );
  }
}
