import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/factories/custom_card_widget_factory.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/column_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/row_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/expanded_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/container_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/text_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/icon_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/card_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/sizedbox_builder.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/parse_util.dart';

class DynamicLayout extends StatefulWidget {
  final String? configPath;
  final LayoutConfig? layoutConfig;

  const DynamicLayout({super.key, this.configPath, this.layoutConfig});

  @override
  State<DynamicLayout> createState() => _DynamicLayoutState();
}

class _DynamicLayoutState extends State<DynamicLayout> {
  LayoutConfig? _layoutConfig;
  bool _isLoading = true;
  String? _error;
  final CustomCardWidgetFactory _customCardFactory = CustomCardWidgetFactory();

  late final Map<String, Widget Function(LayoutElement)> _widgetBuilders;

  @override
  void initState() {
    super.initState();
    _widgetBuilders = <String, Widget Function(LayoutElement p1)>{
      'column': (LayoutElement e) => ColumnBuilder.build(e, _buildWidget),
      'row': (LayoutElement e) => RowBuilder.build(e, _buildWidget),
      'expanded': (LayoutElement e) => ExpandedBuilder.build(e, _buildWidget),
      'container': (LayoutElement e) => ContainerBuilder.build(
        e,
        _buildWidget,
        ParseUtil.parseDimension,
        ParseUtil.parseColor,
      ),
      'text': (LayoutElement e) => TextBuilder.build(
        e,
        ParseUtil.parseColor,
        ParseUtil.parseFontWeight,
        ParseUtil.parseTextAlign,
      ),
      'icon': (LayoutElement e) =>
          IconBuilder.build(e, ParseUtil.parseIconData, ParseUtil.parseColor),
      'card': (LayoutElement e) => CardBuilder.build(e, _buildWidget),
      'sizedbox': (LayoutElement e) => SizedBoxBuilder.build(e),
    };

    if (widget.layoutConfig != null) {
      _layoutConfig = widget.layoutConfig;
      _isLoading = false;
    } else {
      _loadLayoutConfig();
    }
  }

  @override
  void didUpdateWidget(DynamicLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layoutConfig != oldWidget.layoutConfig) {
      if (widget.layoutConfig != null) {
        setState(() {
          _layoutConfig = widget.layoutConfig;
          _isLoading = false;
          _error = null;
        });
      } else if (widget.configPath != oldWidget.configPath) {
        _loadLayoutConfig();
      }
    }
  }

  Future<void> _loadLayoutConfig() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final configPath =
          widget.configPath ?? 'assets/config/layout_config.json';
      final String jsonString = await rootBundle.loadString(configPath);
      final LayoutConfig config = LayoutConfig.fromJson(jsonString);

      setState(() {
        _layoutConfig = config;
        _isLoading = false;
      });
      debugPrint('Layout config loaded successfully from $configPath');
    } catch (e) {
      setState(() {
        _error = 'Failed to load layout config: $e';
        _isLoading = false;
      });
      debugPrint('Error loading layout config: $e');
    }
  }

  Widget _buildWidget(LayoutElement element) {
    if (element.type.toLowerCase() == 'custom_card') {
      final Widget? customWidget = _customCardFactory.createWidget(element);
      if (customWidget != null) {
        return customWidget;
      }
    }
    final Widget Function(LayoutElement p1)? builder =
        _widgetBuilders[element.type.toLowerCase()];
    if (builder != null) {
      return builder(element);
    }
    debugPrint('Unknown widget type: [${element.type}]');
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        'Unknown: [${element.type}]',
        style: const TextStyle(color: Colors.red),
      ),
    );
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
}

// New widget for Riverpod integration
class DynamicLayoutWidget extends StatelessWidget {
  final LayoutConfig layoutConfig;

  const DynamicLayoutWidget({super.key, required this.layoutConfig});

  @override
  Widget build(BuildContext context) {
    return DynamicLayout(layoutConfig: layoutConfig);
  }
}
