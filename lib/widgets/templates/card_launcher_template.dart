import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_template.dart';
import 'package:custom_launcher/services/app_launcher_service.dart';

/// Card-style launcher template widget
class CardLauncherTemplate extends StatefulWidget {
  final LauncherItem item;
  final LauncherTemplate template;
  final double? width;
  final double? height;

  const CardLauncherTemplate({
    super.key,
    required this.item,
    required this.template,
    this.width,
    this.height,
  });

  @override
  State<CardLauncherTemplate> createState() => _CardLauncherTemplateState();
}

class _CardLauncherTemplateState extends State<CardLauncherTemplate> {
  final AppLauncherService _launcherService = AppLauncherService();
  bool _isLaunching = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> style = {...widget.template.defaultStyle, ...(widget.item.customStyle ?? <String, dynamic>{})};
    
    return Card(
      elevation: _getStyleValue<double>(style, 'elevation', 4.0),
      margin: EdgeInsets.all(_getStyleValue<double>(style, 'margin', 8.0)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          _getStyleValue<double>(style, 'borderRadius', 12.0),
        ),
      ),
      child: InkWell(
        onTap: _isLaunching ? null : _launchApp,
        borderRadius: BorderRadius.circular(
          _getStyleValue<double>(style, 'borderRadius', 12.0),
        ),
        child: Container(
          width: widget.width ?? _getStyleValue<double>(style, 'width', 120.0),
          height: widget.height ?? _getStyleValue<double>(style, 'height', 120.0),
          padding: EdgeInsets.all(_getStyleValue<double>(style, 'padding', 16.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Icon or loading indicator
              _buildIcon(style),
              SizedBox(height: _getStyleValue<double>(style, 'iconTextSpacing', 8.0)),
              // App name
              _buildText(style),
            ],
          ),
        ),
      ),
    );
  }

  /// Build icon widget
  Widget _buildIcon(Map<String, dynamic> style) {
    if (_isLaunching) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _parseColor(style['primaryColor']) ?? Theme.of(context).primaryColor,
        ),
      );
    }

    final double iconSize = _getStyleValue<double>(style, 'iconSize', 48.0);
    final Color iconColor = _parseColor(style['iconColor']) ?? Theme.of(context).primaryColor;

    // Use custom icon path if provided
    if (widget.item.iconPath != null) {
      return Image.asset(
        widget.item.iconPath!,
        width: iconSize,
        height: iconSize,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => _buildDefaultIcon(iconSize, iconColor),
      );
    }

    // Use icon name
    return _buildDefaultIcon(iconSize, iconColor);
  }

  /// Build default icon from icon name
  Widget _buildDefaultIcon(double size, Color color) {
    return Icon(
      _parseIconFromString(widget.item.icon ?? 'apps'),
      size: size,
      color: color,
    );
  }

  /// Build text widget
  Widget _buildText(Map<String, dynamic> style) {
    return Text(
      widget.item.displayName,
      style: TextStyle(
        fontSize: _getStyleValue<double>(style, 'fontSize', 12.0),
        fontWeight: _parseFontWeight(style['fontWeight']) ?? FontWeight.w500,
        color: _parseColor(style['textColor']) ?? Theme.of(context).textTheme.bodyMedium?.color,
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: _getStyleValue<int>(style, 'maxLines', 2),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Launched ${widget.item.displayName}'),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to launch ${widget.item.displayName}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching ${widget.item.appName}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error launching ${widget.item.displayName}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  /// Get style value with type safety and default fallback
  T _getStyleValue<T>(Map<String, dynamic> style, String key, T defaultValue) {
    final dynamic value = style[key];
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
        // Handle named colors if needed
        return null;
      } catch (e) {
        debugPrint('Error parsing color: $colorValue');
        return null;
      }
    }
    return null;
  }

  /// Parse font weight from string
  FontWeight? _parseFontWeight(dynamic weightValue) {
    if (weightValue == null) return null;
    if (weightValue is FontWeight) return weightValue;
    if (weightValue is String) {
      switch (weightValue.toLowerCase()) {
        case 'thin':
        case '100':
          return FontWeight.w100;
        case 'extralight':
        case '200':
          return FontWeight.w200;
        case 'light':
        case '300':
          return FontWeight.w300;
        case 'normal':
        case 'regular':
        case '400':
          return FontWeight.w400;
        case 'medium':
        case '500':
          return FontWeight.w500;
        case 'semibold':
        case '600':
          return FontWeight.w600;
        case 'bold':
        case '700':
          return FontWeight.w700;
        case 'extrabold':
        case '800':
          return FontWeight.w800;
        case 'black':
        case '900':
          return FontWeight.w900;
        default:
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
