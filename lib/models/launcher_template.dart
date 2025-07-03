/// Launcher template configuration model
class LauncherTemplate {
  final String id;
  final String name;
  final LauncherTemplateType type;
  final Map<String, dynamic> defaultStyle;
  final Map<String, dynamic> layout;
  final String? description;

  const LauncherTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.defaultStyle,
    required this.layout,
    this.description,
  });

  /// Create from JSON data
  factory LauncherTemplate.fromJson(Map<String, dynamic> json) {
    return LauncherTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      type: LauncherTemplateType.fromString(json['type'] as String),
      defaultStyle:
          json['defaultStyle'] as Map<String, dynamic>? ?? <String, dynamic>{},
      layout: json['layout'] as Map<String, dynamic>? ?? <String, dynamic>{},
      description: json['description'] as String?,
    );
  }

  /// Convert to JSON data
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type.name,
      'defaultStyle': defaultStyle,
      'layout': layout,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return 'LauncherTemplate{id: $id, name: $name, type: $type}';
  }
}

/// Template types for different launcher layouts
enum LauncherTemplateType {
  card('card'),
  icon('icon'),
  list('list'),
  tile('tile');

  const LauncherTemplateType(this.name);

  final String name;

  /// Create from string value
  static LauncherTemplateType fromString(String value) {
    return LauncherTemplateType.values.firstWhere(
      (LauncherTemplateType type) => type.name == value.toLowerCase(),
      orElse: () => LauncherTemplateType.card,
    );
  }
}

/// Launcher item data for templates
class LauncherItem {
  final String appName;
  final String displayName;
  final String? icon;
  final String? iconPath;
  final Map<String, dynamic>? customStyle;
  final Map<String, dynamic>? metadata;

  const LauncherItem({
    required this.appName,
    required this.displayName,
    this.icon,
    this.iconPath,
    this.customStyle,
    this.metadata,
  });

  /// Create from JSON data
  factory LauncherItem.fromJson(Map<String, dynamic> json) {
    return LauncherItem(
      appName: json['appName'] as String,
      displayName: json['displayName'] as String,
      icon: json['icon'] as String?,
      iconPath: json['iconPath'] as String?,
      customStyle: json['customStyle'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON data
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'appName': appName,
      'displayName': displayName,
      if (icon != null) 'icon': icon,
      if (iconPath != null) 'iconPath': iconPath,
      if (customStyle != null) 'customStyle': customStyle,
      if (metadata != null) 'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'LauncherItem{appName: $appName, displayName: $displayName}';
  }
}
