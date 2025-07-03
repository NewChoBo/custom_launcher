import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_template.dart';
import 'package:custom_launcher/services/app_launcher_service.dart';

/// Icon-style launcher template widget (minimal design)
class IconLauncherTemplate extends StatefulWidget {
  final LauncherItem item;
  final LauncherTemplate template;
  final double? size;

  const IconLauncherTemplate({
    super.key,
    required this.item,
    required this.template,
    this.size,
  });

  @override
  State<IconLauncherTemplate> createState() => _IconLauncherTemplateState();
}

class _IconLauncherTemplateState extends State<IconLauncherTemplate> {
  final AppLauncherService _launcherService = AppLauncherService();
  bool _isLaunching = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> style = {...widget.template.defaultStyle, ...(widget.item.customStyle ?? <String, dynamic>{})};
    final double iconSize = widget.size ?? _getStyleValue<double>(style, 'iconSize', 56.0);
    
    return MouseRegion(
      onEnter: (dynamic _) => setState(() => _isHovered = true),
      onExit: (dynamic _) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _isLaunching ? null : _launchApp,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Container(
            width: iconSize + 16,
            height: iconSize + 16,
            decoration: BoxDecoration(
              color: _isHovered 
                  ? (_parseColor(style['hoverColor']) ?? Colors.grey.withValues(alpha: 0.1))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                _getStyleValue<double>(style, 'borderRadius', 8.0),
              ),
            ),
            child: Center(
              child: _buildIcon(style, iconSize),
            ),
          ),
        ),
      ),
    );
  }

  /// Build icon widget
  Widget _buildIcon(Map<String, dynamic> style, double size) {
    if (_isLaunching) {
      return SizedBox(
        width: size * 0.6,
        height: size * 0.6,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: _parseColor(style['primaryColor']) ?? Theme.of(context).primaryColor,
        ),
      );
    }

    final Color iconColor = _parseColor(style['iconColor']) ?? Theme.of(context).primaryColor;

    // Use custom icon path if provided
    if (widget.item.iconPath != null) {
      return Image.asset(
        widget.item.iconPath!,
        width: size,
        height: size,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _buildDefaultIcon(size, iconColor),
      );
    }

    // Use icon name
    return _buildDefaultIcon(size, iconColor);
  }

  /// Build default icon from icon name
  Widget _buildDefaultIcon(double size, Color color) {
    return Icon(
      _parseIconFromString(widget.item.icon ?? 'apps'),
      size: size,
      color: color,
    );
  }

  /// Launch the application
  Future<void> _launchApp() async {
    setState(() {
      _isLaunching = true;
    });

    try {
      final bool success = await _launcherService.launchApp(widget.item.appName);

      if (mounted) {
        if (success) {
          // Show tooltip-style feedback
          _showTooltip('Launched ${widget.item.displayName}', Colors.green);
        } else {
          _showTooltip('Failed to launch ${widget.item.displayName}', Colors.red);
        }
      }
    } catch (e) {
      debugPrint('Error launching ${widget.item.appName}: $e');
      if (mounted) {
        _showTooltip('Error launching ${widget.item.displayName}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  /// Show tooltip-style feedback
  void _showTooltip(String message, Color color) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + (size.width / 2) - 75,
        top: position.dy - 40,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  /// Get style value with type safety and default fallback
  T _getStyleValue<T>(Map<String, dynamic> style, String key, T defaultValue) {
    final value = style[key];
    if (value is T) return value;
    if (value is num && T == double) return value.toDouble() as T;
    if (value is num && T == int) return value.toInt() as T;
    return defaultValue;
  }

  /// Parse color from string
  Color? _parseColor(dynamic colorValue) {
    if (colorValue == null) return null;
    if (colorValue is Color) return colorValue;
    if (colorValue is String) {
      try {
        if (colorValue.startsWith('#')) {
          return Color(int.parse(colorValue.substring(1), radix: 16) + 0xFF000000);
        }
        return null;
      } catch (e) {
        debugPrint('Error parsing color: $colorValue');
        return null;
      }
    }
    return null;
  }

  /// Parse icon from string
  IconData _parseIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'apps':
        return Icons.apps;
      case 'folder':
        return Icons.folder;
      case 'settings':
        return Icons.settings;
      case 'chrome':
      case 'browser':
        return Icons.language;
      case 'terminal':
      case 'console':
        return Icons.terminal;
      case 'code':
      case 'editor':
        return Icons.code;
      case 'music':
        return Icons.music_note;
      case 'video':
        return Icons.video_library;
      case 'game':
        return Icons.sports_esports;
      case 'calculator':
        return Icons.calculate;
      case 'camera':
        return Icons.camera_alt;
      case 'mail':
      case 'email':
        return Icons.mail;
      case 'phone':
        return Icons.phone;
      case 'chat':
      case 'message':
        return Icons.chat;
      case 'file':
        return Icons.insert_drive_file;
      case 'image':
      case 'photo':
        return Icons.image;
      case 'download':
        return Icons.download;
      case 'upload':
        return Icons.upload;
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      case 'bookmark':
        return Icons.bookmark;
      default:
        return Icons.apps;
    }
  }
}
