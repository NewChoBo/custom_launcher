import 'dart:convert';

/// Complete layout configuration model
class LayoutConfig {
  final String version;
  final LayoutMetadata metadata;
  final FrameConfig frame;
  final LayoutElement layout;
  final GlobalSettings globalSettings;

  const LayoutConfig({
    required this.version,
    required this.metadata,
    required this.frame,
    required this.layout,
    required this.globalSettings,
  });

  factory LayoutConfig.fromMap(Map<String, dynamic> map) {
    return LayoutConfig(
      version: map['version'] as String? ?? '1.0',
      metadata: LayoutMetadata.fromMap(map['metadata'] as Map<String, dynamic>),
      frame: FrameConfig.fromMap(map['frame'] as Map<String, dynamic>),
      layout: LayoutElement.fromMap(map['layout'] as Map<String, dynamic>),
      globalSettings: GlobalSettings.fromMap(
        map['globalSettings'] as Map<String, dynamic>,
      ),
    );
  }

  factory LayoutConfig.fromJson(String source) {
    return LayoutConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'version': version,
      'metadata': metadata.toMap(),
      'frame': frame.toMap(),
      'layout': layout.toMap(),
      'globalSettings': globalSettings.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}

/// Layout metadata information
class LayoutMetadata {
  final String title;
  final String description;
  final String author;
  final String created;
  final List<String> tags;

  const LayoutMetadata({
    required this.title,
    required this.description,
    required this.author,
    required this.created,
    required this.tags,
  });

  factory LayoutMetadata.fromMap(Map<String, dynamic> map) {
    return LayoutMetadata(
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      author: map['author'] as String? ?? '',
      created: map['created'] as String? ?? '',
      tags: List<String>.from(map['tags'] as List? ?? <dynamic>[]),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'author': author,
      'created': created,
      'tags': tags,
    };
  }
}

/// Frame configuration (window behavior)
class FrameConfig {
  final UIConfig ui;
  final WindowConfig window;
  final SystemConfig system;

  const FrameConfig({
    required this.ui,
    required this.window,
    required this.system,
  });

