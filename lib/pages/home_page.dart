import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Home page widget for Custom Launcher
/// Displays main UI with system tray information
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
  /// Parse hex color string with opacity
  /// Returns null for invalid colors (will use defaults)
  Color? _parseColor(String hexString, double opacity) {
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

      final Color baseColor = Color(int.parse(hex, radix: 16));

      // Apply the opacity setting directly (ignore hex alpha)
      final Color finalColor = baseColor.withValues(alpha: opacity);

      debugPrint(
        'Parsing $hexString -> Base: ${baseColor.toString()}, Final: ${finalColor.toString()} (opacity: $opacity)',
      );

      return finalColor;
    } catch (e) {
      debugPrint('Error parsing color "$hexString": $e');
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
        Colors.transparent;

    final Color? appBarColor = _parseColor(
      widget.settings.appBarColor,
      widget.settings.appBarOpacity,
    );

    debugPrint(
      'Background: ${widget.settings.backgroundColor} -> $backgroundColor',
    );
    debugPrint('AppBar: ${widget.settings.appBarColor} -> $appBarColor');

    return Scaffold(
      appBar: widget.settings.showAppBar
          ? AppBar(
              backgroundColor:
                  appBarColor ??
                  Theme.of(context).colorScheme.inversePrimary.withValues(
                    alpha: widget.settings.appBarOpacity,
                  ),
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
      backgroundColor: backgroundColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.rocket_launch, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Custom Launcher',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Running in System Tray',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Text(
                      'System Tray Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('• Left click tray icon to show/hide window'),
                    Text('• Right click tray icon for context menu'),
                    Text('• Click minimize button to hide to tray'),
                    Text('• App continues running in background'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
