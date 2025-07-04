import 'dart:core';
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

  /// Build Column widget
  Widget _buildColumn(LayoutElement element) {
    return Column(
      mainAxisAlignment: _parseMainAxisAlignment(
        element.getProperty<String>('mainAxisAlignment'),
      ),
      crossAxisAlignment: _parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      children: element.children?.map(_buildWidget).toList() ?? <Widget>[],
    );
  }

  /// Build Row widget
  Widget _buildRow(LayoutElement element) {
    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(
        element.getProperty<String>('mainAxisAlignment'),
      ),
      crossAxisAlignment: _parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      children: element.children?.map(_buildWidget).toList() ?? <Widget>[],
    );
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
      final String? colorString = decorationMap['color'] as String?;
      final num? borderRadius = decorationMap['borderRadius'] as num?;

      decoration = BoxDecoration(
        color: colorString != null ? _parseColor(colorString) : null,
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius.toDouble())
            : null,
      );
    }

    final width = element.getProperty<dynamic>('width');
    final height = element.getProperty<dynamic>('height');

    return Container(
      width: _parseDimension(width)?.toDouble(),
      height: _parseDimension(height)?.toDouble(),
      padding: padding,
      decoration: decoration,
      child: element.child != null ? _buildWidget(element.child!) : null,
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

      style = TextStyle(
        fontSize: fontSize?.toDouble(),
        fontWeight: _parseFontWeight(fontWeight),
        color: colorString != null ? _parseColor(colorString) : null,
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

  /// Parse color from hex string
  Color _parseColor(String colorString) {
    try {
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildWidget(_layoutConfig!.layout),
      ),
    );
  }
}
