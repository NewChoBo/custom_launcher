import 'package:flutter/material.dart';
import 'package:custom_launcher/services/app_launcher_service.dart';

/// Simple launcher widget for apps
class LauncherWidget extends StatefulWidget {
  final String appName;
  final String displayName;
  final String icon;
  final double width;
  final double height;
  final Map<String, dynamic>? style;

  const LauncherWidget({
    super.key,
    required this.appName,
    required this.displayName,
    required this.icon,
    this.width = 80,
    this.height = 80,
    this.style,
  });

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  final AppLauncherService _launcher = AppLauncherService();
  bool _launching = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.style?['elevation']?.toDouble() ?? 2,
      child: InkWell(
        onTap: _launching ? null : _launch,
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_launching)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  _getIcon(widget.icon),
                  size: widget.style?['iconSize']?.toDouble() ?? 28,
                  color:
                      _parseColor(widget.style?['iconColor']) ??
                      Theme.of(context).primaryColor,
                ),
              const SizedBox(height: 4),
              Text(
                widget.displayName,
                style: TextStyle(
                  fontSize: widget.style?['fontSize']?.toDouble() ?? 10,
                  fontWeight:
                      _parseFontWeight(widget.style?['fontWeight']) ??
                      FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launch() async {
    setState(() => _launching = true);

    try {
      final bool success = await _launcher.launchApp(widget.appName);
      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch ${widget.displayName}')),
        );
      }
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate;
      case 'web':
        return Icons.web;
      case 'games':
        return Icons.games;
      case 'edit_note':
        return Icons.edit_note;
      case 'folder_open':
        return Icons.folder_open;
      case 'code':
        return Icons.code;
      case 'chat':
        return Icons.chat;
      case 'music_note':
        return Icons.music_note;
      default:
        return Icons.apps;
    }
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  FontWeight? _parseFontWeight(String? value) {
    switch (value?.toLowerCase()) {
      case 'bold':
        return FontWeight.bold;
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return null;
    }
  }
}
