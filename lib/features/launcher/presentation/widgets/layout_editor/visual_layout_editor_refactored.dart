import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/element_palette.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/components/layout_editor_toolbar.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/components/layout_properties_panel.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/components/layout_canvas.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/components/layout_operations.dart';

import 'dart:async';

class VisualLayoutEditorRefactored extends ConsumerStatefulWidget {
  final LayoutConfig initialConfig;
  final Function(LayoutConfig config)? onLayoutChanged;

  const VisualLayoutEditorRefactored({
    super.key,
    required this.initialConfig,
    this.onLayoutChanged,
  });

  @override
  ConsumerState<VisualLayoutEditorRefactored> createState() =>
      _VisualLayoutEditorRefactoredState();
}

class _VisualLayoutEditorRefactoredState
    extends ConsumerState<VisualLayoutEditorRefactored> {
  late LayoutConfig _currentConfig;
  bool _isEditMode = true;
  String? _selectedElementPath;
  Timer? _autoSaveTimer;

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
        // Toolbar
        LayoutEditorToolbar(
          isEditMode: _isEditMode,
          onEditModeToggle: () => setState(() => _isEditMode = true),
          onPreviewModeToggle: () => setState(() => _isEditMode = false),
          onSaveLayout: _saveLayout,
          onResetLayout: _resetLayout,
        ),
        // Main Content
        Expanded(
          child: Row(
            children: [
              // Element Palette (왼쪽)
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
              // Main Layout Area (가운데)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: LayoutCanvas(
                    isEditMode: _isEditMode,
                    layoutConfig: _currentConfig,
                    selectedElementPath: _selectedElementPath,
                    onElementSelected: _onElementSelected,
                    onElementDeleted: _deleteElement,
                    onElementMoved: _moveElement,
                    onElementDrop: _handleElementDrop,
                    layoutWidgetBuilder: _buildLayoutWidget,
                  ),
                ),
              ),
              // Properties Panel (오른쪽)
              Container(
                width: 280,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
                child: LayoutPropertiesPanel(
                  selectedElementPath: _selectedElementPath,
                  selectedElement: _getSelectedElement(),
                  onPropertyUpdate: _updateElementProperty,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onElementSelected(String elementPath) {
    setState(() {
      _selectedElementPath = elementPath;
    });
  }

  void _addNewElement(String elementType) {
    final newElement = _createDefaultElement(elementType);
    final targetPath = _selectedElementPath ?? 'root';

    setState(() {
      _currentConfig = LayoutOperations.addElement(
        _currentConfig,
        targetPath,
        newElement,
      );
    });

    _debounceAutoSave();
  }

  void _deleteElement(String elementPath) {
    setState(() {
      _currentConfig = LayoutOperations.removeElement(
        _currentConfig,
        elementPath,
      );
      if (_selectedElementPath == elementPath) {
        _selectedElementPath = null;
      }
    });

    _debounceAutoSave();
  }

  void _moveElement(String fromPath, String toPath, int? insertIndex) {
    setState(() {
      _currentConfig = LayoutOperations.moveElement(
        _currentConfig,
        fromPath,
        toPath,
      );
    });

    _debounceAutoSave();
  }

  void _handleElementDrop(String targetPath, LayoutElement droppedElement) {
    setState(() {
      _currentConfig = LayoutOperations.addElement(
        _currentConfig,
        targetPath,
        droppedElement,
      );
    });

    _debounceAutoSave();
  }

  void _updateElementProperty(String key, dynamic value) {
    if (_selectedElementPath == null) return;

    final selectedElement = _getSelectedElement();
    if (selectedElement == null) return;

    final updatedElement = LayoutOperations.updateElementProperty(
      selectedElement,
      key,
      value,
    );

    setState(() {
      _currentConfig = LayoutOperations.updateElement(
        _currentConfig,
        _selectedElementPath!,
        updatedElement,
      );
    });

    _debounceAutoSave();
  }

  LayoutElement? _getSelectedElement() {
    if (_selectedElementPath == null) return null;
    return LayoutOperations.findElement(_currentConfig, _selectedElementPath!);
  }

  Widget _buildLayoutWidget(LayoutElement element, String path) {
    // DynamicLayout과 유사한 로직 사용하여 위젯 빌드
    switch (element.type.toLowerCase()) {
      case 'column':
        return _buildColumnWidget(element, path);
      case 'row':
        return _buildRowWidget(element, path);
      case 'container':
        return _buildContainerWidget(element, path);
      case 'text':
        return _buildTextWidget(element);
      case 'sizedbox':
        return _buildSizedBoxWidget(element);
      case 'expanded':
        return _buildExpandedWidget(element, path);
      case 'custom_card':
        return _buildCustomCardWidget(element);
      default:
        return _buildPlaceholderWidget(element, path);
    }
  }

  Widget _buildColumnWidget(LayoutElement element, String path) {
    final children = <Widget>[];
    if (element.children != null) {
      for (int i = 0; i < element.children!.length; i++) {
        children.add(
          _buildLayoutWidget(element.children![i], '$path.children[$i]'),
        );
      }
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildRowWidget(LayoutElement element, String path) {
    final children = <Widget>[];
    if (element.children != null) {
      for (int i = 0; i < element.children!.length; i++) {
        children.add(
          _buildLayoutWidget(element.children![i], '$path.children[$i]'),
        );
      }
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildContainerWidget(LayoutElement element, String path) {
    final properties = element.properties ?? {};
    final width = (properties['width'] as num?)?.toDouble();
    final height = (properties['height'] as num?)?.toDouble();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        border: Border.all(color: Colors.grey),
      ),
      child: element.child != null
          ? _buildLayoutWidget(element.child!, '$path.child')
          : const Center(child: Text('Container')),
    );
  }

  Widget _buildTextWidget(LayoutElement element) {
    final properties = element.properties ?? {};
    final text = properties['text'] as String? ?? 'Text';
    final fontSize = (properties['font_size'] as num?)?.toDouble() ?? 14.0;

    return Text(text, style: TextStyle(fontSize: fontSize));
  }

  Widget _buildSizedBoxWidget(LayoutElement element) {
    final properties = element.properties ?? {};
    final width = (properties['width'] as num?)?.toDouble() ?? 100.0;
    final height = (properties['height'] as num?)?.toDouble() ?? 100.0;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Center(child: Text('${width.toInt()}x${height.toInt()}')),
      ),
    );
  }

  Widget _buildExpandedWidget(LayoutElement element, String path) {
    final properties = element.properties ?? {};
    final flex = properties['flex'] as int? ?? 1;

    return Expanded(
      flex: flex,
      child: element.child != null
          ? _buildLayoutWidget(element.child!, '$path.child')
          : Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
              child: const Center(child: Text('Expanded')),
            ),
    );
  }

  Widget _buildCustomCardWidget(LayoutElement element) {
    final properties = element.properties ?? {};
    final appId = properties['app_id'] as String? ?? '';

    if (appId.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.green)),
        child: Text('App: $appId'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: const Text('Custom Card'),
    );
  }

  Widget _buildPlaceholderWidget(LayoutElement element, String path) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red),
      ),
      child: Text('Unknown: ${element.type}'),
    );
  }

  LayoutElement _createDefaultElement(String type) {
    switch (type) {
      case 'column':
        return const LayoutElement(type: 'column', children: []);
      case 'row':
        return const LayoutElement(type: 'row', children: []);
      case 'container':
        return const LayoutElement(
          type: 'container',
          properties: {'width': 100.0, 'height': 100.0},
        );
      case 'text':
        return const LayoutElement(
          type: 'text',
          properties: {'text': 'New Text', 'font_size': 14.0},
        );
      case 'sizedbox':
        return const LayoutElement(
          type: 'sizedbox',
          properties: {'width': 100.0, 'height': 100.0},
        );
      case 'expanded':
        return const LayoutElement(type: 'expanded', properties: {'flex': 1});
      case 'custom_card':
        return const LayoutElement(
          type: 'custom_card',
          properties: {'app_id': ''},
        );
      default:
        return LayoutElement(type: type);
    }
  }

  void _debounceAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onLayoutChanged?.call(_currentConfig);
      }
    });
  }

  void _saveLayout() {
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
