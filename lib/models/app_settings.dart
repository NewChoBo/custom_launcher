/// Application settings model
/// Contains user-configurable settings loaded from YAML file
class AppSettings {
  final double backgroundOpacity;
  final double appBarOpacity;
  final double windowWidth;
  final double windowHeight;
  final bool skipTaskbar;

  const AppSettings({
    this.backgroundOpacity = 1.0,
    this.appBarOpacity = 1.0,
    this.windowWidth = 800.0,
    this.windowHeight = 600.0,
    this.skipTaskbar = true,
  });

  /// Create settings from YAML map
  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      backgroundOpacity: (map['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
      appBarOpacity: (map['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      windowWidth: (map['windowWidth'] as num?)?.toDouble() ?? 800.0,
      windowHeight: (map['windowHeight'] as num?)?.toDouble() ?? 600.0,
      skipTaskbar: map['skipTaskbar'] as bool? ?? true,
    );
  }

  /// Convert settings to YAML-compatible map
  Map<String, dynamic> toMap() {
    return {
      'backgroundOpacity': backgroundOpacity,
      'appBarOpacity': appBarOpacity,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'skipTaskbar': skipTaskbar,
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar)';
  }
}
