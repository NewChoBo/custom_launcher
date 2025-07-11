import 'package:flutter/widgets.dart';

class SpacingUtil {
  static List<Widget> addSpacing(
    List<Widget> children,
    double spacing,
    bool isColumn,
  ) {
    if (children.isEmpty) return children;
    final List<Widget> spacedChildren = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        if (isColumn) {
          spacedChildren.add(
            SizedBox(key: ValueKey('spacing_col_$i'), height: spacing),
          );
        } else {
          spacedChildren.add(
            SizedBox(key: ValueKey('spacing_row_$i'), width: spacing),
          );
        }
      }
    }
    return spacedChildren;
  }
}
