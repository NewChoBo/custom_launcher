import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/widgets/factories/custom_card_widget_factory.dart';

/// Dynamic layout widget that builds UI from JSON configuration
class DynamicLayout extends StatefulWidget {
  final String configPath;

  const DynamicLayout({
    super.key,
    this.configPath = 'assets/config/layout_config.json',
  });

  @override
  State<DynamicLayout> createState() => _DynamicLayoutState();
}

class _DynamicLayoutState extends State<DynamicLayout> {
  LayoutConfig? _layoutConfig;
  bool _isLoading = true;
  String? _error;
  final CustomCardWidgetFactory _customCardFactory = CustomCardWidgetFactory();

  @override
  void initState() {
    super.initState();
    _loadLayoutConfig();
  }

  /// Load layout configuration from JSON file
  Future<void> _loadLayoutConfig() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final String jsonString = await rootBundle.loadString(widget.configPath);
      final LayoutConfig config = LayoutConfig.fromJson(jsonString);

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
    // Try custom card widget first
    if (element.type.toLowerCase() == 'custom_card') {
      final Widget? customWidget = _customCardFactory.createWidget(element);
      if (customWidget != null) {
        return customWidget;
      }
    }

    // Fallback to built-in widgets
    switch (element.type.toLowerCase()) {
      case 'column':
        return _buildColumn(element);
      case 'row':
        return _buildRow(element);
      case 'expanded':
        return _buildExpanded(element);
      case 'container':
        return _buildContainer(element);
      case 'text':
        return _buildText(element);
      case 'icon':
        return _buildIcon(element);
      case 'card':
        return _buildCard(element);
      case 'sizedbox':
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
            'Unknown: ${element.type}',
            style: const TextStyle(color: Colors.red),
          ),
        );
    }
  }

  /// Build Column widget
  Widget _buildColumn(LayoutElement element) {
    final double? spacing =
        element.getProperty<double>('spacing') ??
        element.getProperty<int>('spacing')?.toDouble();

    final String? mainAxisSize = element.getProperty<String>('mainAxisSize');
    final String? mainAlignment = element.getProperty<String>(
      'mainAxisAlignment',
    );

    final List<Widget> children =
        element.children?.map(_buildWidget).toList() ?? <Widget>[];

    return Column(
      mainAxisSize: mainAxisSize == 'max' || mainAlignment == 'start'
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: _parseMainAxisAlignment(mainAlignment),
      crossAxisAlignment: _parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      children: spacing != null
          ? _addSpacing(children, spacing, true)
          : children,
    );
  }

  /// Build Row widget
  Widget _buildRow(LayoutElement element) {
    final double? spacing =
        element.getProperty<double>('spacing') ??
        element.getProperty<int>('spacing')?.toDouble();

    final List<Widget> children =
        element.children?.map(_buildWidget).toList() ?? <Widget>[];

    return Row(
      mainAxisAlignment: _parseMainAxisAlignment(
        element.getProperty<String>('mainAxisAlignment'),
      ),
      crossAxisAlignment: _parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      children: spacing != null
          ? _addSpacing(children, spacing, false)
          : children,
    );
  }

  /// Build Expanded widget
  Widget _buildExpanded(LayoutElement element) {
    final int? flex = element.getProperty<int>('flex');
    final LayoutElement? child = element.child;

    if (child == null) {
      debugPrint('Expanded widget requires a child element');
      return const SizedBox.shrink();
    }

    return Expanded(flex: flex ?? 1, child: _buildWidget(child));
  }

  /// Build Container widget
  Widget _buildContainer(LayoutElement element) {
    final Map<String, dynamic>? paddingMap = element
        .getProperty<Map<String, dynamic>>('padding');
    final Map<String, dynamic>? decorationMap = element
        .getProperty<Map<String, dynamic>>('decoration');

    EdgeInsetsGeometry? padding;
    if (paddingMap != null) {
      final LayoutPadding layoutPadding = LayoutPadding.fromMap(paddingMap);
      if (layoutPadding.all != null) {
        padding = EdgeInsets.all(layoutPadding.all!);
      } else {
        padding = EdgeInsets.only(
          top: layoutPadding.top ?? 0,
          bottom: layoutPadding.bottom ?? 0,
          left: layoutPadding.left ?? 0,
          right: layoutPadding.right ?? 0,
        );
      }
    }

    Decoration? decoration;
    if (decorationMap != null) {
      final LayoutDecoration layoutDecoration = LayoutDecoration.fromMap(
        decorationMap,
      );
      decoration = BoxDecoration(
        color: layoutDecoration.color != null
            ? _parseColor(layoutDecoration.color!)
            : null,
        borderRadius: layoutDecoration.borderRadius != null
            ? BorderRadius.circular(layoutDecoration.borderRadius!)
            : null,
      );
    }

    final width = element.getProperty<dynamic>('width');
    final height = element.getProperty<dynamic>('height');

    return Container(
      width: _parseDimension(width),
      height: _parseDimension(height),
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
      final LayoutStyle layoutStyle = LayoutStyle.fromMap(styleMap);
      style = TextStyle(
        fontSize: layoutStyle.fontSize,
        fontWeight: _parseFontWeight(layoutStyle.fontWeight),
        color: layoutStyle.color != null
            ? _parseColor(layoutStyle.color!)
            : null,
      );
    }

    return Text(text, style: style, textAlign: _parseTextAlign(textAlign));
  }

  /// Build Icon widget
  Widget _buildIcon(LayoutElement element) {
    final String iconName = element.getProperty<String>('icon') ?? 'help';
    final double? size = element.getProperty<num>('size', 24)?.toDouble();
    final String? colorString = element.getProperty<String>('color');

    return Icon(
      _parseIconData(iconName),
      size: size,
      color: colorString != null ? _parseColor(colorString) : null,
    );
  }

  /// Build Card widget
  Widget _buildCard(LayoutElement element) {
    final double? elevation = element
        .getProperty<num>('elevation', 1)
        ?.toDouble();

    return Card(
      elevation: elevation,
      child: element.child != null ? _buildWidget(element.child!) : null,
    );
  }

  /// Build SizedBox widget
  Widget _buildSizedBox(LayoutElement element) {
    final double? width = element.getProperty<num>('width')?.toDouble();
    final double? height = element.getProperty<num>('height')?.toDouble();

    return SizedBox(width: width, height: height);
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
  double? _parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String && value.toLowerCase() == 'fill') {
      return double.infinity;
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

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: _buildWidget(_layoutConfig!.layout),
    );
  }

  /// Add spacing between children widgets
  List<Widget> _addSpacing(
    List<Widget> children,
    double spacing,
    bool isColumn,
  ) {
    if (children.isEmpty) return children;

    final List<Widget> spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        if (isColumn) {
          spacedChildren.add(SizedBox(height: spacing));
        } else {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
    }
    return spacedChildren;
  }
}
