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
          spacedChildren.add(SizedBox(height: spacing));
        } else {
          spacedChildren.add(SizedBox(width: spacing));
        }
      }
    }
    return spacedChildren;
  }
}
