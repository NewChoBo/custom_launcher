/// Window level for z-order management
enum WindowLevel {
  /// Normal window behavior (default)
  normal,

  /// Always stay on top of other windows
  alwaysOnTop,

  /// Always stay below other windows
  alwaysBelow,
}

/// Application settings model
class AppSettings {
  final double backgroundOpacity;
  final double appBarOpacity;
  final double windowWidth;
  final double windowHeight;
  final bool skipTaskbar;
  final WindowLevel windowLevel;
  const AppSettings({
    this.backgroundOpacity = 1.0,
    this.appBarOpacity = 1.0,
    this.windowWidth = 800.0,
    this.windowHeight = 600.0,
    this.skipTaskbar = true,
    this.windowLevel = WindowLevel.normal,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    // Parse window level from string
    WindowLevel parseWindowLevel(String? value) {
      switch (value?.toLowerCase()) {
        case 'alwaysontop':
        case 'always_on_top':
        case 'top':
          return WindowLevel.alwaysOnTop;
        case 'alwaysbelow':
        case 'always_below':
        case 'below':
        case 'bottom':
          return WindowLevel.alwaysBelow;
        default:
          return WindowLevel.normal;
      }
    }

    return AppSettings(
      backgroundOpacity: (map['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
      appBarOpacity: (map['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      windowWidth: (map['windowWidth'] as num?)?.toDouble() ?? 800.0,
      windowHeight: (map['windowHeight'] as num?)?.toDouble() ?? 600.0,
      skipTaskbar: map['skipTaskbar'] as bool? ?? true,
      windowLevel: parseWindowLevel(map['windowLevel'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    // Convert window level to string
    String windowLevelToString(WindowLevel level) {
      switch (level) {
        case WindowLevel.alwaysOnTop:
          return 'alwaysOnTop';
        case WindowLevel.alwaysBelow:
          return 'alwaysBelow';
        case WindowLevel.normal:
          return 'normal';
      }
    }

    return {
      'backgroundOpacity': backgroundOpacity,
      'appBarOpacity': appBarOpacity,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'skipTaskbar': skipTaskbar,
      'windowLevel': windowLevelToString(windowLevel),
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar, windowLevel: $windowLevel)';
  }
}