  factory FrameConfig.fromMap(Map<String, dynamic> map) {
    return FrameConfig(
      ui: UIConfig.fromMap(map['ui'] as Map<String, dynamic>),
      window: WindowConfig.fromMap(map['window'] as Map<String, dynamic>),
      system: SystemConfig.fromMap(map['system'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ui': ui.toMap(),
      'window': window.toMap(),
      'system': system.toMap(),
    };
  }
}

/// UI appearance configuration
class UIConfig {
  final bool showAppBar;
  final ColorConfig colors;
  final OpacityConfig opacity;

  const UIConfig({
    required this.showAppBar,
    required this.colors,
    required this.opacity,
  });

  factory UIConfig.fromMap(Map<String, dynamic> map) {
    return UIConfig(
      showAppBar: map['showAppBar'] as bool? ?? false,
      colors: ColorConfig.fromMap(map['colors'] as Map<String, dynamic>),
      opacity: OpacityConfig.fromMap(map['opacity'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'showAppBar': showAppBar,
      'colors': colors.toMap(),
      'opacity': opacity.toMap(),
    };
  }
}

/// Color configuration
class ColorConfig {
  final String appBarColor;
  final String backgroundColor;

  const ColorConfig({required this.appBarColor, required this.backgroundColor});

  factory ColorConfig.fromMap(Map<String, dynamic> map) {
    return ColorConfig(
      appBarColor: map['appBarColor'] as String? ?? '#2196F3',
      backgroundColor: map['backgroundColor'] as String? ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appBarColor': appBarColor,
      'backgroundColor': backgroundColor,
    };
  }
}

/// Opacity configuration
class OpacityConfig {
  final double appBarOpacity;
  final double backgroundOpacity;

  const OpacityConfig({
    required this.appBarOpacity,
    required this.backgroundOpacity,
  });

  factory OpacityConfig.fromMap(Map<String, dynamic> map) {
    return OpacityConfig(
      appBarOpacity: (map['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      backgroundOpacity: (map['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'appBarOpacity': appBarOpacity,
      'backgroundOpacity': backgroundOpacity,
    };
  }
}

/// Window configuration
class WindowConfig {
  final SizeConfig size;
  final PositionConfig position;
  final BehaviorConfig behavior;

  const WindowConfig({
    required this.size,
    required this.position,
    required this.behavior,
  });

  factory WindowConfig.fromMap(Map<String, dynamic> map) {
    return WindowConfig(
      size: SizeConfig.fromMap(map['size'] as Map<String, dynamic>),
      position: PositionConfig.fromMap(map['position'] as Map<String, dynamic>),
      behavior: BehaviorConfig.fromMap(map['behavior'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'size': size.toMap(),
      'position': position.toMap(),
      'behavior': behavior.toMap(),
    };
  }
}

/// Window size configuration
class SizeConfig {
  final String windowWidth;
  final String windowHeight;

  const SizeConfig({required this.windowWidth, required this.windowHeight});

  factory SizeConfig.fromMap(Map<String, dynamic> map) {
    return SizeConfig(
      windowWidth: map['windowWidth'] as String? ?? '80%',
      windowHeight: map['windowHeight'] as String? ?? '60%',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
    };
  }
}

/// Window position configuration
class PositionConfig {
  final String horizontalPosition;
  final String verticalPosition;
  final MarginConfig? margin;

  const PositionConfig({
    required this.horizontalPosition,
    required this.verticalPosition,
    this.margin,
  });

  factory PositionConfig.fromMap(Map<String, dynamic> map) {
    return PositionConfig(
      horizontalPosition: map['horizontalPosition'] as String? ?? 'center',
      verticalPosition: map['verticalPosition'] as String? ?? 'center',
      margin: map['margin'] != null
          ? MarginConfig.fromMap(map['margin'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'horizontalPosition': horizontalPosition,
      'verticalPosition': verticalPosition,
      if (margin != null) 'margin': margin!.toMap(),
    };
  }
}

/// Margin configuration for window positioning
class MarginConfig {
  final double horizontal;
  final double vertical;

  const MarginConfig({required this.horizontal, required this.vertical});

  factory MarginConfig.fromMap(Map<String, dynamic> map) {
    return MarginConfig(
      horizontal: (map['horizontal'] as num?)?.toDouble() ?? 20.0,
      vertical: (map['vertical'] as num?)?.toDouble() ?? 20.0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'horizontal': horizontal, 'vertical': vertical};
  }
}

/// Window behavior configuration
class BehaviorConfig {
  final String windowLevel;
  final bool skipTaskbar;

  const BehaviorConfig({required this.windowLevel, required this.skipTaskbar});

  factory BehaviorConfig.fromMap(Map<String, dynamic> map) {
    return BehaviorConfig(
      windowLevel: map['windowLevel'] as String? ?? 'normal',
      skipTaskbar: map['skipTaskbar'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'windowLevel': windowLevel,
      'skipTaskbar': skipTaskbar,
    };
  }
}

/// System configuration
class SystemConfig {
  final int monitorIndex;

  const SystemConfig({required this.monitorIndex});

  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(monitorIndex: map['monitorIndex'] as int? ?? 0);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'monitorIndex': monitorIndex};
  }
}

/// Global settings
class GlobalSettings {
  final String theme;
  final bool animations;
  final bool autoHide;
  final String defaultImageType;
  final String defaultActionType;

  const GlobalSettings({
    required this.theme,
    required this.animations,
    required this.autoHide,
    required this.defaultImageType,
    required this.defaultActionType,
  });

  factory GlobalSettings.fromMap(Map<String, dynamic> map) {
    return GlobalSettings(
      theme: map['theme'] as String? ?? 'light',
      animations: map['animations'] as bool? ?? true,
      autoHide: map['autoHide'] as bool? ?? false,
      defaultImageType: map['defaultImageType'] as String? ?? 'default',
      defaultActionType: map['defaultActionType'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'theme': theme,
      'animations': animations,
      'autoHide': autoHide,
      'defaultImageType': defaultImageType,
      'defaultActionType': defaultActionType,
    };
  }
}

/// Individual layout element that can be any widget type
class LayoutElement {
  final String type;
  final Map<String, dynamic>? properties;
  final List<LayoutElement>? children;
  final LayoutElement? child;

  const LayoutElement({
    required this.type,
    this.properties,
    this.children,
    this.child,
  });

  factory LayoutElement.fromMap(Map<String, dynamic> map) {
    final Map<String, dynamic> props = Map<String, dynamic>.from(map);
    props.remove('type');
    props.remove('children');
    props.remove('child');

    return LayoutElement(
      type: map['type'] as String,
      properties: props.isNotEmpty ? props : null,
      children: map['children'] != null
          ? (map['children'] as List<dynamic>)
                .map((x) => LayoutElement.fromMap(x as Map<String, dynamic>))
                .toList()
          : null,
      child: map['child'] != null
          ? LayoutElement.fromMap(map['child'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'type': type,
      if (properties != null) ...properties!,
      if (children != null)
        'children': children!.map((LayoutElement x) => x.toMap()).toList(),
      if (child != null) 'child': child!.toMap(),
    };
    return map;
  }

  /// Get property value with default fallback
  T? getProperty<T>(String key, [T? defaultValue]) {
    final value = properties?[key];
    if (value is T) return value;
    return defaultValue;
  }

  /// Check if this is a launcher element
  bool get isLauncher => type == 'launcher';

  /// Get launcher reference if this is a launcher element
  String? get launcherRef => getProperty<String>('launcherRef');

  /// Get launcher overrides if this is a launcher element
  Map<String, dynamic>? get overrides =>
      getProperty<Map<String, dynamic>>('overrides');
}
