enum HorizontalPosition { left, center, right }

enum VerticalPosition { top, center, bottom }

enum WindowLevel { normal, alwaysOnTop, alwaysBelow }

class AppSettings {
  final double backgroundOpacity;
  final double appBarOpacity;
  final String windowWidth;
  final String windowHeight;
  final bool skipTaskbar;
  final bool showAppBar;
  final WindowLevel windowLevel;
  final HorizontalPosition horizontalPosition;
  final VerticalPosition verticalPosition;
  final int monitorIndex;
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
    this.monitorIndex = 0,
    this.appBarColor = '#FFFFFF',
    this.backgroundColor = '#FFFFFF',
  });
  factory AppSettings.fromMap(Map<String, dynamic> map) {
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

    int parseMonitorIndex(dynamic value) {
      if (value is int) {
        return value.clamp(0, 4);
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
      return 1;
    }

    String parseWindowSize(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.endsWith('%')) {
          final String percentStr = trimmed.substring(0, trimmed.length - 1);
          final double? percent = double.tryParse(percentStr);
          if (percent != null && percent > 0 && percent <= 100) {
            return trimmed;
          }
        } else {
          final double? absoluteValue = double.tryParse(trimmed);
          if (absoluteValue != null && absoluteValue > 0) {
            return trimmed;
          }
        }
        return defaultValue;
      }
      if (value is num) {
        return value.toDouble().toString();
      }
      return defaultValue;
    }

    String parseBackgroundColor(dynamic value) {
      if (value == null) return '#00000000';
      if (value is String) {
        final String trimmed = value.trim();
        if (RegExp(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$').hasMatch(trimmed)) {
          return trimmed;
        }
      }
      return '#00000000';
    }

    String parseAppBarColor(dynamic value) {
      if (value == null) return '';
      if (value is String) {
        final String trimmed = value.trim();
        if (trimmed.isEmpty) return '';
        if (RegExp(r'^#[0-9A-Fa-f]{6}$|^#[0-9A-Fa-f]{8}$').hasMatch(trimmed)) {
          return trimmed;
        }
      }
      return '';
    }

    return AppSettings(
      backgroundOpacity: (map['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,
      appBarOpacity: (map['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      windowWidth: parseWindowSize(map['windowWidth'], '800'),
      windowHeight: parseWindowSize(map['windowHeight'], '600'),
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
      backgroundColor: parseBackgroundColor(map['backgroundColor']),
      appBarColor: parseAppBarColor(map['appBarColor']),
    );
  }
  Map<String, dynamic> toMap() {
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
      'backgroundColor': backgroundColor,
      'appBarColor': appBarColor,
    };
  }

  @override
  String toString() {
    return 'AppSettings(backgroundOpacity: $backgroundOpacity, appBarOpacity: $appBarOpacity, size: ${windowWidth}x$windowHeight, skipTaskbar: $skipTaskbar, showAppBar: $showAppBar, windowLevel: $windowLevel, position: $horizontalPosition-$verticalPosition, monitorIndex: $monitorIndex, backgroundColor: $backgroundColor, appBarColor: $appBarColor)';
  }
}
