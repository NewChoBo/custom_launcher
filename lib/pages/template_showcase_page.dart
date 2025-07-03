import 'package:flutter/material.dart';
import 'package:custom_launcher/models/launcher_template.dart';
import 'package:custom_launcher/services/launcher_template_service.dart';
import 'package:custom_launcher/widgets/templates/card_launcher_template.dart';
import 'package:custom_launcher/widgets/templates/icon_launcher_template.dart';
import 'package:custom_launcher/widgets/templates/list_launcher_template.dart';

/// Template showcase page to demonstrate different launcher templates
class TemplateShowcasePage extends StatelessWidget {
  const TemplateShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Launcher Templates Showcase'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        centerTitle: true,
      ),
      body: const SingleChildScrollView(child: _TemplateShowcaseContent()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateInfo(context),
        icon: const Icon(Icons.info_outline),
        label: const Text('Template Info'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Show template information dialog
  void _showTemplateInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: <Widget>[
              Icon(Icons.palette, color: Colors.blue),
              SizedBox(width: 8),
              Text('Template System'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Available Template Types:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 12),
                _TemplateTypeInfo(
                  type: 'Card Templates',
                  description: 'Icon and text in vertical layout',
                  examples: <String>[
                    'Default Card',
                    'Compact Card',
                    'Large Card',
                  ],
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                _TemplateTypeInfo(
                  type: 'Icon Templates',
                  description: 'Icon-only with hover effects',
                  examples: <String>['Simple Icon', 'Small Icon', 'Large Icon'],
                  color: Colors.purple,
                ),
                SizedBox(height: 16),
                _TemplateTypeInfo(
                  type: 'List Templates',
                  description: 'Icon and text in horizontal layout',
                  examples: <String>[
                    'List Item',
                    'Detailed List',
                    'Compact List',
                  ],
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text('• JSON-based configuration'),
                Text('• Customizable styles and colors'),
                Text('• Responsive design'),
                Text('• Hover effects and animations'),
                Text('• Error handling and fallbacks'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

/// Widget to display template type information
class _TemplateTypeInfo extends StatelessWidget {
  final String type;
  final String description;
  final List<String> examples;
  final Color color;

  const _TemplateTypeInfo({
    required this.type,
    required this.description,
    required this.examples,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.category, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            children: examples.map((String example) {
              return Chip(
                label: Text(example, style: const TextStyle(fontSize: 10)),
                backgroundColor: color.withValues(alpha: 0.2),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Template showcase content widget using actual template widgets
class _TemplateShowcaseContent extends StatefulWidget {
  const _TemplateShowcaseContent();

  @override
  State<_TemplateShowcaseContent> createState() =>
      _TemplateShowcaseContentState();
}

class _TemplateShowcaseContentState extends State<_TemplateShowcaseContent> {
  List<LauncherTemplate> templates = <LauncherTemplate>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      await LauncherTemplateService.instance.initialize();
      setState(() {
        templates = LauncherTemplateService.instance.templates;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading templates: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
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
              'Custom Launcher - Real Templates Demo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Card Templates
          _buildTemplateSection(
            'Card Templates',
            Colors.orange,
            templates
                .where(
                  (LauncherTemplate t) => t.type == LauncherTemplateType.card,
                )
                .toList(),
            <LauncherItem>[
              _createLauncherItem('notepad.exe', 'Notepad', 'file'),
              _createLauncherItem('calc.exe', 'Calculator', 'calculator'),
              _createLauncherItem('chrome.exe', 'Chrome', 'browser'),
            ],
          ),

          const SizedBox(height: 16),

          // Icon Templates
          _buildTemplateSection(
            'Icon Templates',
            Colors.purple,
            templates
                .where(
                  (LauncherTemplate t) => t.type == LauncherTemplateType.icon,
                )
                .toList(),
            <LauncherItem>[
              _createLauncherItem('cmd.exe', 'CMD', 'terminal'),
              _createLauncherItem('explorer.exe', 'Explorer', 'folder'),
              _createLauncherItem('winver.exe', 'System', 'settings'),
            ],
          ),

          const SizedBox(height: 16),

          // List Templates
          _buildTemplateSection(
            'List Templates',
            Colors.green,
            templates
                .where(
                  (LauncherTemplate t) => t.type == LauncherTemplateType.list,
                )
                .toList(),
            <LauncherItem>[
              _createLauncherItem('mspaint.exe', 'Paint', 'image'),
              _createLauncherItem('msedge.exe', 'Edge', 'browser'),
              _createLauncherItem(
                'code.exe',
                'VS Code',
                'code',
                description: 'Source code editor',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateSection(
    String title,
    Color color,
    List<LauncherTemplate> sectionTemplates,
    List<LauncherItem> items,
  ) {
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

          // Create template widgets
          if (sectionTemplates.isNotEmpty && items.isNotEmpty)
            _buildTemplateWidgets(sectionTemplates, items)
          else
            const Text('No templates available'),
        ],
      ),
    );
  }

  Widget _buildTemplateWidgets(
    List<LauncherTemplate> templateList,
    List<LauncherItem> items,
  ) {
    final List<Widget> widgets = <Widget>[];

    for (int i = 0; i < templateList.length && i < items.length; i++) {
      final LauncherTemplate template = templateList[i];
      final LauncherItem item = items[i];

      Widget templateWidget;

      switch (template.type) {
        case LauncherTemplateType.card:
          templateWidget = CardLauncherTemplate(item: item, template: template);
          break;
        case LauncherTemplateType.icon:
          templateWidget = IconLauncherTemplate(item: item, template: template);
          break;
        case LauncherTemplateType.list:
          templateWidget = ListLauncherTemplate(item: item, template: template);
          break;
        case LauncherTemplateType.tile:
          templateWidget = ListLauncherTemplate(item: item, template: template);
          break;
      }

      widgets.add(templateWidget);
    }

    return templateList.isNotEmpty &&
            templateList.first.type == LauncherTemplateType.list
        ? Column(children: widgets)
        : Wrap(spacing: 16, runSpacing: 16, children: widgets);
  }

  LauncherItem _createLauncherItem(
    String appName,
    String displayName,
    String icon, {
    String? description,
  }) {
    return LauncherItem(
      appName: appName,
      displayName: displayName,
      icon: icon,
      metadata: description != null
          ? <String, dynamic>{'description': description}
          : null,
    );
  }
}
