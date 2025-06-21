import 'package:custom_launcher/models/launcher_item.dart';

/// Layout mode for launcher items
enum LauncherLayoutMode {
  /// Free positioning (drag and drop)
  freeform,

  /// Grid layout with fixed columns
  grid,

  /// Horizontal list
  horizontalList,

  /// Vertical list
  verticalList,
}

/// Text position relative to icon
enum TextPosition {
  /// Text above icon
  above,

  /// Text below icon
  below,

  /// Text to the right of icon
  right,

  /// Text to the left of icon
  left,

  /// No text display
  none,
}

/// Click behavior for launcher items
enum ClickBehavior {
  /// Single click to launch
  singleClick,

  /// Double click to launch
  doubleClick,
}

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

  // Launcher-specific settings
  final List<LauncherItem> launcherItems;
  final LauncherLayoutMode layoutMode;
  final TextPosition textPosition;
  final ClickBehavior clickBehavior;
  final bool showIcons;
  final bool showText;
  final int gridColumns; // For grid layout mode
  final double itemSpacing; // Spacing between items
  final double iconSize; // Icon size in pixels

  const AppSettings({
    this.backgroundOpacity = 1.0,
    this.appBarOpacity = 1.0,
    this.windowWidth = "800",
    this.windowHeight = "600",
    this.skipTaskbar = true,
    this.showAppBar = true,
    this.windowLevel = WindowLevel.normal,
    this.horizontalPosition = HorizontalPosition.center,
    this.verticalPosition = VerticalPosition.center,
    this.monitorIndex = 1, // Default to first monitor
    this.launcherItems = const [],
    this.layoutMode = LauncherLayoutMode.grid,
    this.textPosition = TextPosition.below,
    this.clickBehavior = ClickBehavior.singleClick,
    this.showIcons = true,
    this.showText = true,
    this.gridColumns = 4,
    this.itemSpacing = 16.0,
    this.iconSize = 48.0,
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
    }

    // Parse monitor index from string or number
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

    // Parse launcher layout mode from string
    LauncherLayoutMode parseLayoutMode(String? value) {
      switch (value?.toLowerCase()) {
        case 'freeform':
          return LauncherLayoutMode.freeform;
        case 'grid':
          return LauncherLayoutMode.grid;
        case 'horizontallist':
        case 'horizontal_list':
          return LauncherLayoutMode.horizontalList;
        case 'verticallist':
        case 'vertical_list':
          return LauncherLayoutMode.verticalList;
        default:
          return LauncherLayoutMode.grid;
      }
    }

    // Parse text position from string
    TextPosition parseTextPosition(String? value) {
      switch (value?.toLowerCase()) {
        case 'above':
          return TextPosition.above;
        case 'below':
          return TextPosition.below;
        case 'right':
          return TextPosition.right;
        case 'left':
          return TextPosition.left;
        case 'none':
          return TextPosition.none;
        default:
          return TextPosition.below;
      }
    }

    // Parse click behavior from string
    ClickBehavior parseClickBehavior(String? value) {
      switch (value?.toLowerCase()) {
        case 'singleclick':
        case 'single_click':
        case 'single':
          return ClickBehavior.singleClick;
        case 'doubleclick':
        case 'double_click':
        case 'double':
          return ClickBehavior.doubleClick;
        default:
          return ClickBehavior.singleClick;
      }
    } // Parse launcher items from list

    List<LauncherItem> parseLauncherItems(dynamic value) {
      if (value is! List) return [];

      return value
          .whereType<Map<String, dynamic>>()
          .map((item) {
            try {
              return LauncherItem.fromJson(item);
            } catch (e) {
              // Skip invalid items
              return null;
            }
          })
          .whereType<LauncherItem>()
          .toList();
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
      showAppBar: map['showAppBar'] as bool? ?? false,
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
      launcherItems: parseLauncherItems(map['launcherItems']),
      layoutMode: parseLayoutMode(map['layoutMode'] as String?),
      textPosition: parseTextPosition(map['textPosition'] as String?),
      clickBehavior: parseClickBehavior(map['clickBehavior'] as String?),
      showIcons: map['showIcons'] as bool? ?? true,
      showText: map['showText'] as bool? ?? true,
      gridColumns: (map['gridColumns'] as num?)?.toInt() ?? 4,
      itemSpacing: (map['itemSpacing'] as num?)?.toDouble() ?? 16.0,
      iconSize: (map['iconSize'] as num?)?.toDouble() ?? 48.0,
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

    // Convert layout mode to string
    String layoutModeToString(LauncherLayoutMode mode) {
      switch (mode) {
        case LauncherLayoutMode.freeform:
          return 'freeform';
        case LauncherLayoutMode.grid:
          return 'grid';
        case LauncherLayoutMode.horizontalList:
          return 'horizontalList';
        case LauncherLayoutMode.verticalList:
          return 'verticalList';
      }
    }

    // Convert text position to string
    String textPositionToString(TextPosition position) {
      switch (position) {
        case TextPosition.above:
          return 'above';
        case TextPosition.below:
          return 'below';
        case TextPosition.right:
          return 'right';
        case TextPosition.left:
          return 'left';
        case TextPosition.none:
          return 'none';
      }
    }

    // Convert click behavior to string
    String clickBehaviorToString(ClickBehavior behavior) {
      switch (behavior) {
        case ClickBehavior.singleClick:
          return 'singleClick';
        case ClickBehavior.doubleClick:
          return 'doubleClick';
      }
    }

    return {
      'backgroundOpacity': backgroundOpacity,
      'appBarOpacity': appBarOpacity,
      'windowWidth': windowWidth,
      'windowHeight': windowHeight,
      'skipTaskbar': skipTaskbar,
      'showAppBar': showAppBar,
      'windowLevel': windowLevelToString(windowLevel),
      'horizontalPosition': horizontalPositionToString(horizontalPosition),
      'verticalPosition': verticalPositionToString(verticalPosition),
      'monitorIndex': monitorIndex,
      'launcherItems': launcherItems.map((item) => item.toJson()).toList(),
      'layoutMode': layoutModeToString(layoutMode),
      'textPosition': textPositionToString(textPosition),
      'clickBehavior': clickBehaviorToString(clickBehavior),
      'showIcons': showIcons,
      'showText': showText,
      'gridColumns': gridColumns,
      'itemSpacing': itemSpacing,
      'iconSize': iconSize,
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar, showAppBar: $showAppBar, windowLevel: $windowLevel, position: $horizontalPosition-$verticalPosition, monitorIndex: $monitorIndex, launcherItems: ${launcherItems.length} items)';
  }
}
