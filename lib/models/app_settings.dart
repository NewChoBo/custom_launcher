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
  final WindowLevel windowLevel;
  final HorizontalPosition horizontalPosition;
  final VerticalPosition verticalPosition;
  final int monitorIndex; // 1, 2, 3, 4... or 0 for auto

  const AppSettings({
    this.backgroundOpacity = 1.0,
    this.appBarOpacity = 1.0,
    this.windowWidth = "800",
    this.windowHeight = "600",
    this.skipTaskbar = true,
    this.windowLevel = WindowLevel.normal,
    this.horizontalPosition = HorizontalPosition.center,
    this.verticalPosition = VerticalPosition.center,
    this.monitorIndex = 1, // Default to first monitor
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
        final trimmed = value.trim();
        if (trimmed.endsWith('%')) {
          // Percentage format: "80%"
          final percentStr = trimmed.substring(0, trimmed.length - 1);
          final percent = double.tryParse(percentStr);
          if (percent != null && percent > 0 && percent <= 100) {
            return trimmed;
          }
        } else {
          // Absolute value as string: "800"
          final absoluteValue = double.tryParse(trimmed);
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
    }

    return AppSettings(
      backgroundOpacity: (map['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
      appBarOpacity: (map['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      windowWidth: parseWindowSize(map['windowWidth'], "800"),
      windowHeight: parseWindowSize(map['windowHeight'], "600"),
      skipTaskbar: map['skipTaskbar'] as bool? ?? true,
      windowLevel: parseWindowLevel(map['windowLevel'] as String?),
      horizontalPosition: parseHorizontalPosition(
        map['horizontalPosition'] as String?,
      ),
      verticalPosition: parseVerticalPosition(
        map['verticalPosition'] as String?,
      ),
      monitorIndex: parseMonitorIndex(
        map['monitorIndex'] ?? map['monitorTarget'],
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

    return {
      'backgroundOpacity': backgroundOpacity,
      'appBarOpacity': appBarOpacity,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'skipTaskbar': skipTaskbar,
      'windowLevel': windowLevelToString(windowLevel),
      'horizontalPosition': horizontalPositionToString(horizontalPosition),
      'verticalPosition': verticalPositionToString(verticalPosition),
      'monitorIndex': monitorIndex,
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar, windowLevel: $windowLevel, position: $horizontalPosition-$verticalPosition, monitorIndex: $monitorIndex)';
  }
}
