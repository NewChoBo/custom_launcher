import 'package:custom_launcher/models/layout_config.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/services/launcher_config_service.dart';
import 'package:custom_launcher/widgets/dynamic_layout.dart';

/// Home page widget for Custom Launcher
/// Displays main UI with system tray information
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.onHideToTray,
    required this.configService,
  });

  final String title;
  final Future<void> Function() onHideToTray;
  final LauncherConfigService configService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final LayoutConfig? currentLayout = widget.configService.getCurrentLayout();

    if (currentLayout == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.minimize),
              onPressed: widget.onHideToTray,
              tooltip: 'Hide to System Tray',
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error, color: Colors.red, size: 48.0),
              SizedBox(height: 16.0),
              Text(
                'No layout configuration available',
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Get colors from frame config
    final FrameConfig frame = currentLayout.frame;
    final UIConfig ui = frame.ui;

    Color? backgroundColor;
    if (ui.colors.backgroundColor.isNotEmpty) {
      backgroundColor = _parseColor(ui.colors.backgroundColor);
      if (backgroundColor != null) {
        backgroundColor = backgroundColor.withValues(
          alpha: ui.opacity.backgroundOpacity,
        );
      }
    }

    Color? appBarColor;
    if (ui.colors.appBarColor.isNotEmpty) {
      appBarColor = _parseColor(ui.colors.appBarColor);
      if (appBarColor != null) {
        appBarColor = appBarColor.withValues(alpha: ui.opacity.appBarOpacity);
      }
    }

    return Scaffold(
      appBar: ui.showAppBar
          ? AppBar(
              backgroundColor:
                  appBarColor ?? Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.minimize),
                  onPressed: widget.onHideToTray,
                  tooltip: 'Hide to System Tray',
                ),
              ],
            )
          : null,
      backgroundColor: backgroundColor ?? Colors.transparent,
      body: DynamicLayout(configService: widget.configService),
    );
  }

  /// Parse hex color string
  Color? _parseColor(String hexString) {
    try {
      if (hexString.isEmpty) return null;

      String hex = hexString.replaceFirst('#', '');
      if (!RegExp(r'^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$').hasMatch(hex)) {
        debugPrint('Invalid hex format: $hexString');
        return null;
      }

      // Handle RGB and RGBA formats
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add full alpha for RGB
      }

      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Error parsing color "$hexString": $e');
      return null;
    }
  }
}
