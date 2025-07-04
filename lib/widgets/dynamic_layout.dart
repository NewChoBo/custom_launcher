import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/services/launcher_config_service.dart';
import 'package:custom_launcher/widgets/factories/widget_registry.dart';
import 'package:custom_launcher/widgets/factories/launcher_widget_factory.dart';

/// Dynamic layout widget that builds UI from JSON configuration
class DynamicLayout extends StatefulWidget {
  final LauncherConfigService configService;
  final String? layoutName;

  const DynamicLayout({
    super.key,
    required this.configService,
    this.layoutName,
  });

  @override
  State<DynamicLayout> createState() => _DynamicLayoutState();
}

class _DynamicLayoutState extends State<DynamicLayout> {
  LayoutConfig? _layoutConfig;
  bool _isLoading = true;
  String? _error;
  final WidgetRegistry _widgetRegistry = WidgetRegistry();

  @override
  void initState() {
    super.initState();
    _initializeWidgetRegistry();
    _loadLayoutConfig();
  }

  /// Initialize widget registry with factories
  void _initializeWidgetRegistry() {
    // Register custom widget factories
    _widgetRegistry.registerFactory(
      LauncherWidgetFactory(configService: widget.configService),
    );

    debugPrint(
      'Widget registry initialized with ${_widgetRegistry.supportedTypes.length} factories',
    );
  }

  /// Load layout configuration from service
  Future<void> _loadLayoutConfig() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final LayoutConfig? config = widget.layoutName != null
          ? widget.configService.getLayout(widget.layoutName!)
          : widget.configService.getCurrentLayout();

      if (config == null) {
        throw Exception('Layout not found: ${widget.layoutName ?? 'current'}');
      }

      setState(() {
        _layoutConfig = config;
        _isLoading = false;
      });

