import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/element_palette.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/draggable_layout_item.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'dart:async'; // Added for Timer

class VisualLayoutEditor extends ConsumerStatefulWidget {
  final LayoutConfig initialConfig;
  final Function(LayoutConfig config)? onLayoutChanged;

  const VisualLayoutEditor({
    super.key,
    required this.initialConfig,
    this.onLayoutChanged,
  });

  @override
  ConsumerState<VisualLayoutEditor> createState() => _VisualLayoutEditorState();
}

class _VisualLayoutEditorState extends ConsumerState<VisualLayoutEditor> {
  late LayoutConfig _currentConfig;
  bool _isEditMode = true;
  String? _selectedElementPath;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig;
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToolbar(),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: ElementPalette(onElementSelected: _addNewElement),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: _buildEditableLayout(),
                ),
              ),
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: _buildPropertiesPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Visual Layout Editor',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ToggleButtons(
            isSelected: [_isEditMode, !_isEditMode],
            onPressed: (index) {
              setState(() {
                _isEditMode = index == 0;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text('Preview'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _saveLayout,
            icon: const Icon(Icons.save),
            label: const Text('Save Layout'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _resetLayout,
            icon: const Icon(Icons.restore),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableLayout() {
    if (!_isEditMode) {
      return _buildPreviewLayout(_currentConfig.layout);
    }

    return LayoutDropTarget(
      targetPath: 'root',
      onAccept: _handleElementDrop,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildEditableElement(
            element: _currentConfig.layout,
            path: 'root',
          ),
        ),
      ),
    );
  }

  Widget _buildEditableElement({
    required LayoutElement element,
    required String path,
  }) {
    final isSelected = _selectedElementPath == path;

    Widget child = _buildLayoutWidget(element, path);

    if (_isEditMode && path != 'root') {
      child = DraggableLayoutItem(
        element: element,
        elementPath: path,
        isSelected: isSelected,
        onElementSelected: (elementPath) {
          setState(() {
            _selectedElementPath = elementPath;
          });
        },
        onElementDeleted: _deleteElement,
        onElementMoved: _moveElement,
        child: child,
      );
    }

    return child;
  }

  Widget _buildLayoutWidget(LayoutElement element, String path) {
    switch (element.type) {
      case 'column':
        return _buildColumnWidget(element, path);
      case 'row':
        return _buildRowWidget(element, path);
      case 'expanded':
        return _buildExpandedWidget(element, path);
      case 'container':
        return _buildContainerWidget(element, path);
      case 'custom_card':
        return _buildCustomCardWidget(element, path);
      case 'text':
        return _buildTextWidget(element, path);
      case 'sizedbox':
        return _buildSizedBoxWidget(element, path);
      default:
        return _buildPlaceholderWidget(element, path);
    }
  }

  Widget _buildColumnWidget(LayoutElement element, String path) {
    final children = element.children ?? [];
    final spacing = element.getProperty<double>('spacing', 0.0);
    final isSelected = _selectedElementPath == path;

    return LayoutDropTarget(
      targetPath: path,
      onAccept: _handleElementDrop,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.blue.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.withValues(alpha: isSelected ? 0.1 : 0.05),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_column, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Column',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (children.isEmpty)
              _buildEmptyDropZone('Drop elements here')
            else
              ...children.asMap().entries.map((entry) {
                final index = entry.key;
                final child = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < children.length - 1
                        ? (spacing ?? 0.0)
                        : 0.0,
                  ),
                  child: _buildEditableElement(
                    element: child,
                    path: '$path.children[$index]',
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRowWidget(LayoutElement element, String path) {
    final children = element.children ?? [];
    final spacing = element.getProperty<double>('spacing', 0.0);
    final isSelected = _selectedElementPath == path;

    return LayoutDropTarget(
      targetPath: path,
      onAccept: _handleElementDrop,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.green.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.green.withValues(alpha: isSelected ? 0.1 : 0.05),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_stream, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Row',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (children.isEmpty)
              _buildEmptyDropZone('Drop elements here')
            else
              Row(
                children: children.asMap().entries.map((entry) {
                  final index = entry.key;
                  final child = entry.value;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index < children.length - 1
                            ? (spacing ?? 0.0)
                            : 0.0,
                      ),
                      child: _buildEditableElement(
                        element: child,
                        path: '$path.children[$index]',
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedWidget(LayoutElement element, String path) {
    final flex = element.getProperty<int>('flex', 1);
    final child = element.child;
    final isSelected = _selectedElementPath == path;

    return LayoutDropTarget(
      targetPath: path,
      onAccept: _handleElementDrop,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.teal.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.teal.withValues(alpha: isSelected ? 0.1 : 0.05),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_in_full, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Expanded (flex: $flex)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (child == null)
              _buildEmptyDropZone('Drop element here')
            else
              _buildEditableElement(element: child, path: '$path.child'),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerWidget(LayoutElement element, String path) {
    final child = element.child;
    final isSelected = _selectedElementPath == path;

    return LayoutDropTarget(
      targetPath: path,
      onAccept: _handleElementDrop,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.orange.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.orange.withValues(alpha: isSelected ? 0.1 : 0.05),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.crop_square, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Container',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (child == null)
              _buildEmptyDropZone('Drop element here')
            else
              _buildEditableElement(element: child, path: '$path.child'),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomCardWidget(LayoutElement element, String path) {
    final appId = element.getProperty<String>('app_id', '') ?? '';
    final appName = element.getProperty<String>('app_name', '') ?? '';
    final isSelected = _selectedElementPath == path;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.red.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.withValues(alpha: isSelected ? 0.1 : 0.05),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.apps, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'App Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.apps, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appName.isNotEmpty ? appName : 'App Name',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (appId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'ID: $appId',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextWidget(LayoutElement element, String path) {
    final text = element.getProperty<String>('text', 'Text') ?? 'Text';
    final isSelected = _selectedElementPath == path;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.purple.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple.withValues(alpha: isSelected ? 0.1 : 0.05),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.text_fields, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  'Text',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildSizedBoxWidget(LayoutElement element, String path) {
    final width = element.getProperty<double>('width', 0.0);
    final height = element.getProperty<double>('height', 0.0);
    final isSelected = _selectedElementPath == path;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withValues(alpha: isSelected ? 0.1 : 0.05),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.crop_free, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'SizedBox (${width}x${height})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(
              minWidth: 50,
              maxWidth: 300,
              minHeight: 30,
              maxHeight: 200,
            ),
            width: width != null && width > 0 ? width.clamp(50, 300) : 100,
            height: height != null && height > 0 ? height.clamp(30, 200) : 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                style: BorderStyle.solid,
              ),
            ),
            child: Center(
              child: Text(
                '${width?.toInt() ?? 0}x${height?.toInt() ?? 0}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderWidget(LayoutElement element, String path) {
    final isSelected = _selectedElementPath == path;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.withValues(alpha: 0.3),
          width: isSelected ? 2 : 1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.withValues(alpha: isSelected ? 0.1 : 0.05),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.help_outline, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Unknown (${element.type})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Text(
              'Unknown element type: ${element.type}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewLayout(LayoutElement element) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          'Preview Mode\n(Coming Soon)',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildPropertiesPanel() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Properties',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_selectedElementPath != null) ...[
              _buildElementProperties(),
            ] else ...[
              Text(
                'Select an element to view properties',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildElementProperties() {
    final element = _getElementByPath(_selectedElementPath!);
    if (element == null) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Type: ${element.type}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Path: $_selectedElementPath',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Properties:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._buildEditableProperties(element),
      ],
    );
  }

  List<Widget> _buildEditableProperties(LayoutElement element) {
    final List<Widget> propertyWidgets = [];
    final Map<String, dynamic> properties = element.properties ?? {};

    // Type-specific property editors
    switch (element.type) {
      case 'expanded':
        propertyWidgets.add(_buildFlexEditor(properties));
        break;
      case 'custom_card':
        propertyWidgets.add(_buildAppIdEditor(properties));
        propertyWidgets.add(_buildAppNameEditor(properties));
        break;
      case 'text':
        propertyWidgets.add(_buildTextEditor(properties));
        propertyWidgets.add(_buildFontSizeEditor(properties));
        break;
      case 'sizedbox':
        propertyWidgets.add(_buildWidthEditor(properties));
        propertyWidgets.add(_buildHeightEditor(properties));
        break;
      case 'container':
        propertyWidgets.add(_buildWidthEditor(properties));
        propertyWidgets.add(_buildHeightEditor(properties));
        propertyWidgets.add(_buildPaddingEditor(properties));
        propertyWidgets.add(_buildColorEditor(properties));
        propertyWidgets.add(_buildBorderRadiusEditor(properties));
        break;
      case 'column':
      case 'row':
        propertyWidgets.add(_buildSpacingEditor(properties));
        propertyWidgets.add(_buildMainAxisAlignmentEditor(properties));
        propertyWidgets.add(_buildCrossAxisAlignmentEditor(properties));
        break;
    }

    // Common properties for all elements
    if (properties.isNotEmpty) {
      propertyWidgets.add(const SizedBox(height: 16));
      propertyWidgets.add(
        Text(
          'All Properties:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      );
      propertyWidgets.add(const SizedBox(height: 8));

      // Show read-only view of all properties
      for (final entry in properties.entries) {
        propertyWidgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return propertyWidgets;
  }

  Widget _buildFlexEditor(Map<String, dynamic> properties) {
    final int currentFlex = properties['flex'] as int? ?? 1;

    return _buildPropertyCard(
      'Flex',
      Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: currentFlex.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: currentFlex.toString(),
                  onChanged: (value) {
                    _updateElementProperty('flex', value.toInt());
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Text(
                  currentFlex.toString(),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppIdEditor(Map<String, dynamic> properties) {
    final String currentAppId = properties['app_id'] as String? ?? '';

    return _buildPropertyCard(
      'App ID',
      Consumer(
        builder: (context, ref, child) {
          final appListAsync = ref.watch(appListNotifierProvider);

          return appListAsync.when(
            data: (apps) {
              // 현재 선택된 앱 ID가 목록에 있는지 확인
              String? selectedValue = currentAppId;
              if (selectedValue.isNotEmpty &&
                  !apps.any((app) => app.id == selectedValue)) {
                selectedValue = null;
              }

              // 현재 선택된 앱 찾기
              final selectedApp = apps.cast<dynamic>().firstWhere(
                (app) => app?.id == currentAppId,
                orElse: () => null,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 선택 드롭다운 (개선된 UI)
                  DropdownButtonFormField<String>(
                    value: selectedValue,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      hintText: 'Select an app',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    isExpanded: true,
                    menuMaxHeight: 300,
                    items: apps.map<DropdownMenuItem<String>>((app) {
                      return DropdownMenuItem<String>(
                        value: app.id,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              // 앱 아이콘
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                                child:
                                    app.imagePath != null &&
                                        app.imagePath!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.asset(
                                          app.imagePath!,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.apps,
                                                  size: 16,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(Icons.apps, size: 16),
                              ),
                              const SizedBox(width: 12),
                              // 앱 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      app.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (app.subtitle.isNotEmpty)
                                      Text(
                                        app.subtitle,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
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
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateElementProperty('app_id', value);
                      }
                    },
                  ),

                  // 선택된 앱 미리보기
                  if (selectedApp != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected App',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // 앱 아이콘
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                                child:
                                    selectedApp.imagePath != null &&
                                        selectedApp.imagePath!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          selectedApp.imagePath!,
                                          width: 36,
                                          height: 36,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Icon(
                                                  Icons.apps,
                                                  size: 20,
                                                );
                                              },
                                        ),
                                      )
                                    : const Icon(Icons.apps, size: 20),
                              ),
                              const SizedBox(width: 12),
                              // 앱 정보
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedApp.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    if (selectedApp.subtitle != null &&
                                        selectedApp.subtitle!.isNotEmpty)
                                      Text(
                                        selectedApp.subtitle!,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.7),
                                            ),
                                      ),
                                    Text(
                                      'ID: ${selectedApp.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.5),
                                            fontFamily: 'monospace',
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Error loading apps: ${error.toString()}',
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppNameEditor(Map<String, dynamic> properties) {
    final String currentAppName = properties['app_name'] as String? ?? '';

    return _buildPropertyCard(
      'App Name',
      TextField(
        controller: TextEditingController(text: currentAppName),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Enter app name',
        ),
        onChanged: (value) {
          _updateElementProperty('app_name', value);
        },
      ),
    );
  }

  Widget _buildTextEditor(Map<String, dynamic> properties) {
    final String currentText = properties['text'] as String? ?? '';

    return _buildPropertyCard(
      'Text',
      TextField(
        controller: TextEditingController(text: currentText),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Enter text',
        ),
        maxLines: 3,
        onChanged: (value) {
          _updateElementProperty('text', value);
        },
      ),
    );
  }

  Widget _buildFontSizeEditor(Map<String, dynamic> properties) {
    final double currentFontSize =
        (properties['fontSize'] as num?)?.toDouble() ?? 16.0;

    return _buildPropertyCard(
      'Font Size',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentFontSize,
              min: 8,
              max: 48,
              divisions: 40,
              label: '${currentFontSize.toInt()}px',
              onChanged: (value) {
                _updateElementProperty('fontSize', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${currentFontSize.toInt()}px',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWidthEditor(Map<String, dynamic> properties) {
    final double currentWidth =
        (properties['width'] as num?)?.toDouble() ?? 100.0;

    return _buildPropertyCard(
      'Width',
      TextField(
        controller: TextEditingController(text: currentWidth.toString()),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Width (px)',
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final double? parsedValue = double.tryParse(value);
          if (parsedValue != null) {
            _updateElementProperty('width', parsedValue);
          }
        },
      ),
    );
  }

  Widget _buildHeightEditor(Map<String, dynamic> properties) {
    final double currentHeight =
        (properties['height'] as num?)?.toDouble() ?? 50.0;

    return _buildPropertyCard(
      'Height',
      TextField(
        controller: TextEditingController(text: currentHeight.toString()),
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
          hintText: 'Height (px)',
          suffixText: 'px',
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          final double? parsedValue = double.tryParse(value);
          if (parsedValue != null) {
            _updateElementProperty('height', parsedValue);
          }
        },
      ),
    );
  }

  Widget _buildPaddingEditor(Map<String, dynamic> properties) {
    final double currentPadding =
        (properties['padding'] as num?)?.toDouble() ?? 8.0;

    return _buildPropertyCard(
      'Padding',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentPadding,
              min: 0,
              max: 50,
              divisions: 50,
              label: '${currentPadding.toInt()}px',
              onChanged: (value) {
                _updateElementProperty('padding', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${currentPadding.toInt()}px',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorEditor(Map<String, dynamic> properties) {
    final String currentColor = properties['color'] as String? ?? '#F5F5F5';

    return _buildPropertyCard(
      'Color',
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: currentColor),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                hintText: '#RRGGBB',
              ),
              onChanged: (value) {
                _updateElementProperty('color', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _parseColor(currentColor) ?? Colors.grey,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBorderRadiusEditor(Map<String, dynamic> properties) {
    final double currentRadius =
        (properties['borderRadius'] as num?)?.toDouble() ?? 8.0;

    return _buildPropertyCard(
      'Border Radius',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentRadius,
              min: 0,
              max: 50,
              divisions: 50,
              label: '${currentRadius.toInt()}px',
              onChanged: (value) {
                _updateElementProperty('borderRadius', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${currentRadius.toInt()}px',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingEditor(Map<String, dynamic> properties) {
    final double currentSpacing =
        (properties['spacing'] as num?)?.toDouble() ?? 8.0;

    return _buildPropertyCard(
      'Spacing',
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentSpacing,
              min: 0,
              max: 50,
              divisions: 50,
              label: '${currentSpacing.toInt()}px',
              onChanged: (value) {
                _updateElementProperty('spacing', value);
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${currentSpacing.toInt()}px',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainAxisAlignmentEditor(Map<String, dynamic> properties) {
    final String currentAlignment =
        properties['mainAxisAlignment'] as String? ?? 'start';

    return _buildPropertyCard(
      'Main Axis Alignment',
      DropdownButtonFormField<String>(
        value: currentAlignment,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'start', child: Text('Start')),
          DropdownMenuItem(value: 'center', child: Text('Center')),
          DropdownMenuItem(value: 'end', child: Text('End')),
          DropdownMenuItem(value: 'spaceBetween', child: Text('Space Between')),
          DropdownMenuItem(value: 'spaceAround', child: Text('Space Around')),
          DropdownMenuItem(value: 'spaceEvenly', child: Text('Space Evenly')),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateElementProperty('mainAxisAlignment', value);
          }
        },
      ),
    );
  }

  Widget _buildCrossAxisAlignmentEditor(Map<String, dynamic> properties) {
    final String currentAlignment =
        properties['crossAxisAlignment'] as String? ?? 'start';

    return _buildPropertyCard(
      'Cross Axis Alignment',
      DropdownButtonFormField<String>(
        value: currentAlignment,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 'start', child: Text('Start')),
          DropdownMenuItem(value: 'center', child: Text('Center')),
          DropdownMenuItem(value: 'end', child: Text('End')),
          DropdownMenuItem(value: 'stretch', child: Text('Stretch')),
        ],
        onChanged: (value) {
          if (value != null) {
            _updateElementProperty('crossAxisAlignment', value);
          }
        },
      ),
    );
  }

  Widget _buildPropertyCard(String title, Widget child) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }

  void _updateElementProperty(String propertyKey, dynamic value) {
    final element = _getElementByPath(_selectedElementPath!);
    if (element == null) return;

    final updatedProperties = Map<String, dynamic>.from(
      element.properties ?? {},
    );
    updatedProperties[propertyKey] = value;

    final updatedElement = LayoutElement(
      type: element.type,
      properties: updatedProperties,
      children: element.children,
      child: element.child,
    );

    final newConfig = _updateElementInConfig(
      _selectedElementPath!,
      updatedElement,
    );

    // 상태 업데이트와 자동 저장을 분리
    if (mounted) {
      setState(() {
        _currentConfig = newConfig;
      });

      // Auto-save after a short delay to avoid too frequent saves
      _debounceAutoSave();
    }
  }

  Timer? _autoSaveTimer;

  void _debounceAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      // 위젯이 마운트되어 있을 때만 콜백 호출
      if (mounted) {
        widget.onLayoutChanged?.call(_currentConfig);
      }
    });
  }

  LayoutConfig _updateElementInConfig(
    String elementPath,
    LayoutElement newElement,
  ) {
    final pathParts = elementPath.split('.');
    pathParts.removeAt(0); // remove 'root'

    final updatedLayout = _updateElementRecursive(
      _currentConfig.layout,
      pathParts,
      newElement,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutElement _updateElementRecursive(
    LayoutElement element,
    List<String> pathParts,
    LayoutElement newElement,
  ) {
    if (pathParts.isEmpty) {
      return newElement;
    }

    final currentPart = pathParts.first;
    final remainingParts = pathParts.sublist(1);

    if (currentPart == 'child' && element.child != null) {
      final updatedChild = _updateElementRecursive(
        element.child!,
        remainingParts,
        newElement,
      );
      return LayoutElement(
        type: element.type,
        properties: element.properties,
        children: element.children,
        child: updatedChild,
      );
    } else if (currentPart.startsWith('children[') &&
        element.children != null) {
      final indexStr = currentPart.substring(9, currentPart.length - 1);
      final index = int.tryParse(indexStr);
      if (index != null && index >= 0 && index < element.children!.length) {
        final updatedChildren = List<LayoutElement>.from(element.children!);
        updatedChildren[index] = _updateElementRecursive(
          updatedChildren[index],
          remainingParts,
          newElement,
        );
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: updatedChildren,
          child: element.child,
        );
      }
    }

    return element;
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) return null;

    try {
      final hex = colorString.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return null;
    }
  }

  LayoutElement? _getElementByPath(String path) {
    if (path == 'root') {
      return _currentConfig.layout;
    }

    final pathParts = path.split('.');
    pathParts.removeAt(0); // 'root' 제거
    return _findElementRecursive(_currentConfig.layout, pathParts);
  }

  LayoutElement? _findElementRecursive(
    LayoutElement element,
    List<String> pathParts,
  ) {
    if (pathParts.isEmpty) {
      return element;
    }

    final currentPart = pathParts.first;
    final remainingParts = pathParts.sublist(1);

    if (currentPart == 'child' && element.child != null) {
      return _findElementRecursive(element.child!, remainingParts);
    } else if (currentPart.startsWith('children[') &&
        element.children != null) {
      final indexStr = currentPart.substring(9, currentPart.length - 1);
      final index = int.tryParse(indexStr);
      if (index != null && index >= 0 && index < element.children!.length) {
        return _findElementRecursive(element.children![index], remainingParts);
      }
    }

    return null;
  }

  Widget _buildEmptyDropZone(String message) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60, maxHeight: 120),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.outline,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event handlers
  void _handleElementDrop(
    LayoutElementDragData data,
    String targetPath,
    int index,
  ) {
    if (!mounted) return;

    final newConfig = data.sourcePath.isNotEmpty && data.sourcePath != 'palette'
        ? _moveElementInConfig(data.sourcePath, targetPath)
        : _addElementToConfig(data.element, targetPath);

    setState(() {
      _currentConfig = newConfig;
    });

    final actionType = data.sourcePath.isEmpty || data.sourcePath == 'palette'
        ? 'Added'
        : 'Moved';

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$actionType ${data.element.type} element'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _addNewElement(String elementType) {
    final element = _createDefaultElement(elementType);
    final data = LayoutElementDragData(element: element, sourcePath: 'palette');

    // 루트에 추가하거나 선택된 컨테이너에 추가
    final targetPath = _selectedElementPath ?? 'root';
    _handleElementDrop(data, targetPath, 0);
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
      default:
        return LayoutElement(type: elementType, properties: {});
    }
  }

  void _deleteElement(String elementPath) {
    if (!mounted) return;

    if (elementPath == 'root') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete root element'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final newConfig = _removeElementFromConfig(elementPath);

    setState(() {
      _currentConfig = newConfig;
      if (_selectedElementPath == elementPath) {
        _selectedElementPath = null;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Element deleted successfully'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _moveElement(String fromPath, String toPath, int toIndex) {
    if (!mounted) return;

    final newConfig = _moveElementInConfig(fromPath, toPath);

    setState(() {
      _currentConfig = newConfig;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Element moved to new position'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Layout manipulation helpers
  LayoutConfig _addElementToConfig(
    LayoutElement newElement,
    String targetPath,
  ) {
    if (targetPath == 'root') {
      // 루트 요소가 column이나 row인 경우 자식으로 추가
      if (_currentConfig.layout.type == 'column' ||
          _currentConfig.layout.type == 'row') {
        final updatedChildren = List<LayoutElement>.from(
          _currentConfig.layout.children ?? [],
        );
        updatedChildren.add(newElement);

        final updatedLayout = LayoutElement(
          type: _currentConfig.layout.type,
          properties: _currentConfig.layout.properties,
          children: updatedChildren,
          child: _currentConfig.layout.child,
        );

        return LayoutConfig(layout: updatedLayout);
      }
      // 루트 요소가 container나 expanded인 경우 child로 설정
      else if (_currentConfig.layout.type == 'container' ||
          _currentConfig.layout.type == 'expanded') {
        final updatedLayout = LayoutElement(
          type: _currentConfig.layout.type,
          properties: _currentConfig.layout.properties,
          children: _currentConfig.layout.children,
          child: newElement,
        );

        return LayoutConfig(layout: updatedLayout);
      }
      // 기타 경우에는 column으로 감싸기
      else {
        final wrappedLayout = LayoutElement(
          type: 'column',
          properties: const {
            'mainAxisAlignment': 'start',
            'crossAxisAlignment': 'start',
            'spacing': 8.0,
          },
          children: [_currentConfig.layout, newElement],
        );

        return LayoutConfig(layout: wrappedLayout);
      }
    }

    return _addElementAtPath(_currentConfig, targetPath, newElement);
  }

  LayoutConfig _removeElementFromConfig(String elementPath) {
    return _removeElementAtPath(_currentConfig, elementPath);
  }

  LayoutConfig _moveElementInConfig(String fromPath, String toPath) {
    // 먼저 요소를 제거하고
    final elementToMove = _getElementByPath(fromPath);
    if (elementToMove == null) return _currentConfig;

    var tempConfig = _removeElementFromConfig(fromPath);

    // 그 다음 새 위치에 추가
    return _addElementAtPath(tempConfig, toPath, elementToMove);
  }

  LayoutConfig _addElementAtPath(
    LayoutConfig config,
    String path,
    LayoutElement newElement,
  ) {
    final pathParts = path.split('.');
    pathParts.removeAt(0); // 'root' 제거
    final updatedLayout = _addElementRecursive(
      config.layout,
      pathParts,
      newElement,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutConfig _removeElementAtPath(LayoutConfig config, String path) {
    final pathParts = path.split('.');
    pathParts.removeAt(0); // 'root' 제거
    final updatedLayout = _removeElementRecursive(config.layout, pathParts);
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutElement _addElementRecursive(
    LayoutElement element,
    List<String> pathParts,
    LayoutElement newElement,
  ) {
    if (pathParts.isEmpty) {
      // 현재 요소에 추가
      if (element.type == 'column' || element.type == 'row') {
        final updatedChildren = List<LayoutElement>.from(
          element.children ?? [],
        );
        updatedChildren.add(newElement);

        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: updatedChildren,
          child: element.child,
        );
      } else if (element.type == 'container' || element.type == 'expanded') {
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: element.children,
          child: newElement,
        );
      }
    }

    if (pathParts.isNotEmpty) {
      final currentPart = pathParts.first;
      final remainingParts = pathParts.sublist(1);

      if (currentPart == 'child' && element.child != null) {
        final updatedChild = _addElementRecursive(
          element.child!,
          remainingParts,
          newElement,
        );
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: element.children,
          child: updatedChild,
        );
      } else if (currentPart == 'child' && element.child == null) {
        // 비어있는 child 슬롯에 추가
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: element.children,
          child: newElement,
        );
      } else if (currentPart.startsWith('children[') &&
          element.children != null) {
        final indexStr = currentPart.substring(9, currentPart.length - 1);
        final index = int.tryParse(indexStr);
        if (index != null && index >= 0 && index < element.children!.length) {
          final updatedChildren = List<LayoutElement>.from(element.children!);
          updatedChildren[index] = _addElementRecursive(
            updatedChildren[index],
            remainingParts,
            newElement,
          );
          return LayoutElement(
            type: element.type,
            properties: element.properties,
            children: updatedChildren,
            child: element.child,
          );
        }
      }
    }

    return element;
  }

  LayoutElement _removeElementRecursive(
    LayoutElement element,
    List<String> pathParts,
  ) {
    if (pathParts.length == 1) {
      final targetPart = pathParts.first;

      if (targetPart == 'child') {
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: element.children,
          child: null,
        );
      } else if (targetPart.startsWith('children[') &&
          element.children != null) {
        final indexStr = targetPart.substring(9, targetPart.length - 1);
        final index = int.tryParse(indexStr);
        if (index != null && index >= 0 && index < element.children!.length) {
          final updatedChildren = List<LayoutElement>.from(element.children!);
          updatedChildren.removeAt(index);
          return LayoutElement(
            type: element.type,
            properties: element.properties,
            children: updatedChildren,
            child: element.child,
          );
        }
      }
    } else if (pathParts.length > 1) {
      final currentPart = pathParts.first;
      final remainingParts = pathParts.sublist(1);

      if (currentPart == 'child' && element.child != null) {
        final updatedChild = _removeElementRecursive(
          element.child!,
          remainingParts,
        );
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: element.children,
          child: updatedChild,
        );
      } else if (currentPart.startsWith('children[') &&
          element.children != null) {
        final indexStr = currentPart.substring(9, currentPart.length - 1);
        final index = int.tryParse(indexStr);
        if (index != null && index >= 0 && index < element.children!.length) {
          final updatedChildren = List<LayoutElement>.from(element.children!);
          updatedChildren[index] = _removeElementRecursive(
            updatedChildren[index],
            remainingParts,
          );
          return LayoutElement(
            type: element.type,
            properties: element.properties,
            children: updatedChildren,
            child: element.child,
          );
        }
      }
    }

    return element;
  }

  void _saveLayout() {
    // 레이아웃 저장
    widget.onLayoutChanged?.call(_currentConfig);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Layout saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetLayout() {
    setState(() {
      _currentConfig = widget.initialConfig;
      _selectedElementPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Layout reset to initial state'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
