import 'dart:convert';

/// Launcher configuration model
class LauncherConfig {
  final String version;
  final Map<String, LauncherItem> launchers;

  const LauncherConfig({required this.version, required this.launchers});

  factory LauncherConfig.fromMap(Map<String, dynamic> map) {
    return LauncherConfig(
      version: map['version'] as String? ?? '1.0',
      launchers:
          (map['launchers'] as Map<String, dynamic>? ?? <String, dynamic>{})
              .map(
                (String key, value) => MapEntry(
                  key,
                  LauncherItem.fromMap(value as Map<String, dynamic>),
                ),
              ),
    );
  }

  factory LauncherConfig.fromJson(String source) {
    return LauncherConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'launchers': launchers.map(
        (String key, LauncherItem value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  String toJson() => json.encode(toMap());

  LauncherItem? getLauncher(String id) {
    return launchers[id];
  }

  List<LauncherItem> getLaunchersByCategory(String category) {
    return launchers.values
        .where((LauncherItem launcher) => launcher.category == category)
        .toList();
  }
}

/// Individual launcher item
class LauncherItem {
  final String id;
  final String displayName;
  final String description;
  final String category;
  final Map<String, String> images;
  final Map<String, LauncherAction> actions;

  const LauncherItem({
    required this.id,
    required this.displayName,
    required this.description,
    required this.category,
    required this.images,
    required this.actions,
  });

  factory LauncherItem.fromMap(Map<String, dynamic> map) {
    return LauncherItem(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'general',
      images: Map<String, String>.from(
        map['images'] as Map? ?? <dynamic, dynamic>{},
      ),
      actions: (map['actions'] as Map<String, dynamic>? ?? <String, dynamic>{})
          .map(
            (String key, value) => MapEntry(
              key,
              LauncherAction.fromMap(value as Map<String, dynamic>),
            ),
          ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'description': description,
      'category': category,
      'images': images,
      'actions': actions.map(
        (String key, LauncherAction value) => MapEntry(key, value.toMap()),
      ),
    };
  }

  /// Get image path by type, fallback to default
  String getImagePath(String type) {
    return images[type] ?? images['default'] ?? '';
  }

  /// Get action by type, fallback to default
  LauncherAction? getAction(String type) {
    return actions[type] ?? actions['default'];
  }

  /// Get resolved action (with inheritance from default)
  LauncherAction? getResolvedAction(String type) {
    final LauncherAction? action = actions[type];
    final LauncherAction? defaultAction = actions['default'];

    if (action == null) return defaultAction;
    if (defaultAction == null) return action;

    // Inherit from default and override specified properties
    return LauncherAction(
      type: action.type ?? defaultAction.type,
      target: action.target ?? defaultAction.target,
      arguments: action.arguments ?? defaultAction.arguments,
      workingDirectory:
          action.workingDirectory ?? defaultAction.workingDirectory,
    );
  }
}

/// Launcher action definition
class LauncherAction {
  final String? type;
  final String? target;
  final List<String>? arguments;
  final String? workingDirectory;

  const LauncherAction({
    this.type,
    this.target,
    this.arguments,
    this.workingDirectory,
  });

  factory LauncherAction.fromMap(Map<String, dynamic> map) {
    return LauncherAction(
      type: map['type'] as String?,
      target: map['target'] as String?,
      arguments: map['arguments'] != null
          ? List<String>.from(map['arguments'] as List)
          : null,
      workingDirectory: map['workingDirectory'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (type != null) 'type': type,
      if (target != null) 'target': target,
      if (arguments != null) 'arguments': arguments,
      if (workingDirectory != null) 'workingDirectory': workingDirectory,
    };
  }

  /// Check if this action has complete information for execution
  bool get isExecutable {
    return type != null && target != null;
  }
}
