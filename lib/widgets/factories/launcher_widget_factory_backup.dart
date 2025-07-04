import 'dart:ui';
import 'package:custom_launcher/models/launcher_config.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/services/launcher_config_service.dart';
import 'package:custom_launcher/widgets/factories/widget_factory.dart';

/// Factory for creating launcher widgets with new launcher reference system
class LauncherWidgetFactory extends WidgetFactory {
  final LauncherConfigService? configService;

  LauncherWidgetFactory({this.configService});

  @override
  String get widgetType => 'launcher';

  @override
  Widget createWidget(LayoutElement element) {
    final String? launcherRef = element.getProperty<String>('launcherRef');
    final Map<String, dynamic> overrides =
        element.getProperty<Map<String, dynamic>>('overrides') ??
        <String, dynamic>{};
    final Map<String, dynamic> position =
        element.getProperty<Map<String, dynamic>>('position') ??
        <String, dynamic>{};
    final Map<String, dynamic> style =
        element.getProperty<Map<String, dynamic>>('style') ??
        <String, dynamic>{};

    // Get launcher info from config service
    final LauncherItem? launcher = configService?.getLauncher(
      launcherRef ?? '',
    );
    final String displayName =
        overrides['displayName'] as String? ??
        launcher?.displayName ??
        'Unknown App';
    final String actionType = overrides['action'] as String? ?? 'default';

    // Parse dimensions
    final double? width = _parseDimension(position['width']);
    final double? height = _parseDimension(position['height']) ?? 100;

    // Build advanced decoration
    final Decoration? decoration = _buildAdvancedDecoration(style);

    Widget launcherWidget = Container(
      width: width,
      height: height,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onLauncherTap(launcherRef, actionType, overrides),
          borderRadius: BorderRadius.circular(
            (style['borderRadius'] as num?)?.toDouble() ?? 8.0,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  _getIconForLauncher(launcherRef ?? ''),
                  size: 32.0,
                  color: Colors.white,
                ),
                const SizedBox(height: 4.0),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 10.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Apply hover effects if specified
    final Map<String, dynamic>? hoverMap = style['hover'] as Map<String, dynamic>?;
    if (hoverMap != null) {
      launcherWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: launcherWidget,
        ),
      );
    }

