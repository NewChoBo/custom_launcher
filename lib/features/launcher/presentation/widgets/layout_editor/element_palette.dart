import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/draggable_layout_item.dart';

class ElementPalette extends StatefulWidget {
  final Function(String elementType)? onElementSelected;

  const ElementPalette({super.key, this.onElementSelected});

  @override
  State<ElementPalette> createState() => _ElementPaletteState();
}

class _ElementPaletteState extends State<ElementPalette> {
  final List<ElementTemplate> _elements = [
    const ElementTemplate(
      type: 'column',
      name: 'Column',
      description: 'Arranges children vertically',
      icon: Icons.view_column,
      color: Colors.blue,
    ),
    const ElementTemplate(
      type: 'row',
      name: 'Row',
      description: 'Arranges children horizontally',
      icon: Icons.view_stream,
      color: Colors.green,
    ),
    const ElementTemplate(
      type: 'expanded',
      name: 'Expanded',
      description: 'Expands child to fill space',
      icon: Icons.open_in_full,
      color: Colors.teal,
    ),
    const ElementTemplate(
      type: 'container',
      name: 'Container',
      description: 'A box with decoration',
      icon: Icons.crop_square,
      color: Colors.orange,
    ),
    const ElementTemplate(
      type: 'custom_card',
      name: 'App Card',
      description: 'Application launcher card',
      icon: Icons.rectangle,
      color: Colors.red,
    ),
    const ElementTemplate(
      type: 'text',
      name: 'Text',
      description: 'Display text content',
      icon: Icons.text_fields,
      color: Colors.purple,
    ),
    const ElementTemplate(
      type: 'sizedbox',
      name: 'Sized Box',
      description: 'Fixed size spacing',
      icon: Icons.crop_free,
      color: Colors.grey,
    ),
    const ElementTemplate(
      type: 'card',
      name: 'Card',
      description: 'Material design card',
      icon: Icons.credit_card,
      color: Colors.indigo,
    ),
  ];

  String? _selectedCategory;
  final List<String> _categories = ['Layout', 'Content', 'Interactive', 'All'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryFilter(),
        Expanded(child: _buildElementList()),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.widgets, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Element Palette',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildElementList() {
    final filteredElements = _getFilteredElements();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredElements.length,
      itemBuilder: (context, index) {
        final element = filteredElements[index];
        return _buildElementTile(element);
      },
    );
  }

  Widget _buildElementTile(ElementTemplate element) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Draggable<LayoutElementDragData>(
        data: LayoutElementDragData(
          element: _createDefaultElement(element.type),
          sourcePath: 'palette',
        ),
        feedback: _buildDragFeedback(element),
        childWhenDragging: _buildChildWhenDragging(element),
        child: _buildElementCard(element),
      ),
    );
  }

  LayoutElement _createDefaultElement(String elementType) {
    switch (elementType) {
      case 'column':
        return const LayoutElement(
          type: 'column',
          properties: {
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'start',
            'spacing': 8.0,
          },
          children: [],
        );
      case 'row':
        return const LayoutElement(
          type: 'row',
          properties: {
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'start',
            'spacing': 8.0,
          },
          children: [],
        );
      case 'expanded':
        return const LayoutElement(type: 'expanded', properties: {'flex': 1});
      case 'container':
        return const LayoutElement(
          type: 'container',
          properties: {'padding': 8.0, 'color': '#F5F5F5', 'borderRadius': 8.0},
        );
      case 'custom_card':
        return const LayoutElement(
          type: 'custom_card',
          properties: {'app_id': 'sample_app', 'app_name': 'Sample App'},
        );
      case 'text':
        return const LayoutElement(
          type: 'text',
          properties: {'text': 'Sample Text', 'fontSize': 16.0},
        );
      case 'sizedbox':
        return const LayoutElement(
          type: 'sizedbox',
          properties: {'width': 100.0, 'height': 50.0},
        );
      case 'card':
        return const LayoutElement(
          type: 'card',
          properties: {'elevation': 4.0},
        );
      default:
        return LayoutElement(type: elementType, properties: {});
    }
  }

  Widget _buildElementCard(ElementTemplate element) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => widget.onElementSelected?.call(element.type),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: element.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(element.icon, color: element.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          element.name,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          element.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  element.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragFeedback(ElementTemplate element) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: element.color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(element.icon, color: element.color, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    element.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'New ${element.type}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildWhenDragging(ElementTemplate element) {
    return Card(
      elevation: 1,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: element.color,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                element.icon,
                color: element.color.withValues(alpha: 0.7),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  element.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Drag elements to add them to your layout',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              _showElementTemplates();
            },
            icon: const Icon(Icons.library_add),
            label: const Text('Templates'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
            ),
          ),
        ],
      ),
    );
  }

  List<ElementTemplate> _getFilteredElements() {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return _elements;
    }

    switch (_selectedCategory) {
      case 'Layout':
        return _elements
            .where(
              (e) => [
                'column',
                'row',
                'expanded',
                'container',
                'sizedbox',
              ].contains(e.type),
            )
            .toList();
      case 'Content':
        return _elements
            .where((e) => ['text', 'custom_card', 'card'].contains(e.type))
            .toList();
      case 'Interactive':
        return _elements
            .where((e) => ['custom_card'].contains(e.type))
            .toList();
      default:
        return _elements;
    }
  }

  void _showElementTemplates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Element Templates'),
        content: const Text('Pre-built element templates coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ElementTemplate {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const ElementTemplate({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
