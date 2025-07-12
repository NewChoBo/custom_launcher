import 'dart:convert';
import 'dart:io';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/core/storage/file_service.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error.dart';

class LayoutRepositoryImpl implements LayoutRepository {
  static const String _layoutConfigFile = 'layout_config.json';
  static const String _layoutPresetsDir = 'layout_presets';
  static const String _defaultLayoutFile = 'default_layout.json';

  LayoutConfig? _cachedLayoutConfig;
  final Logger _logger = LogManager.instance.logger;

  @override
  Future<LayoutConfig> getLayoutConfig() async {
    if (_cachedLayoutConfig != null) {
      return _cachedLayoutConfig!;
    }

    try {
      if (await FileService.instance.fileExists(_layoutConfigFile)) {
        final data = await FileService.instance.readJsonFile(_layoutConfigFile);
        _cachedLayoutConfig = LayoutConfig.fromMap(data);
        _logger.info('Loaded layout config from file', tag: 'LayoutRepository');
        return _cachedLayoutConfig!;
      }
    } catch (e) {
      _logger.warn(
        'Failed to load layout config, falling back to default',
        tag: 'LayoutRepository',
        error: e,
      );
    }

    // 기본 레이아웃 로드
    return await _loadDefaultLayout();
  }

  @override
  Future<void> saveLayoutConfig(LayoutConfig layoutConfig) async {
    try {
      final layoutData = _layoutConfigToMap(layoutConfig);
      await FileService.instance.writeJsonFile(_layoutConfigFile, layoutData);
      _cachedLayoutConfig = layoutConfig;
      _logger.info('Saved layout config to file', tag: 'LayoutRepository');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save layout config',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to save layout config',
        details: 'Error writing layout config to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateLayoutElement(
    String elementPath,
    Map<String, dynamic> updates,
  ) async {
    final currentConfig = await getLayoutConfig();
    final updatedConfig = _updateElementInConfig(
      currentConfig,
      elementPath,
      updates,
    );
    await saveLayoutConfig(updatedConfig);
  }

  @override
  Future<void> addLayoutElement(
    String parentPath,
    Map<String, dynamic> elementData,
  ) async {
    final currentConfig = await getLayoutConfig();
    final updatedConfig = _addElementToConfig(
      currentConfig,
      parentPath,
      elementData,
    );
    await saveLayoutConfig(updatedConfig);
  }

  @override
  Future<void> removeLayoutElement(String elementPath) async {
    final currentConfig = await getLayoutConfig();
    final updatedConfig = _removeElementFromConfig(currentConfig, elementPath);
    await saveLayoutConfig(updatedConfig);
  }

  @override
  Future<void> moveLayoutElement(
    String elementPath,
    String newParentPath,
    int newIndex,
  ) async {
    final currentConfig = await getLayoutConfig();
    final updatedConfig = _moveElementInConfig(
      currentConfig,
      elementPath,
      newParentPath,
      newIndex,
    );
    await saveLayoutConfig(updatedConfig);
  }

  @override
  Future<List<String>> getLayoutPresets() async {
    try {
      final presets = <String>[];
      final appDataPath = await FileService.instance.getAppDataPath();
      final presetsDir = Directory('$appDataPath/$_layoutPresetsDir');

      if (await presetsDir.exists()) {
        final files = await presetsDir.list().toList();

        for (final file in files) {
          if (file is File && file.path.endsWith('.json')) {
            final fileName = file.path.split('/').last;
            final presetName = fileName.replaceAll('.json', '');
            presets.add(presetName);
          }
        }
      }

      return presets;
    } catch (e) {
      _logger.warn(
        'Failed to get layout presets',
        tag: 'LayoutRepository',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<void> saveLayoutPreset(
    String presetName,
    LayoutConfig layoutConfig,
  ) async {
    try {
      final presetPath = '$_layoutPresetsDir/$presetName.json';
      final layoutData = _layoutConfigToMap(layoutConfig);
      await FileService.instance.writeJsonFile(presetPath, layoutData);
      _logger.info('Saved layout preset: $presetName', tag: 'LayoutRepository');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save layout preset: $presetName',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to save layout preset',
        details: 'Error writing preset to file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<LayoutConfig> loadLayoutPreset(String presetName) async {
    try {
      final presetPath = '$_layoutPresetsDir/$presetName.json';
      final data = await FileService.instance.readJsonFile(presetPath);
      return LayoutConfig.fromMap(data);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to load layout preset: $presetName',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to load layout preset',
        details: 'Error reading preset from file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> deleteLayoutPreset(String presetName) async {
    try {
      final presetPath = '$_layoutPresetsDir/$presetName.json';
      await FileService.instance.deleteFile(presetPath);
      _logger.info(
        'Deleted layout preset: $presetName',
        tag: 'LayoutRepository',
      );
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to delete layout preset: $presetName',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to delete layout preset',
        details: 'Error deleting preset file',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetToDefaultLayout() async {
    try {
      final defaultLayout = await _loadDefaultLayout();
      await saveLayoutConfig(defaultLayout);
      _logger.info('Reset to default layout', tag: 'LayoutRepository');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to reset to default layout',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to reset to default layout',
        details: 'Error loading default layout',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> exportLayoutToJson() async {
    try {
      final currentConfig = await getLayoutConfig();
      final layoutData = _layoutConfigToMap(currentConfig);
      return json.encode(layoutData);
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to export layout to JSON',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to export layout',
        details: 'Error converting layout to JSON',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> importLayoutFromJson(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final layoutConfig = LayoutConfig.fromMap(data);
      await saveLayoutConfig(layoutConfig);
      _logger.info('Imported layout from JSON', tag: 'LayoutRepository');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to import layout from JSON',
        tag: 'LayoutRepository',
        error: e,
        stackTrace: stackTrace,
      );
      throw FileSystemError(
        message: 'Failed to import layout',
        details: 'Error parsing JSON or saving layout',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  // Private helper methods
  Future<LayoutConfig> _loadDefaultLayout() async {
    try {
      final data = await FileService.instance.readJsonFile(_defaultLayoutFile);
      return LayoutConfig.fromMap(data);
    } catch (e) {
      // 기본 레이아웃 하드코딩
      return _createHardcodedDefaultLayout();
    }
  }

  LayoutConfig _createHardcodedDefaultLayout() {
    final defaultLayoutData = {
      'layout': {
        'type': 'column',
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'start',
        'spacing': 2,
        'children': [
          {
            'type': 'expanded',
            'flex': 1,
            'child': {
              'type': 'row',
              'reorderable': true,
              'spacing': 2,
              'children': [
                {'type': 'custom_card', 'app_id': 'steam'},
                {'type': 'custom_card', 'app_id': 'discord'},
              ],
            },
          },
        ],
      },
    };
    return LayoutConfig.fromMap(defaultLayoutData);
  }

  Map<String, dynamic> _layoutConfigToMap(LayoutConfig config) {
    return {'layout': _layoutElementToMap(config.layout)};
  }

  Map<String, dynamic> _layoutElementToMap(LayoutElement element) {
    final map = <String, dynamic>{'type': element.type};

    if (element.properties != null) {
      map.addAll(element.properties!);
    }

    if (element.children != null) {
      map['children'] = element.children!.map(_layoutElementToMap).toList();
    }

    if (element.child != null) {
      map['child'] = _layoutElementToMap(element.child!);
    }

    return map;
  }

  LayoutConfig _updateElementInConfig(
    LayoutConfig config,
    String elementPath,
    Map<String, dynamic> updates,
  ) {
    final pathParts = elementPath.split('.');
    final updatedLayout = _updateElementRecursive(
      config.layout,
      pathParts,
      updates,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutConfig _addElementToConfig(
    LayoutConfig config,
    String parentPath,
    Map<String, dynamic> elementData,
  ) {
    final pathParts = parentPath.split('.');
    final updatedLayout = _addElementToElementRecursive(
      config.layout,
      pathParts,
      elementData,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutConfig _removeElementFromConfig(
    LayoutConfig config,
    String elementPath,
  ) {
    final pathParts = elementPath.split('.');
    final updatedLayout = _removeElementFromElementRecursive(
      config.layout,
      pathParts,
    );
    return LayoutConfig(layout: updatedLayout);
  }

  LayoutConfig _moveElementInConfig(
    LayoutConfig config,
    String elementPath,
    String newParentPath,
    int newIndex,
  ) {
    // TODO: Implement element moving logic
    // For now, return the original config
    return config;
  }

  // Helper methods for recursive operations
  LayoutElement _updateElementRecursive(
    LayoutElement element,
    List<String> pathParts,
    Map<String, dynamic> updates,
  ) {
    if (pathParts.isEmpty) {
      // Update current element
      final updatedProperties = Map<String, dynamic>.from(
        element.properties ?? {},
      );
      updatedProperties.addAll(updates);
      return LayoutElement(
        type: element.type,
        properties: updatedProperties,
        children: element.children,
        child: element.child,
      );
    }

    final currentPart = pathParts.first;
    final remainingParts = pathParts.sublist(1);

    if (currentPart == 'child' && element.child != null) {
      final updatedChild = _updateElementRecursive(
        element.child!,
        remainingParts,
        updates,
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
          updates,
        );
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: updatedChildren,
          child: element.child,
        );
      }
    }

    // Path not found, return original element
    return element;
  }

  LayoutElement _addElementToElementRecursive(
    LayoutElement element,
    List<String> pathParts,
    Map<String, dynamic> elementData,
  ) {
    if (pathParts.isEmpty) {
      // Add to current element's children
      final newElement = LayoutElement.fromMap(elementData);
      final updatedChildren = List<LayoutElement>.from(element.children ?? []);
      updatedChildren.add(newElement);
      return LayoutElement(
        type: element.type,
        properties: element.properties,
        children: updatedChildren,
        child: element.child,
      );
    }

    final currentPart = pathParts.first;
    final remainingParts = pathParts.sublist(1);

    if (currentPart == 'child' && element.child != null) {
      final updatedChild = _addElementToElementRecursive(
        element.child!,
        remainingParts,
        elementData,
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
        updatedChildren[index] = _addElementToElementRecursive(
          updatedChildren[index],
          remainingParts,
          elementData,
        );
        return LayoutElement(
          type: element.type,
          properties: element.properties,
          children: updatedChildren,
          child: element.child,
        );
      }
    }

    // Path not found, return original element
    return element;
  }

  LayoutElement _removeElementFromElementRecursive(
    LayoutElement element,
    List<String> pathParts,
  ) {
    if (pathParts.length == 1) {
      final targetPart = pathParts.first;

      if (targetPart == 'child') {
        // Remove child
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
    } else {
      final currentPart = pathParts.first;
      final remainingParts = pathParts.sublist(1);

      if (currentPart == 'child' && element.child != null) {
        final updatedChild = _removeElementFromElementRecursive(
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
          updatedChildren[index] = _removeElementFromElementRecursive(
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

    // Path not found or unable to remove, return original element
    return element;
  }
}
