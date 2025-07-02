import 'package:flutter/material.dart';
import 'package:custom_launcher/services/app_launcher_service.dart';

/// Launcher widget for launching external applications
class LauncherWidget extends StatefulWidget {
  final String? appName;
  final String? displayName;
  final String? icon;
  final double? width;
  final double? height;
  final Map<String, dynamic>? style;

  const LauncherWidget({
    super.key,
    this.appName,
    this.displayName,
    this.icon,
    this.width,
    this.height,
    this.style,
  });

  @override
  State<LauncherWidget> createState() => _LauncherWidgetState();
}

class _LauncherWidgetState extends State<LauncherWidget> {
  final AppLauncherService _launcherService = AppLauncherService();
  bool _isLaunching = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: widget.style?['elevation']?.toDouble() ?? 4.0,
      child: InkWell(
        onTap: _isLaunching ? null : _launchApp,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: widget.width,
          height: widget.height ?? 100,
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_isLaunching)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  _getIconData(widget.icon ?? 'apps'),
                  size: widget.style?['iconSize']?.toDouble() ?? 32.0,
                  color:
                      _parseColor(widget.style?['iconColor'] as String?) ??
                      Theme.of(context).primaryColor,
                ),
              const SizedBox(height: 8),
              Text(
                widget.displayName ?? widget.appName ?? 'App',
                style: TextStyle(
                  fontSize: widget.style?['fontSize']?.toDouble() ?? 12.0,
                  fontWeight:
                      _parseFontWeight(
                        widget.style?['fontWeight'] as String?,
                      ) ??
                      FontWeight.w500,
                  color:
                      _parseColor(widget.style?['textColor'] as String?) ??
                      Theme.of(context).textTheme.bodyMedium?.color,
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

  /// Launch the application
  Future<void> _launchApp() async {
    if (widget.appName == null) {
      debugPrint('No app name provided');
      return;
    }

    setState(() {
      _isLaunching = true;
    });

    try {
      final bool success = await _launcherService.launchApp(widget.appName!);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Launched ${widget.displayName ?? widget.appName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to launch ${widget.displayName ?? widget.appName}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  /// Parse icon data from string
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
      case 'calculator':
        return Icons.calculate;
      case 'web':
      case 'chrome':
        return Icons.web;
      case 'games':
      case 'steam':
        return Icons.games;
      case 'edit':
      case 'notepad':
        return Icons.edit;
      case 'folder':
      case 'explorer':
        return Icons.folder;
      case 'settings':
        return Icons.settings;
      case 'apps':
      default:
        return Icons.apps;
    }
  }

  /// Parse color from hex string
  Color? _parseColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;

    try {
      String hex = hexString.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Invalid color format: $hexString');
      return null;
    }
  }

  /// Parse font weight from string
  FontWeight? _parseFontWeight(String? weight) {
    switch (weight?.toLowerCase()) {
      case 'normal':
        return FontWeight.normal;
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
