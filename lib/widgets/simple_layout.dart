import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:custom_launcher/models/layout_config.dart';
import 'package:custom_launcher/widgets/simple_launcher_widget.dart';

/// Simplified dynamic layout widget
class SimpleLayout extends StatefulWidget {
  final String configPath;

  const SimpleLayout({
    super.key,
    this.configPath = 'assets/config/layout_config.json',
  });

  @override
  State<SimpleLayout> createState() => _SimpleLayoutState();
}

class _SimpleLayoutState extends State<SimpleLayout> {
  LayoutConfig? _config;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final String json = await rootBundle.loadString(widget.configPath);
      _config = LayoutConfig.fromJson(json);
      _loading = false;
      setState(() {});
    } catch (e) {
      _error = e.toString();
      _loading = false;
      setState(() {});
    }
  }

  Widget _buildWidget(LayoutElement element) {
    switch (element.type.toLowerCase()) {
      case 'column':
        return Column(
          mainAxisAlignment: _parseMainAxis(
            element.getProperty('mainAxisAlignment'),
          ),
          crossAxisAlignment: _parseCrossAxis(
            element.getProperty('crossAxisAlignment'),
          ),
          children: element.children?.map(_buildWidget).toList() ?? <Widget>[],
        );

      case 'row':
        return Row(
          mainAxisAlignment: _parseMainAxis(
            element.getProperty('mainAxisAlignment'),
          ),
          crossAxisAlignment: _parseCrossAxis(
            element.getProperty('crossAxisAlignment'),
          ),
          children: element.children?.map(_buildWidget).toList() ?? <Widget>[],
        );

      case 'container':
        return Container(
          width: _parseSize(element.getProperty('width')),
          height: _parseSize(element.getProperty('height')),
          padding: _parsePadding(element.getProperty('padding')),
          decoration: _parseDecoration(element.getProperty('decoration')),
          child: element.child != null ? _buildWidget(element.child!) : null,
        );

      case 'text':
        return Text(
          element.getProperty('text') ?? '',
          style: _parseTextStyle(element.getProperty('style')),
          textAlign: _parseTextAlign(element.getProperty('textAlign')),
        );

      case 'sizedbox':
        return SizedBox(
          width: _parseSize(element.getProperty('width')),
          height: _parseSize(element.getProperty('height')),
        );

      case 'launcher':
        return LauncherWidget(
          appName: element.getProperty('appName') ?? '',
          displayName: element.getProperty('displayName') ?? '',
          icon: element.getProperty('icon') ?? 'apps',
          width: _parseSize(element.getProperty('width')) ?? 80,
          height: _parseSize(element.getProperty('height')) ?? 80,
          style: element.getProperty('style'),
        );

      case 'icon':
        return Icon(
          _parseIconData(element.getProperty('icon') ?? 'help'),
          size: element.getProperty('size')?.toDouble() ?? 24,
          color: _parseColor(element.getProperty('color')),
        );

      case 'card':
        return Card(
          elevation: element.getProperty('elevation')?.toDouble() ?? 1,
          child: element.child != null ? _buildWidget(element.child!) : null,
        );

      default:
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.red.withValues(alpha: 0.3),
          child: Text('Unknown: ${element.type}'),
        );
    }
  }

  MainAxisAlignment _parseMainAxis(String? value) {
    switch (value) {
      case 'center':
        return MainAxisAlignment.center;
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      default:
        return MainAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxis(String? value) {
    switch (value) {
      case 'center':
        return CrossAxisAlignment.center;
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  double? _parseSize(dynamic value) {
    if (value == null) return null;
    if (value == 'fill') return double.infinity;
    if (value is num) return value.toDouble();
    return null;
  }

  EdgeInsets? _parsePadding(Map<String, dynamic>? padding) {
    if (padding == null) return null;
    if (padding['all'] != null) {
      return EdgeInsets.all(padding['all'].toDouble());
    }
    return EdgeInsets.only(
      top: padding['top']?.toDouble() ?? 0,
      bottom: padding['bottom']?.toDouble() ?? 0,
      left: padding['left']?.toDouble() ?? 0,
      right: padding['right']?.toDouble() ?? 0,
    );
  }

  BoxDecoration? _parseDecoration(Map<String, dynamic>? decoration) {
    if (decoration == null) return null;
    return BoxDecoration(
      color: decoration['color'] != null
          ? _parseColor(decoration['color'])
          : null,
      borderRadius: decoration['borderRadius'] != null
          ? BorderRadius.circular(decoration['borderRadius'].toDouble())
          : null,
    );
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null) return null;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  TextStyle? _parseTextStyle(Map<String, dynamic>? style) {
    if (style == null) return null;
    return TextStyle(
      fontSize: style['fontSize']?.toDouble(),
      fontWeight: _parseFontWeight(style['fontWeight']),
      color: _parseColor(style['color']),
    );
  }

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
        return FontWeight.normal;
    }
  }

  TextAlign? _parseTextAlign(String? align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'left':
        return TextAlign.left;
      case 'right':
        return TextAlign.right;
      default:
        return null;
    }
  }

  IconData _parseIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'calculate':
        return Icons.calculate;
      case 'web':
        return Icons.web;
      case 'games':
        return Icons.games;
      case 'edit_note':
        return Icons.edit_note;
      case 'folder_open':
        return Icons.folder_open;
      case 'code':
        return Icons.code;
      case 'chat':
        return Icons.chat;
      case 'music_note':
        return Icons.music_note;
      case 'help':
        return Icons.help;
      case 'star':
        return Icons.star;
      case 'favorite':
        return Icons.favorite;
      case 'settings':
        return Icons.settings;
      case 'home':
        return Icons.home;
      default:
        return Icons.apps;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    if (_config == null) {
      return const Center(child: Text('No config'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: _buildWidget(_config!.layout),
    );
  }
}