    return launcherWidget;
  }

  /// Build advanced decoration with gradients, borders, and shadows
  Decoration? _buildAdvancedDecoration(Map<String, dynamic> style) {
    // Parse gradient or solid color
    Gradient? gradient;
    Color? color;
    
    final String? gradientString = style['gradient'] as String?;
    final String? backgroundColor = style['backgroundColor'] as String?;
    
    if (gradientString != null) {
      gradient = _parseGradient(gradientString);
    } else if (backgroundColor != null) {
      color = _parseColor(backgroundColor);
    }

    // Parse border radius
    BorderRadius? borderRadius;
    final num? borderRadiusValue = style['borderRadius'] as num?;
    if (borderRadiusValue != null) {
      borderRadius = BorderRadius.circular(borderRadiusValue.toDouble());
    }

    // Parse border
    Border? border;
    final Map<String, dynamic>? borderMap = style['border'] as Map<String, dynamic>?;
    if (borderMap != null) {
      final num? width = borderMap['width'] as num?;
      final String? borderColor = borderMap['color'] as String?;
      if (width != null && borderColor != null) {
        border = Border.all(
          width: width.toDouble(),
          color: _parseColor(borderColor),
        );
      }
    }

    // Parse box shadow
    List<BoxShadow>? boxShadow;
    final Map<String, dynamic>? shadowMap = style['shadow'] as Map<String, dynamic>?;
    if (shadowMap != null) {
      boxShadow = [_parseBoxShadow(shadowMap)];
    }

    if (gradient != null || color != null || borderRadius != null || border != null || boxShadow != null) {
      return BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      );
    }

    return null;
  }

  /// Parse gradient from CSS-like string
  Gradient? _parseGradient(String gradientString) {
    // Simple linear gradient parser for "linear-gradient(135deg, #color1 0%, #color2 100%)"
    final RegExp gradientRegex = RegExp(
      r'linear-gradient\((\d+)deg,\s*([^,]+)\s+(\d+)%,\s*([^,)]+)\s+(\d+)%\)',
    );
    
    final Match? match = gradientRegex.firstMatch(gradientString);
    if (match != null) {
      final double angle = double.parse(match.group(1)!);
      final String color1 = match.group(2)!.trim();
      final String color2 = match.group(4)!.trim();
      
      // Convert CSS angle to Flutter alignment
      Alignment begin = Alignment.topLeft;
      Alignment end = Alignment.bottomRight;
      
      if (angle == 0) {
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
      } else if (angle == 45) {
        begin = Alignment.topLeft;
        end = Alignment.bottomRight;
      } else if (angle == 90) {
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
      } else if (angle == 135) {
        begin = Alignment.topRight;
        end = Alignment.bottomLeft;
      }
      
      return LinearGradient(
        begin: begin,
        end: end,
        colors: [_parseColor(color1), _parseColor(color2)],
      );
    }
    
    return null;
  }

  /// Parse box shadow from map
  BoxShadow _parseBoxShadow(Map<String, dynamic> shadowMap) {
    final String? colorString = shadowMap['color'] as String?;
    final Map<String, dynamic>? offsetMap = shadowMap['offset'] as Map<String, dynamic>?;
    final num? blur = shadowMap['blur'] as num?;
    final num? spread = shadowMap['spread'] as num?;
    
    Offset offset = Offset.zero;
    if (offsetMap != null) {
      final num? x = offsetMap['x'] as num?;
      final num? y = offsetMap['y'] as num?;
      offset = Offset(x?.toDouble() ?? 0, y?.toDouble() ?? 0);
    }
    
    return BoxShadow(
      color: colorString != null ? _parseColor(colorString) : Colors.black26,
      offset: offset,
      blurRadius: blur?.toDouble() ?? 0,
      spreadRadius: spread?.toDouble() ?? 0,
    );
  }

  /// Parse color from hex string or rgba
  Color _parseColor(String colorString) {
    try {
      colorString = colorString.trim();
      
      // Handle rgba format: rgba(255, 255, 255, 0.5)
      if (colorString.startsWith('rgba(')) {
        final RegExp rgbaRegex = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)');
        final Match? match = rgbaRegex.firstMatch(colorString);
        if (match != null) {
          final int r = int.parse(match.group(1)!);
          final int g = int.parse(match.group(2)!);
          final int b = int.parse(match.group(3)!);
          final double a = double.parse(match.group(4)!);
          return Color.fromRGBO(r, g, b, a);
        }
      }
      
      // Handle hex format: #RRGGBB or #AARRGGBB
      String hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Invalid color: $colorString');
      return Colors.black;
    }
  }
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildLauncherIcon(launcher, overrides, style),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: (style['fontSize'] as num?)?.toDouble() ?? 10,
                      fontWeight: FontWeight.w500,
                      color:
                          _parseColor(style['textColor'] as String?) ??
                          Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle launcher tap
  void _onLauncherTap(
    String? launcherRef,
    String actionType,
    Map<String, dynamic> overrides,
  ) {
    if (launcherRef != null && configService != null) {
      configService!.executeLauncher(
        launcherRef,
        actionType,
        overrides: overrides.cast<String, String>(),
      );
    } else {
      debugPrint(
        'Cannot execute launcher: launcherRef=$launcherRef, configService=$configService',
      );
    }
  }

  /// Parse color from hex string
  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;
    try {
      String hex = colorString.replaceFirst('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      debugPrint('Invalid color: $colorString');
      return null;
    }
  }

  /// Parse dimension value (number, "fill", or percentage)
  double? _parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value.toLowerCase() == 'fill') {
        return double.infinity;
      }
      // Handle percentage strings if needed
      if (value.endsWith('%')) {
        final double? percent = double.tryParse(
          value.substring(0, value.length - 1),
        );
        return percent != null ? percent / 100 : null;
      }
      return double.tryParse(value);
    }
    return null;
  }

  /// Build launcher icon with fallback to default image
  Widget _buildLauncherIcon(
    dynamic launcher,
    Map<String, dynamic> overrides,
    Map<String, dynamic> style,
  ) {
    final double iconSize = (style['iconSize'] as num?)?.toDouble() ?? 24;

    // Try to get custom icon from overrides first
    final String? customIcon = overrides['icon'] as String?;
    if (customIcon != null && customIcon.isNotEmpty) {
      return _buildImageIcon(customIcon, iconSize, style);
    }

    // Try to get icon from launcher config
    if (launcher != null && launcher.images != null) {
      final String? defaultImage = launcher.images['default'] as String?;
      if (defaultImage != null && defaultImage.isNotEmpty) {
        // Convert @/icons/ path to assets/icons/images/
        String imagePath = defaultImage;
        if (imagePath.startsWith('@/icons/')) {
          imagePath = imagePath.replaceFirst(
            '@/icons/',
            'assets/icons/images/',
          );
        }
        return _buildImageIcon(imagePath, iconSize, style);
      }
    }

    // Fallback to default icon
    return Icon(
      Icons.apps,
      size: iconSize,
      color: _parseColor(style['iconColor'] as String?) ?? Colors.blue,
    );
  }

  /// Build image icon with fallback to no_image.jpg
  Widget _buildImageIcon(
    String imagePath,
    double size,
    Map<String, dynamic> style,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
              debugPrint('Failed to load image: $imagePath, using fallback');
              return Image.asset(
                'assets/icons/images/no_image.jpg',
                width: size,
                height: size,
                fit: BoxFit.contain,
                errorBuilder:
                    (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) {
                      // Ultimate fallback to icon if no_image.jpg also fails
                      return Icon(
                        Icons.apps,
                        size: size,
                        color:
                            _parseColor(style['iconColor'] as String?) ??
                            Colors.blue,
                      );
                    },
              );
            },
      ),
    );
  }
}
