import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

class LayoutOperations {
  static LayoutConfig addElement(
    LayoutConfig config,
    String targetPath,
    LayoutElement newElement,
  ) {
    final pathParts = targetPath.split('.');
    pathParts.removeAt(0);
    final updatedLayout = _addElementRecursive(
      config.layout,
      pathParts,
      newElement,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  static LayoutConfig removeElement(LayoutConfig config, String elementPath) {
    final pathParts = elementPath.split('.');
    pathParts.removeAt(0);
    final updatedLayout = _removeElementRecursive(config.layout, pathParts);
    return LayoutConfig(layout: updatedLayout);
  }

  static LayoutConfig updateElement(
    LayoutConfig config,
    String elementPath,
    LayoutElement newElement,
  ) {
    final pathParts = elementPath.split('.');
    pathParts.removeAt(0);
    final updatedLayout = _updateElementRecursive(
      config.layout,
      pathParts,
      newElement,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  static LayoutConfig moveElement(
    LayoutConfig config,
    String fromPath,
    String toPath,
  ) {
    final elementToMove = findElement(config, fromPath);
    if (elementToMove == null) return config;

    var tempConfig = removeElement(config, fromPath);

    return addElement(tempConfig, toPath, elementToMove);
  }

  static LayoutElement? findElement(LayoutConfig config, String elementPath) {
    if (elementPath == 'root') {
      return config.layout;
    }

    final pathParts = elementPath.split('.');
    pathParts.removeAt(0);
    return _findElementRecursive(config.layout, pathParts);
  }

  static LayoutElement? _findElementRecursive(
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

  static LayoutElement _addElementRecursive(
    LayoutElement element,
    List<String> pathParts,
    LayoutElement newElement,
  ) {
    if (pathParts.isEmpty) {
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

  static LayoutElement _removeElementRecursive(
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

  static LayoutElement _updateElementRecursive(
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

  static LayoutElement updateElementProperty(
    LayoutElement element,
    String propertyKey,
    dynamic propertyValue,
  ) {
    final updatedProperties = Map<String, dynamic>.from(
      element.properties ?? {},
    );
    updatedProperties[propertyKey] = propertyValue;

    return LayoutElement(
      type: element.type,
      properties: updatedProperties,
      children: element.children,
      child: element.child,
    );
  }
}
