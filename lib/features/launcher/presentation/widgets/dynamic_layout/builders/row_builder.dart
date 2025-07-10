import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/presentation/widgets/dynamic_layout/builders/spacing_util.dart';

class RowBuilder {
  static MainAxisAlignment parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }

  static Widget build(
    LayoutElement element,
    Widget Function(LayoutElement) buildWidget,
  ) {
    final double? spacing =
        element.getProperty<double>('spacing') ??
        element.getProperty<int>('spacing')?.toDouble();
    final bool reorderable =
        element.getProperty<bool>('reorderable', true) ?? true;
    final List<LayoutElement> childElements =
        element.children ?? <LayoutElement>[];
    if (!reorderable) {
      final List<Widget> children = childElements.map(buildWidget).toList();
      return Row(
        mainAxisAlignment: RowBuilder.parseMainAxisAlignment(
          element.getProperty<String>('mainAxisAlignment'),
        ),
        crossAxisAlignment: RowBuilder.parseCrossAxisAlignment(
          element.getProperty<String>('crossAxisAlignment'),
        ),
        children: spacing != null
            ? SpacingUtil.addSpacing(children, spacing, false)
            : children,
      );
    }
    // ReorderableRow 적용
    return _ReorderableRowWrapper(
      childElements: childElements,
      buildWidget: buildWidget,
      mainAxisAlignment: RowBuilder.parseMainAxisAlignment(
        element.getProperty<String>('mainAxisAlignment'),
      ),
      crossAxisAlignment: RowBuilder.parseCrossAxisAlignment(
        element.getProperty<String>('crossAxisAlignment'),
      ),
      spacing: spacing,
    );
  }
}

class _ReorderableRowWrapper extends StatefulWidget {
  final List<LayoutElement> childElements;
  final Widget Function(LayoutElement) buildWidget;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;

  const _ReorderableRowWrapper({
    required this.childElements,
    required this.buildWidget,
    required this.mainAxisAlignment,
    required this.crossAxisAlignment,
    this.spacing,
  });

  @override
  State<_ReorderableRowWrapper> createState() => _ReorderableRowWrapperState();
}

class _ReorderableRowWrapperState extends State<_ReorderableRowWrapper> {
  late List<LayoutElement> _children;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _children = List<LayoutElement>.from(widget.childElements);
  }

  @override
  void didUpdateWidget(covariant _ReorderableRowWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childElements != widget.childElements) {
      _children = List<LayoutElement>.from(widget.childElements);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Helper to map visual index (with spacing widgets) to model index
  int _toModelIndex(int visualIndex) {
    if (widget.spacing == null || widget.spacing == 0) return visualIndex;
    // Visual list: [item, spacer, item, spacer, item]
    // Model index for visual index 0, 1, 2, 3, 4 -> 0, 0, 1, 1, 2
    return visualIndex ~/ 2;
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final int oldModelIndex = _toModelIndex(oldIndex);
      int newModelIndex = _toModelIndex(newIndex);

      if (oldModelIndex == newModelIndex) return;

      final item = _children.removeAt(oldModelIndex);

      // Ensure the newModelIndex is within the valid range
      if (newModelIndex > _children.length) {
        newModelIndex = _children.length;
      }

      _children.insert(newModelIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidgets = <Widget>[];
        final int cardCount = _children.length;
        final double rowWidth = constraints.maxWidth;
        final double spacing = widget.spacing ?? 0;
        final double cardWidth =
            (rowWidth - ((cardCount - 1) * spacing)) / cardCount;

        for (var idx = 0; idx < _children.length; idx++) {
          final e = _children[idx];
          final String keyString =
              '${e.type}_${e.getProperty<String>('title', '')}_$idx';
          cardWidgets.add(
            SizedBox(
              key: ValueKey(keyString),
              width: cardWidth > 0 ? cardWidth : 0, // Ensure width is not negative
              child: widget.buildWidget(e),
            ),
          );
        }

        List<Widget> reorderableChildren = [];
        for (int i = 0; i < cardWidgets.length; i++) {
          reorderableChildren.add(cardWidgets[i]);
          if (i < cardWidgets.length - 1 && spacing > 0) {
            reorderableChildren.add(
              SizedBox(key: ValueKey('spacing_$i'), width: spacing),
            );
          }
        }

        return ReorderableRow(
          scrollController: _scrollController,
          children: reorderableChildren,
          onReorder: _onReorder,
          mainAxisAlignment: widget.mainAxisAlignment,
          crossAxisAlignment: widget.crossAxisAlignment,
        );
      },
    );
  }

  static MainAxisAlignment parseMainAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spacebetween':
        return MainAxisAlignment.spaceBetween;
      case 'spacearound':
        return MainAxisAlignment.spaceAround;
      case 'spaceevenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  static CrossAxisAlignment parseCrossAxisAlignment(String? value) {
    switch (value?.toLowerCase()) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.center;
    }
  }
}
