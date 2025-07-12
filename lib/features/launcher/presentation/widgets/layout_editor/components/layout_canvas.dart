import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/layout_editor/draggable_layout_item.dart';

class LayoutCanvas extends StatelessWidget {
  final bool isEditMode;
  final LayoutConfig layoutConfig;
  final String? selectedElementPath;
  final Function(String elementPath) onElementSelected;
  final Function(String elementPath) onElementDeleted;
  final Function(String fromPath, String toPath, int? insertIndex)
  onElementMoved;
  final Function(String targetPath, LayoutElement droppedElement) onElementDrop;
  final Widget Function(LayoutElement element, String path) layoutWidgetBuilder;

  const LayoutCanvas({
    super.key,
    required this.isEditMode,
    required this.layoutConfig,
    required this.selectedElementPath,
    required this.onElementSelected,
    required this.onElementDeleted,
    required this.onElementMoved,
    required this.onElementDrop,
    required this.layoutWidgetBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (!isEditMode) {
      return _buildPreviewLayout(context);
    }

    return LayoutDropTarget(
      targetPath: 'root',
      onAccept: (data, targetPath, index) {
        onElementDrop(targetPath, data.element);
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildEditableElement(
            context: context,
            element: layoutConfig.layout,
            path: 'root',
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewLayout(BuildContext context) {
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

  Widget _buildEditableElement({
    required BuildContext context,
    required LayoutElement element,
    required String path,
  }) {
    final isSelected = selectedElementPath == path;

    Widget child = layoutWidgetBuilder(element, path);

    if (isEditMode && path != 'root') {
      child = DraggableLayoutItem(
        element: element,
        elementPath: path,
        isSelected: isSelected,
        onElementSelected: onElementSelected,
        onElementDeleted: onElementDeleted,
        onElementMoved: onElementMoved,
        child: child,
      );
    }

    return child;
  }
}

// Note: LayoutDropTarget is defined in draggable_layout_item.dart