      debugPrint('Layout config loaded successfully');
    } catch (e) {
      setState(() {
        _error = 'Failed to load layout config: $e';
        _isLoading = false;
      });
      debugPrint('Error loading layout config: $e');
    }
  }

  /// Build widget from layout element
  Widget _buildWidget(LayoutElement element) {
    debugPrint('Building widget for type: ${element.type}');

    // Try widget registry first (for custom widgets)
    final Widget? customWidget = _widgetRegistry.createWidget(element);
    if (customWidget != null) {
      debugPrint('Created custom widget for type: ${element.type}');
      return customWidget;
    }

    // Fallback to built-in widgets
    switch (element.type.toLowerCase()) {
      case 'column':
        debugPrint('Building Column widget');
        return _buildColumn(element);
      case 'row':
        debugPrint('Building Row widget');
        return _buildRow(element);
      case 'container':
        debugPrint('Building Container widget');
        return _buildContainer(element);
      case 'text':
        debugPrint('Building Text widget');
        return _buildText(element);
      case 'icon':
        debugPrint('Building Icon widget');
        return _buildIcon(element);
      case 'card':
        debugPrint('Building Card widget');
        return _buildCard(element);
      case 'sizedbox':
        debugPrint('Building SizedBox widget');
        return _buildSizedBox(element);
      default:
        debugPrint('Unknown widget type: ${element.type}');
        return Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.2),
            border: Border.all(color: Colors.red),
          ),
          child: Text(
            'Error\nUnknown: ${element.type}',
            style: const TextStyle(color: Colors.red, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
    }
  }

  /// Build Row widget
  Widget _buildRow(LayoutElement element) {
    final MainAxisAlignment mainAlignment = _parseMainAxisAlignment(
      element.getProperty<String>('mainAxisAlignment'),
    );
    final CrossAxisAlignment crossAlignment = _parseCrossAxisAlignment(
      element.getProperty<String>('crossAxisAlignment'),
    );
    final MainAxisSize mainAxisSize = _parseMainAxisSize(
      element.getProperty<String>('mainAxisSize'),
    );
    final num? spacing = element.getProperty<num>('spacing');

    List<Widget> children = <Widget>[];

    if (element.children != null) {
      for (int i = 0; i < element.children!.length; i++) {
        final LayoutElement child = element.children![i];
        final Widget widget = _buildWidget(child);
        final Widget wrappedWidget = _applyFlexWrapper(widget, child);

        children.add(wrappedWidget);

        // Add spacing between children (but not after the last one)
        if (spacing != null &&
            spacing > 0 &&
            i < element.children!.length - 1) {
          children.add(SizedBox(width: spacing.toDouble()));
        }
      }
    }

    return Row(
      mainAxisAlignment: mainAlignment,
      crossAxisAlignment: crossAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Build Column widget
  Widget _buildColumn(LayoutElement element) {
    final MainAxisAlignment mainAlignment = _parseMainAxisAlignment(
      element.getProperty<String>('mainAxisAlignment'),
    );
    final CrossAxisAlignment crossAlignment = _parseCrossAxisAlignment(
      element.getProperty<String>('crossAxisAlignment'),
    );
    final MainAxisSize mainAxisSize = _parseMainAxisSize(
      element.getProperty<String>('mainAxisSize'),
    );
    final num? spacing = element.getProperty<num>('spacing');

    List<Widget> children = <Widget>[];

    if (element.children != null) {
      for (int i = 0; i < element.children!.length; i++) {
        final LayoutElement child = element.children![i];
        final Widget widget = _buildWidget(child);
        final Widget wrappedWidget = _applyFlexWrapper(widget, child);

        children.add(wrappedWidget);

        // Add spacing between children (but not after the last one)
        if (spacing != null &&
            spacing > 0 &&
            i < element.children!.length - 1) {
          children.add(SizedBox(height: spacing.toDouble()));
        }
      }
    }

    return Column(
      mainAxisAlignment: mainAlignment,
      crossAxisAlignment: crossAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Apply flex wrapper (Expanded/Flexible) to widget based on element properties
  Widget _applyFlexWrapper(Widget widget, LayoutElement element) {
    // Check for flex property
    final num? flex = element.getProperty<num>('flex');
    final String? flexFitStr = element.getProperty<String>('flexFit');

    // Check if this element explicitly opts out of flex wrapping
    final bool? noFlex = element.getProperty<bool>('noFlex');
    if (noFlex == true) {
      return widget;
    }

    // Check for explicit width/height that should override flex behavior
    final dynamic width = element.getProperty<dynamic>('width');
    final dynamic height = element.getProperty<dynamic>('height');
    final Map<String, dynamic>? position = element
        .getProperty<Map<String, dynamic>>('position');

    // If explicit size is set and no flex properties, don't wrap
    if ((width != null || height != null || position != null) &&
        flex == null &&
        flexFitStr == null) {
      return widget;
    }

    // If no flex property is specified, use Flexible(loose) by default to avoid infinite constraint issues
    if (flex == null && flexFitStr == null) {
      return Flexible(fit: FlexFit.loose, child: widget);
    }

    final FlexFit flexFit = _parseFlexFit(flexFitStr);
    final int flexValue = flex?.toInt() ?? 1;

    if (flexFit == FlexFit.tight) {
      return Expanded(flex: flexValue, child: widget);
    } else {
      return Flexible(flex: flexValue, fit: flexFit, child: widget);
    }
  }

  /// Parse FlexFit from string
  FlexFit _parseFlexFit(String? flexFitStr) {
    switch (flexFitStr?.toLowerCase()) {
      case 'loose':
        return FlexFit.loose;
      case 'tight':
      default:
        return FlexFit.tight; // Default to tight for Expanded behavior
    }
  }

  /// Build Container widget
  Widget _buildContainer(LayoutElement element) {
    final Map<String, dynamic>? paddingMap = element
        .getProperty<Map<String, dynamic>>('padding');
    final Map<String, dynamic>? decorationMap = element
        .getProperty<Map<String, dynamic>>('decoration');

    EdgeInsetsGeometry? padding;
    if (paddingMap != null) {
      final num? all = paddingMap['all'] as num?;
      if (all != null) {
        padding = EdgeInsets.all(all.toDouble());
      } else {
        padding = EdgeInsets.only(
          top: (paddingMap['top'] as num?)?.toDouble() ?? 0,
          bottom: (paddingMap['bottom'] as num?)?.toDouble() ?? 0,
          left: (paddingMap['left'] as num?)?.toDouble() ?? 0,
          right: (paddingMap['right'] as num?)?.toDouble() ?? 0,
        );
      }
    }

    Decoration? decoration;
    if (decorationMap != null) {
      decoration = _buildAdvancedDecoration(decorationMap);
    }

    final width = element.getProperty<dynamic>('width');
    final height = element.getProperty<dynamic>('height');

    Widget container = Container(
      width: _parseDimension(width)?.toDouble(),
      height: _parseDimension(height)?.toDouble(),
      padding: padding,
      decoration: decoration,
      child: element.child != null ? _buildWidget(element.child!) : null,
    );

    // Apply blur effect if specified
    final num? blur = decorationMap?['blur'] as num?;
    if (blur != null && blur > 0) {
      container = ClipRRect(
        borderRadius: BorderRadius.circular(
          (decorationMap?['borderRadius'] as num?)?.toDouble() ?? 0,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blur.toDouble(),
            sigmaY: blur.toDouble(),
          ),
          child: container,
        ),
      );
    }

    return container;
  }

  /// Build advanced decoration with gradients, borders, and shadows
  BoxDecoration _buildAdvancedDecoration(Map<String, dynamic> decorationMap) {
    // Parse gradient or solid color
    Gradient? gradient;
    Color? color;

    final String? gradientString = decorationMap['gradient'] as String?;
    final String? colorString = decorationMap['color'] as String?;

    if (gradientString != null) {
      gradient = _parseGradient(gradientString);
    } else if (colorString != null) {
      color = _parseColor(colorString);
    }

    // Parse border radius
    BorderRadius? borderRadius;
    final num? borderRadiusValue = decorationMap['borderRadius'] as num?;
    if (borderRadiusValue != null) {
      borderRadius = BorderRadius.circular(borderRadiusValue.toDouble());
    }

    // Parse border
    Border? border;
    final Map<String, dynamic>? borderMap =
        decorationMap['border'] as Map<String, dynamic>?;
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
    final Map<String, dynamic>? shadowMap =
        decorationMap['shadow'] as Map<String, dynamic>?;
    if (shadowMap != null) {
      boxShadow = <BoxShadow>[_parseBoxShadow(shadowMap)];
    }

    return BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: borderRadius,
      border: border,
      boxShadow: boxShadow,
    );
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
        colors: <Color>[_parseColor(color1), _parseColor(color2)],
      );
    }

    return null;
  }

  /// Parse box shadow from map
  BoxShadow _parseBoxShadow(Map<String, dynamic> shadowMap) {
    final String? colorString = shadowMap['color'] as String?;
    final Map<String, dynamic>? offsetMap =
        shadowMap['offset'] as Map<String, dynamic>?;
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

  /// Build Text widget
  Widget _buildText(LayoutElement element) {
    final String text = element.getProperty<String>('text') ?? 'No text';
    final Map<String, dynamic>? styleMap = element
        .getProperty<Map<String, dynamic>>('style');
    final String? textAlign = element.getProperty<String>('textAlign');

    TextStyle? style;
    if (styleMap != null) {
      final num? fontSize = styleMap['fontSize'] as num?;
      final String? fontWeight = styleMap['fontWeight'] as String?;
      final String? colorString = styleMap['color'] as String?;
      final num? letterSpacing = styleMap['letterSpacing'] as num?;

      // Parse text shadows
      List<Shadow>? shadows;
      final List<dynamic>? shadowsList = styleMap['shadows'] as List<dynamic>?;
      if (shadowsList != null) {
        shadows = shadowsList.map((shadowData) {
          final Map<String, dynamic> shadowMap =
              shadowData as Map<String, dynamic>;
          final String? shadowColor = shadowMap['color'] as String?;
          final Map<String, dynamic>? offsetMap =
              shadowMap['offset'] as Map<String, dynamic>?;
          final num? blur = shadowMap['blur'] as num?;

          Offset offset = Offset.zero;
          if (offsetMap != null) {
            final num? x = offsetMap['x'] as num?;
            final num? y = offsetMap['y'] as num?;
            offset = Offset(x?.toDouble() ?? 0, y?.toDouble() ?? 0);
          }

          return Shadow(
            color: shadowColor != null
                ? _parseColor(shadowColor)
                : Colors.black26,
            offset: offset,
            blurRadius: blur?.toDouble() ?? 0,
          );
        }).toList();
      }

      style = TextStyle(
        fontSize: fontSize?.toDouble(),
        fontWeight: _parseFontWeight(fontWeight),
        color: colorString != null ? _parseColor(colorString) : null,
        letterSpacing: letterSpacing?.toDouble(),
        shadows: shadows,
      );
    }

    return Text(text, style: style, textAlign: _parseTextAlign(textAlign));
  }

  /// Build Icon widget
  Widget _buildIcon(LayoutElement element) {
    final String iconName = element.getProperty<String>('icon') ?? 'help';
    final num? size = element.getProperty<num>('size', 24);
    final String? colorString = element.getProperty<String>('color');

    return Icon(
      _parseIconData(iconName),
      size: size?.toDouble(),
      color: colorString != null ? _parseColor(colorString) : null,
    );
  }

  /// Build Card widget
  Widget _buildCard(LayoutElement element) {
    final num? elevation = element.getProperty<num>('elevation', 1);

    return Card(
      elevation: elevation?.toDouble(),
      child: element.child != null ? _buildWidget(element.child!) : null,
    );
  }

  /// Build SizedBox widget
  Widget _buildSizedBox(LayoutElement element) {
    final num? width = element.getProperty<num>('width');
    final num? height = element.getProperty<num>('height');

    return SizedBox(width: width?.toDouble(), height: height?.toDouble());
  }

  /// Parse color from hex string or rgba
  Color _parseColor(String colorString) {
    try {
      colorString = colorString.trim();

      // Handle rgba format: rgba(255, 255, 255, 0.5)
      if (colorString.startsWith('rgba(')) {
        final RegExp rgbaRegex = RegExp(
          r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)',
        );
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

  /// Parse dimension (supports 'fill' for double.infinity)
  num? _parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String && value.toLowerCase() == 'fill') {
      return 1.0 / 0.0; // double.infinity equivalent
    }
    return null;
  }

  /// Parse MainAxisAlignment
  MainAxisAlignment _parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Parse CrossAxisAlignment
  CrossAxisAlignment _parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  /// Parse MainAxisSize
  MainAxisSize _parseMainAxisSize(String? value) {
    switch (value?.toLowerCase()) {
      case 'min':
        return MainAxisSize.min;
      case 'max':
        return MainAxisSize.max;
      default:
        return MainAxisSize
            .min; // Changed default to min to avoid infinite constraint issues
    }
  }

  /// Parse FontWeight
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

  /// Parse TextAlign
  TextAlign? _parseTextAlign(String? value) {
    switch (value?.toLowerCase()) {
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      case 'center':
        return TextAlign.center;
      case 'justify':
        return TextAlign.justify;
      default:
        return null;
    }
  }

  /// Parse IconData from string
  IconData _parseIconData(String iconName) {
    // Create IconData from codePoint if it's a number
    final int? codePoint = int.tryParse(iconName);
    if (codePoint != null) {
      return IconData(codePoint, fontFamily: 'MaterialIcons');
    }
    return Icons.help;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16.0),
            Text('Loading layout...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error, color: Colors.red, size: 48.0),
            const SizedBox(height: 16.0),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _loadLayoutConfig,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_layoutConfig == null) {
      return const Center(child: Text('No layout configuration available'));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildWidget(_layoutConfig!.layout),
    );
  }
}
