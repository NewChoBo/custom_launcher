/// Launcher item type enumeration
enum LauncherItemType {
  /// Executable file (.exe, .bat, etc.)
  executable,

  /// Web URL
  url,
}

/// Position information for launcher item placement
class ItemPosition {
  final double x;
  final double y;
  final int? gridRow;
  final int? gridColumn;

  const ItemPosition({
    required this.x,
    required this.y,
    this.gridRow,
    this.gridColumn,
  });

  /// Create ItemPosition from JSON
  factory ItemPosition.fromJson(Map<String, dynamic> json) {
    return ItemPosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      gridRow: json['gridRow'] as int?,
      gridColumn: json['gridColumn'] as int?,
    );
  }

  /// Convert ItemPosition to JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      if (gridRow != null) 'gridRow': gridRow,
      if (gridColumn != null) 'gridColumn': gridColumn,
    };
  }

  /// Create a copy with updated values
  ItemPosition copyWith({double? x, double? y, int? gridRow, int? gridColumn}) {
    return ItemPosition(
      x: x ?? this.x,
      y: y ?? this.y,
      gridRow: gridRow ?? this.gridRow,
      gridColumn: gridColumn ?? this.gridColumn,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemPosition &&
        other.x == x &&
        other.y == y &&
        other.gridRow == gridRow &&
        other.gridColumn == gridColumn;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, gridRow, gridColumn);
  }
}

/// Launcher item model for apps and URLs
class LauncherItem {
  final String id;
  final String name;
  final String path; // File path for executable or URL for web links
  final LauncherItemType itemType;
  final String? iconPath; // Custom icon path (optional)
  final ItemPosition position;
  final bool isVisible;
  final DateTime? lastUsed;

  const LauncherItem({
    required this.id,
    required this.name,
    required this.path,
    required this.itemType,
    this.iconPath,
    required this.position,
    this.isVisible = true,
    this.lastUsed,
  });

  /// Create LauncherItem from JSON
  factory LauncherItem.fromJson(Map<String, dynamic> json) {
    return LauncherItem(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      itemType: LauncherItemType.values.firstWhere(
        (e) => e.name == json['itemType'],
        orElse: () => LauncherItemType.executable,
      ),
      iconPath: json['iconPath'] as String?,
      position: ItemPosition.fromJson(json['position'] as Map<String, dynamic>),
      isVisible: json['isVisible'] as bool? ?? true,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
    );
  }

  /// Convert LauncherItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'itemType': itemType.name,
      if (iconPath != null) 'iconPath': iconPath,
      'position': position.toJson(),
      'isVisible': isVisible,
      if (lastUsed != null) 'lastUsed': lastUsed!.toIso8601String(),
    };
  }

  /// Create a copy with updated values
  LauncherItem copyWith({
    String? id,
    String? name,
    String? path,
    LauncherItemType? itemType,
    String? iconPath,
    ItemPosition? position,
    bool? isVisible,
    DateTime? lastUsed,
  }) {
    return LauncherItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      itemType: itemType ?? this.itemType,
      iconPath: iconPath ?? this.iconPath,
      position: position ?? this.position,
      isVisible: isVisible ?? this.isVisible,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  /// Mark item as used (update lastUsed timestamp)
  LauncherItem markAsUsed() {
    return copyWith(lastUsed: DateTime.now());
  }

  /// Check if this is an executable item
  bool get isExecutable => itemType == LauncherItemType.executable;

  /// Check if this is a URL item
  bool get isUrl => itemType == LauncherItemType.url;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LauncherItem &&
        other.id == id &&
        other.name == name &&
        other.path == path &&
        other.itemType == itemType &&
        other.iconPath == iconPath &&
        other.position == position &&
        other.isVisible == isVisible &&
        other.lastUsed == lastUsed;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      path,
      itemType,
      iconPath,
      position,
      isVisible,
      lastUsed,
    );
  }

  @override
  String toString() {
    return 'LauncherItem(id: $id, name: $name, type: $itemType, path: $path)';
  }
}
