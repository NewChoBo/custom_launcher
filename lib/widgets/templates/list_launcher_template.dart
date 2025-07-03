import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_template.dart';
import 'package:custom_launcher/services/app_launcher_service.dart';

/// List-style launcher template widget (horizontal layout)
class ListLauncherTemplate extends StatefulWidget {
  final LauncherItem item;
  final LauncherTemplate template;
  final double? width;
  final double? height;

  const ListLauncherTemplate({
    super.key,
    required this.item,
    required this.template,
    this.width,
    this.height,
  });

  @override
  State<ListLauncherTemplate> createState() => _ListLauncherTemplateState();
}

class _ListLauncherTemplateState extends State<ListLauncherTemplate> {
  final AppLauncherService _launcherService = AppLauncherService();
  bool _isLaunching = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final style = {...widget.template.defaultStyle, ...?widget.item.customStyle};
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width ?? _getStyleValue<double>(style, 'width', 200.0),
        height: widget.height ?? _getStyleValue<double>(style, 'height', 60.0),
        margin: EdgeInsets.symmetric(
          vertical: _getStyleValue<double>(style, 'verticalMargin', 2.0),
          horizontal: _getStyleValue<double>(style, 'horizontalMargin', 4.0),
        ),
        decoration: BoxDecoration(
          color: _isHovered 
              ? (_parseColor(style['hoverColor']) ?? Theme.of(context).hoverColor)
              : (_parseColor(style['backgroundColor']) ?? Colors.transparent),
          borderRadius: BorderRadius.circular(
            _getStyleValue<double>(style, 'borderRadius', 8.0),
          ),
          border: _getStyleValue<bool>(style, 'showBorder', false)
              ? Border.all(
                  color: _parseColor(style['borderColor']) ?? Colors.grey.withValues(alpha: 0.3),
                  width: _getStyleValue<double>(style, 'borderWidth', 1.0),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLaunching ? null : _launchApp,
            borderRadius: BorderRadius.circular(
              _getStyleValue<double>(style, 'borderRadius', 8.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(_getStyleValue<double>(style, 'padding', 12.0)),
              child: Row(
                children: [
                  // Icon
                  _buildIcon(style),
                  SizedBox(width: _getStyleValue<double>(style, 'iconTextSpacing', 12.0)),
                  // Text content
                  Expanded(
                    child: _buildTextContent(style),
                  ),
                  // Optional trailing icon
                  if (_getStyleValue<bool>(style, 'showTrailingIcon', false))
                    Icon(
                      Icons.launch,
                      size: _getStyleValue<double>(style, 'trailingIconSize', 16.0),
                      color: _parseColor(style['trailingIconColor']) ?? 
                             Theme.of(context).textTheme.bodySmall?.color,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build icon widget
  Widget _buildIcon(Map<String, dynamic> style) {
    final iconSize = _getStyleValue<double>(style, 'iconSize', 32.0);

    if (_isLaunching) {
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _parseColor(style['primaryColor']) ?? Theme.of(context).primaryColor,
        ),
      );
    }

    final iconColor = _parseColor(style['iconColor']) ?? Theme.of(context).primaryColor;

    // Use custom icon path if provided
    if (widget.item.iconPath != null) {
      return Image.asset(
        widget.item.iconPath!,
        width: iconSize,
        height: iconSize,
        errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(iconSize, iconColor),
      );
    }

    // Use icon name
    return _buildDefaultIcon(iconSize, iconColor);
  }

  /// Build default icon from icon name
  Widget _buildDefaultIcon(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Icon(
        _parseIconFromString(widget.item.icon ?? 'apps'),
        size: size * 0.6,
        color: color,
      ),
    );
  }

  /// Build text content
  Widget _buildTextContent(Map<String, dynamic> style) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Main title
        Text(
          widget.item.displayName,
          style: TextStyle(
            fontSize: _getStyleValue<double>(style, 'titleFontSize', 14.0),
            fontWeight: _parseFontWeight(style['titleFontWeight']) ?? FontWeight.w600,
            color: _parseColor(style['titleColor']) ?? 
                   Theme.of(context).textTheme.titleMedium?.color,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        // Subtitle (optional)
        if (_getStyleValue<bool>(style, 'showSubtitle', false))
          Text(
            widget.item.metadata?['description'] as String? ?? widget.item.appName,
            style: TextStyle(
              fontSize: _getStyleValue<double>(style, 'subtitleFontSize', 11.0),
              fontWeight: _parseFontWeight(style['subtitleFontWeight']) ?? FontWeight.w400,
              color: _parseColor(style['subtitleColor']) ?? 
                     Theme.of(context).textTheme.bodySmall?.color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
      ],
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
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Launched ${widget.item.displayName}'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Failed to launch ${widget.item.displayName}'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching ${widget.item.appName}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Error launching ${widget.item.displayName}'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
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
    final value = style[key];
    if (value is T) return value;
    if (value is num && T == double) return value.toDouble() as T;
    if (value is num && T == int) return value.toInt() as T;
    if (value is String && T == bool) {
      return (value.toLowerCase() == 'true') as T;
    }
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
