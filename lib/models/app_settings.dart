/// Horizontal position for window placement
enum HorizontalPosition {
  /// Position window on the left side of screen
  left,

  /// Position window in the center horizontally
  center,

  /// Position window on the right side of screen
  right,
}

/// Vertical position for window placement
enum VerticalPosition {
  /// Position window at the top of screen
  top,

  /// Position window in the center vertically
  center,

  /// Position window at the bottom of screen
  bottom,
}

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
  final String windowWidth; // Support both "800" and "80%" formats
  final String windowHeight; // Support both "600" and "50%" formats
  final bool skipTaskbar;
  final bool showAppBar; // Control AppBar visibility
  final WindowLevel windowLevel;
  final HorizontalPosition horizontalPosition;
  final VerticalPosition verticalPosition;
  final int monitorIndex; // 1, 2, 3, 4... or 0 for auto
  final String appBarColor;
  final String backgroundColor;

  const AppSettings({
    this.backgroundOpacity = 1.0,
    this.appBarOpacity = 1.0,
    this.windowWidth = '800',
    this.windowHeight = '600',
    this.skipTaskbar = true,
    this.showAppBar = true,
    this.windowLevel = WindowLevel.normal,
    this.horizontalPosition = HorizontalPosition.center,
    this.verticalPosition = VerticalPosition.center,
    this.monitorIndex = 1,
    this.backgroundColor = '#00000000',
    this.appBarColor = '', // Default to empty (use theme color)
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

    // Parse horizontal position from string
    HorizontalPosition parseHorizontalPosition(String? value) {
      switch (value?.toLowerCase()) {
        case 'left':
          return HorizontalPosition.left;
        case 'right':
          return HorizontalPosition.right;
        case 'center':
        default:
          return HorizontalPosition.center;
      }
    }

    // Parse vertical position from string
    VerticalPosition parseVerticalPosition(String? value) {
      switch (value?.toLowerCase()) {
        case 'top':
          return VerticalPosition.top;
        case 'bottom':
          return VerticalPosition.bottom;
        case 'center':
        default:
          return VerticalPosition.center;
      }
    } // Parse monitor index from string or number

    int parseMonitorIndex(dynamic value) {
      if (value is int) {
        return value.clamp(0, 4); // 0 = auto, 1-4 = monitor numbers
      }

      if (value is String) {
        switch (value.toLowerCase()) {
          case 'auto':
            return 0;
          case '1':
          case 'monitor1':
            return 1;
          case '2':
          case 'monitor2':
            return 2;
          case '3':
          case 'monitor3':
            return 3;
          case '4':
          case 'monitor4':
            return 4;
          default:
            return int.tryParse(value)?.clamp(0, 4) ?? 1;
        }
      }
      return 1; // Default to monitor 1
    }

    // Parse window size (supports both absolute values and percentages)
    String parseWindowSize(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;

      if (value is String) {
        // Already a string, validate format
        final String trimmed = value.trim();
        if (trimmed.endsWith('%')) {
          // Percentage format: "80%"
          final String percentStr = trimmed.substring(0, trimmed.length - 1);
          final double? percent = double.tryParse(percentStr);
          if (percent != null && percent > 0 && percent <= 100) {
            return trimmed;
          }
        } else {
          // Absolute value as string: "800"
          final double? absoluteValue = double.tryParse(trimmed);
          if (absoluteValue != null && absoluteValue > 0) {
            return trimmed;
          }
        }
        return defaultValue; // Invalid format, use default
      }

      if (value is num) {
        // Convert number to string
        return value.toDouble().toString();
      }
      return defaultValue;
    } // Parse background color from string (hex format)

    String parseBackgroundColor(dynamic value) {
      if (value == null) return '#00000000'; // Default transparent

      if (value is String) {
        final String trimmed = value.trim();
        // Validate hex color format
        if (RegExp(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$').hasMatch(trimmed)) {
          return trimmed;
        }
      }

      return '#00000000'; // Fallback to transparent
    }

    // Parse AppBar color from string (hex format)
    String parseAppBarColor(dynamic value) {
      if (value == null) return ''; // Default to empty (use theme color)

      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isEmpty) return ''; // Empty means use theme color
        // Validate hex color format
        if (RegExp(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$').hasMatch(trimmed)) {
          return trimmed;
        }
      }

      return ''; // Fallback to theme color
    }

    // Extract nested sections
    final Map<String, dynamic> ui =
        map['ui'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> window =
        map['window'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> system =
        map['system'] as Map<String, dynamic>? ?? <String, dynamic>{};

    // Extract UI subsections
    final Map<String, dynamic> colors =
        ui['colors'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> opacity =
        ui['opacity'] as Map<String, dynamic>? ?? <String, dynamic>{};

    // Extract Window subsections
    final Map<String, dynamic> size =
        window['size'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> position =
        window['position'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> behavior =
        window['behavior'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AppSettings(
      // UI settings
      showAppBar: ui['showAppBar'] as bool? ?? false,
      appBarColor: parseAppBarColor(colors['appBarColor']),
      backgroundColor: parseBackgroundColor(colors['backgroundColor']),
      appBarOpacity: (opacity['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      backgroundOpacity:
          (opacity['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,

      // Window size settings
      windowWidth: parseWindowSize(size['windowWidth'], '800'),
      windowHeight: parseWindowSize(size['windowHeight'], '600'),

      // Window position settings
      horizontalPosition: parseHorizontalPosition(
        position['horizontalPosition'] as String?,
      ),
      verticalPosition: parseVerticalPosition(
        position['verticalPosition'] as String?,
      ),

      // Window behavior settings
      windowLevel: parseWindowLevel(behavior['windowLevel'] as String?),
      skipTaskbar: behavior['skipTaskbar'] as bool? ?? true,

      // System settings
      monitorIndex: parseMonitorIndex(
        system['monitorIndex'] ?? map['monitorTarget'],
      ),
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

    // Convert horizontal position to string
    String horizontalPositionToString(HorizontalPosition position) {
      switch (position) {
        case HorizontalPosition.left:
          return 'left';
        case HorizontalPosition.right:
          return 'right';
        case HorizontalPosition.center:
          return 'center';
      }
    }

    // Convert vertical position to string
    String verticalPositionToString(VerticalPosition position) {
      switch (position) {
        case VerticalPosition.top:
          return 'top';
        case VerticalPosition.bottom:
          return 'bottom';
        case VerticalPosition.center:
          return 'center';
      }
    }

    return <String, dynamic>{
      'ui': <String, Object>{
        'showAppBar': showAppBar,
        'colors': <String, String>{
          'appBarColor': appBarColor,
          'backgroundColor': backgroundColor,
        },
        'opacity': <String, double>{
          'appBarOpacity': appBarOpacity,
          'backgroundOpacity': backgroundOpacity,
        },
      },
      'window': <String, Map<String, Object>>{
        'size': <String, String>{
          'windowWidth': windowWidth,
          'windowHeight': windowHeight,
        },
        'position': <String, String>{
          'horizontalPosition': horizontalPositionToString(horizontalPosition),
          'verticalPosition': verticalPositionToString(verticalPosition),
        },
        'behavior': <String, Object>{
          'windowLevel': windowLevelToString(windowLevel),
          'skipTaskbar': skipTaskbar,
        },
      },
      'system': <String, int>{'monitorIndex': monitorIndex},
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar, showAppBar: $showAppBar, windowLevel: $windowLevel, position: $horizontalPosition-$verticalPosition, monitorIndex: $monitorIndex, backgroundColor: $backgroundColor, appBarColor: $appBarColor)';
  }
}
