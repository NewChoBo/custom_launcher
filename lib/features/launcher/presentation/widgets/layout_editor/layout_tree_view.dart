import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

class LayoutTreeView extends StatefulWidget {
  final LayoutConfig layoutConfig;
  final Function(String elementPath)? onElementSelected;
  final Function(String elementPath, Map<String, dynamic> updates)?
  onElementUpdated;

  const LayoutTreeView({
    super.key,
    required this.layoutConfig,
    this.onElementSelected,
    this.onElementUpdated,
  });

  @override
  State<LayoutTreeView> createState() => _LayoutTreeViewState();
}

class _LayoutTreeViewState extends State<LayoutTreeView> {
  final Set<String> _expandedNodes = <String>{};
  String? _selectedElementPath;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Layout Structure',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'expand_all':
                        _expandAll();
                        break;
                      case 'collapse_all':
                        _collapseAll();
                        break;
                      case 'refresh':
                        _refresh();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'expand_all',
                      child: Row(
                        children: [
                          Icon(Icons.unfold_more),
                          SizedBox(width: 8),
                          Text('Expand All'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'collapse_all',
                      child: Row(
                        children: [
                          Icon(Icons.unfold_less),
                          SizedBox(width: 8),
                          Text('Collapse All'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'refresh',
                      child: Row(
                        children: [
                          Icon(Icons.refresh),
                          SizedBox(width: 8),
                          Text('Refresh'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildTreeNode(
                  element: widget.layoutConfig.layout,
                  path: 'root',
                  depth: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode({
    required LayoutElement element,
    required String path,
    required int depth,
  }) {
    final hasChildren =
        element.children?.isNotEmpty == true || element.child != null;
    final isExpanded = _expandedNodes.contains(path);
    final isSelected = _selectedElementPath == path;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(left: depth * 16.0),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedElementPath = path;
              });
              widget.onElementSelected?.call(path);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2)
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasChildren)
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedNodes.remove(path);
                          } else {
                            _expandedNodes.add(path);
                          }
                        });
                      },
                      child: Icon(
                        isExpanded ? Icons.expand_more : Icons.chevron_right,
                        size: 16,
                      ),
                    )
                  else
                    const SizedBox(width: 16),
                  Icon(
                    _getElementIcon(element.type),
                    size: 16,
                    color: _getElementColor(element.type),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getElementDisplayName(element),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (element.properties != null &&
                      element.properties!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${element.properties!.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded) ...[
          if (element.child != null)
            _buildTreeNode(
              element: element.child!,
              path: '$path.child',
              depth: depth + 1,
            ),
          if (element.children != null)
            ...element.children!.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return _buildTreeNode(
                element: child,
                path: '$path.children[$index]',
                depth: depth + 1,
              );
            }),
        ],
      ],
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

    // 추가 정보 표시
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

  void _expandAll() {
    setState(() {
      _expandedNodes.clear();
      _addAllPaths(widget.layoutConfig.layout, 'root');
    });
  }

  void _addAllPaths(LayoutElement element, String path) {
    final hasChildren =
        element.children?.isNotEmpty == true || element.child != null;

    if (hasChildren) {
      _expandedNodes.add(path);

      if (element.child != null) {
        _addAllPaths(element.child!, '$path.child');
      }

      if (element.children != null) {
        for (int i = 0; i < element.children!.length; i++) {
          _addAllPaths(element.children![i], '$path.children[$i]');
        }
      }
    }
  }

  void _collapseAll() {
    setState(() {
      _expandedNodes.clear();
    });
  }

  void _refresh() {
    setState(() {
      _expandedNodes.clear();
      _selectedElementPath = null;
    });
  }
}
