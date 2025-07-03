import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';
import 'package:custom_launcher/pages/template_showcase_page.dart';

/// Home page widget for Custom Launcher
/// Displays main UI with system tray information
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.title,
    required this.onHideToTray,
    required this.settings,
  });

  final String title;
  final Future<void> Function() onHideToTray;
  final AppSettings settings;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Navigate to template showcase page
  void _navigateToTemplateShowcase(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TemplateShowcasePage(),
      ),
    );
  }

  /// Parse hex color string with opacity
  /// Returns null for invalid colors (will use defaults)
  Color? _parseColor(String hexString, double opacity) {
    try {
      if (hexString.isEmpty) return null;

      String hex = hexString.replaceFirst('#', '');
      if (!RegExp(r'^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$').hasMatch(hex)) {
        debugPrint('Invalid hex format: $hexString');
        return null;
      }

      // Handle RGB and RGBA formats
      if (hex.length == 6) {
        hex = 'FF$hex'; // Add full alpha for RGB
      }

      final Color baseColor = Color(int.parse(hex, radix: 16));

      // Apply the opacity setting directly (ignore hex alpha)
      final Color finalColor = baseColor.withValues(alpha: opacity);

      debugPrint(
        'Parsing $hexString -> Base: ${baseColor.toString()}, Final: ${finalColor.toString()} (opacity: $opacity)',
      );

      return finalColor;
    } catch (e) {
      debugPrint('Error parsing color "$hexString": $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        _parseColor(
          widget.settings.backgroundColor,
          widget.settings.backgroundOpacity,
        ) ??
        Colors.transparent;

    final Color? appBarColor = _parseColor(
      widget.settings.appBarColor,
      widget.settings.appBarOpacity,
    );

    debugPrint(
      'Background: ${widget.settings.backgroundColor} -> $backgroundColor',
    );
    debugPrint('AppBar: ${widget.settings.appBarColor} -> $appBarColor');

    return Scaffold(
      appBar: widget.settings.showAppBar
          ? AppBar(
              backgroundColor:
                  appBarColor ??
                  Theme.of(context).colorScheme.inversePrimary.withValues(
                    alpha: widget.settings.appBarOpacity,
                  ),
              title: Text(widget.title),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(Icons.palette),
                  onPressed: () => _navigateToTemplateShowcase(context),
                  tooltip: 'Template Showcase',
                ),
                IconButton(
                  icon: const Icon(Icons.minimize),
                  onPressed: widget.onHideToTray,
                  tooltip: 'Hide to System Tray',
                ),
              ],
            )
          : null,
      backgroundColor: backgroundColor,
      body: const _TemplateDemo(),
    );
  }
}

/// Simple template demo widget without using DynamicLayout
class _TemplateDemo extends StatelessWidget {
  const _TemplateDemo();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Custom Launcher - Templates Demo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Card Templates Section
          _buildSection('Card Templates', Colors.orange, <Widget>[
            _buildTemplateWidget(
              'default_card',
              'notepad.exe',
              'Notepad',
              'file',
            ),
            _buildTemplateWidget(
              'compact_card',
              'calc.exe',
              'Calculator',
              'calculator',
            ),
            _buildTemplateWidget(
              'large_card',
              'chrome.exe',
              'Chrome',
              'browser',
            ),
          ], isWrap: true),
          const SizedBox(height: 16),

          // Icon Templates Section
          _buildSection('Icon Templates', Colors.purple, <Widget>[
            _buildTemplateWidget('small_icon', 'cmd.exe', 'CMD', 'terminal'),
            _buildTemplateWidget(
              'simple_icon',
              'explorer.exe',
              'Explorer',
              'folder',
            ),
            _buildTemplateWidget(
              'large_icon',
              'winver.exe',
              'System',
              'settings',
            ),
          ], isWrap: true),
          const SizedBox(height: 16),

          // List Templates Section
          _buildSection('List Templates', Colors.green, <Widget>[
            _buildTemplateWidget(
              'compact_list',
              'mspaint.exe',
              'Paint',
              'image',
            ),
            _buildTemplateWidget('list_item', 'msedge.exe', 'Edge', 'browser'),
            _buildTemplateWidget(
              'detailed_list',
              'code.exe',
              'VS Code',
              'code',
            ),
          ], isWrap: false),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    Color color,
    List<Widget> children, {
    required bool isWrap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          if (isWrap)
            Wrap(spacing: 16, runSpacing: 16, children: children)
          else
            Column(children: children),
        ],
      ),
    );
  }

  Widget _buildTemplateWidget(
    String templateId,
    String appName,
    String displayName,
    String icon,
  ) {
    // For now, return a simple placeholder since we need the actual template service
    return Container(
      width: templateId.contains('card')
          ? 120
          : (templateId.contains('list') ? 200 : 60),
      height: templateId.contains('card')
          ? 120
          : (templateId.contains('list') ? 60 : 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            _getIcon(icon),
            size: templateId.contains('large')
                ? 48
                : (templateId.contains('small') ? 24 : 32),
            color: Colors.blue,
          ),
          if (!templateId.contains('icon'))
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                displayName,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'file':
        return Icons.insert_drive_file;
      case 'calculator':
        return Icons.calculate;
      case 'browser':
        return Icons.language;
      case 'terminal':
        return Icons.terminal;
      case 'folder':
        return Icons.folder;
      case 'settings':
        return Icons.settings;
      case 'image':
        return Icons.image;
      case 'code':
        return Icons.code;
      default:
        return Icons.apps;
    }
  }
}
