import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/widgets/dynamic_layout.dart';

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
    if (hexString.isEmpty) return null;
    final String hex = hexString.replaceFirst('#', '');
    if (hex.length != 6) return null;
    return Color(int.parse('FF$hex', radix: 16)).withValues(alpha: opacity);
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
      body: const DynamicLayout(),
    );
  }
}
