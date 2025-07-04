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

    return Container(
      width: _parseDimension(position['width']),
      height: _parseDimension(position['height']) ?? 100,
      child: Card(
        elevation: (style['elevation'] as num?)?.toDouble() ?? 4.0,
        child: InkWell(
          onTap: () => _onLauncherTap(launcherRef, actionType, overrides),
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
