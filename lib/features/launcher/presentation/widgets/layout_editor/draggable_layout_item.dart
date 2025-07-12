import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

class DraggableLayoutItem extends StatefulWidget {
  final LayoutElement element;
  final String elementPath;
  final Function(String fromPath, String toPath, int toIndex)? onElementMoved;
  final Function(String elementPath)? onElementSelected;
  final Function(String elementPath)? onElementDeleted;
  final bool isSelected;
  final Widget child;

  const DraggableLayoutItem({
    super.key,
    required this.element,
    required this.elementPath,
    required this.child,
    this.onElementMoved,
    this.onElementSelected,
    this.onElementDeleted,
    this.isSelected = false,
  });

  @override
  State<DraggableLayoutItem> createState() => _DraggableLayoutItemState();
}

class _DraggableLayoutItemState extends State<DraggableLayoutItem> {
  bool _isDragging = false;
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (mounted) {
          setState(() => _isHovering = true);
        }
      },
      onExit: (_) {
        if (mounted) {
          setState(() => _isHovering = false);
        }
      },
      child: GestureDetector(
        onTap: () => widget.onElementSelected?.call(widget.elementPath),
        child: Draggable<LayoutElementDragData>(
          data: LayoutElementDragData(
            element: widget.element,
            sourcePath: widget.elementPath,
          ),
          feedback: _buildDragFeedback(),
          childWhenDragging: _buildChildWhenDragging(),
          onDragStarted: () {
            if (mounted) {
              setState(() => _isDragging = true);
            }
          },
          onDragEnd: (_) {
            if (mounted) {
              setState(() => _isDragging = false);
            }
          },
          child: _buildSelectableContainer(),
        ),
      ),
    );
  }

  Widget _buildSelectableContainer() {
    final isHighlighted = widget.isSelected || _isHovering || _isDragging;

    return Container(
      decoration: BoxDecoration(
        border: isHighlighted
            ? Border.all(
                color: widget.isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: widget.isSelected ? 2 : 1,
              )
            : null,
        borderRadius: BorderRadius.circular(8),
        color: widget.isSelected
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : _isHovering
            ? Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : null,
      ),
      child: Stack(
        children: [widget.child, if (isHighlighted) _buildElementControls()],
      ),
    );
  }

  Widget _buildElementControls() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 요소 타입 표시
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getElementColor(
                  widget.element.type,
                ).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getElementIcon(widget.element.type),
                    size: 12,
                    color: _getElementColor(widget.element.type),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.element.type.toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getElementColor(widget.element.type),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            // 드래그 핸들
            Icon(
              Icons.drag_indicator,
              size: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 4),
            // 삭제 버튼
            InkWell(
              onTap: () => widget.onElementDeleted?.call(widget.elementPath),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragFeedback() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getElementIcon(widget.element.type),
              color: _getElementColor(widget.element.type),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _getElementDisplayName(widget.element),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildWhenDragging() {
    return Opacity(
      opacity: 0.3,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.child,
      ),
    );
  }

  IconData _getElementIcon(String type) {
    switch (type) {
      case 'column':
        return Icons.view_column;
      case 'row':
        return Icons.view_stream;
      case 'container':
        return Icons.crop_square;
      case 'text':
        return Icons.text_fields;
      case 'icon':
        return Icons.star;
      case 'custom_card':
        return Icons.rectangle;
      case 'expanded':
        return Icons.open_in_full;
      case 'sizedbox':
        return Icons.crop_free;
      case 'card':
        return Icons.credit_card;
      default:
        return Icons.widgets;
    }
  }

  Color _getElementColor(String type) {
    switch (type) {
      case 'column':
        return Colors.blue;
      case 'row':
        return Colors.green;
      case 'container':
        return Colors.orange;
      case 'text':
        return Colors.purple;
      case 'icon':
        return Colors.amber;
      case 'custom_card':
        return Colors.red;
      case 'expanded':
        return Colors.teal;
      case 'sizedbox':
        return Colors.grey;
      case 'card':
        return Colors.indigo;
      default:
        return Colors.black54;
    }
  }

  String _getElementDisplayName(LayoutElement element) {
    final type = element.type;
    String displayName = type.replaceAll('_', ' ').toUpperCase();

    if (element.properties != null) {
      switch (type) {
        case 'custom_card':
          final appId = element.properties!['app_id'] as String?;
          if (appId != null) {
            displayName += ' ($appId)';
          }
          break;
        case 'expanded':
          final flex = element.properties!['flex'] as int?;
          if (flex != null) {
            displayName += ' (flex: $flex)';
          }
          break;
        case 'text':
          final text = element.properties!['text'] as String?;
          if (text != null) {
            displayName +=
                ' ("${text.length > 20 ? '${text.substring(0, 20)}...' : text}")';
          }
          break;
      }
    }

    return displayName;
  }
}

// 드래그 데이터 클래스
class LayoutElementDragData {
  final LayoutElement element;
  final String sourcePath;

  const LayoutElementDragData({
    required this.element,
    required this.sourcePath,
  });
}

// 드롭 타겟 위젯
class LayoutDropTarget extends StatefulWidget {
  final String targetPath;
  final Function(LayoutElementDragData data, String targetPath, int index)?
  onAccept;
  final Widget child;
  final bool canAcceptChildren;

  const LayoutDropTarget({
    super.key,
    required this.targetPath,
    required this.child,
    this.onAccept,
    this.canAcceptChildren = true,
  });

  @override
  State<LayoutDropTarget> createState() => _LayoutDropTargetState();
}

class _LayoutDropTargetState extends State<LayoutDropTarget> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.canAcceptChildren) {
      return widget.child;
    }

    return DragTarget<LayoutElementDragData>(
      onWillAcceptWithDetails: (details) {
        return details.data.sourcePath != widget.targetPath;
      },
      onAcceptWithDetails: (details) {
        widget.onAccept?.call(details.data, widget.targetPath, 0);
        if (mounted) {
          setState(() => _isHovering = false);
        }
      },
      onMove: (_) {
        if (!_isHovering && mounted) {
          setState(() => _isHovering = true);
        }
      },
      onLeave: (_) {
        if (mounted) {
          setState(() => _isHovering = false);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            border: _isHovering
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                    style: BorderStyle.solid,
                  )
                : null,
            borderRadius: BorderRadius.circular(8),
            color: _isHovering
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}
