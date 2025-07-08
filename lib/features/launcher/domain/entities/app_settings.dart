enum HorizontalPosition { left, center, right }

enum VerticalPosition { top, center, bottom }

enum WindowLevel { normal, alwaysOnTop, alwaysBelow }

class AppSettings {
  final String mode;
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
    this.mode = 'demo',
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
    this.appBarColor = '',
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
        return value;
      }
      return 0;
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

    final Map<String, dynamic> ui =
        map['ui'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> window =
        map['window'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> system =
        map['system'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final Map<String, dynamic> colors =
        ui['colors'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> opacity =
        ui['opacity'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final Map<String, dynamic> size =
        window['size'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> position =
        window['position'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> behavior =
        window['behavior'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AppSettings(
      mode: map['mode'] as String? ?? 'demo',

      showAppBar: ui['showAppBar'] as bool? ?? false,
      appBarColor: parseAppBarColor(colors['appBarColor']),
      backgroundColor: parseBackgroundColor(colors['backgroundColor']),
      appBarOpacity: (opacity['appBarOpacity'] as num?)?.toDouble() ?? 1.0,
      backgroundOpacity:
          (opacity['backgroundOpacity'] as num?)?.toDouble() ?? 1.0,

      windowWidth: parseWindowSize(size['windowWidth'], '800'),
      windowHeight: parseWindowSize(size['windowHeight'], '600'),

      horizontalPosition: parseHorizontalPosition(
        position['horizontalPosition'] as String?,
      ),
      verticalPosition: parseVerticalPosition(
        position['verticalPosition'] as String?,
      ),

      windowLevel: parseWindowLevel(behavior['windowLevel'] as String?),
      skipTaskbar: behavior['skipTaskbar'] as bool? ?? true,

      monitorIndex: parseMonitorIndex(
        system['monitorIndex'] ?? map['monitorTarget'],
      ),
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
      'mode': mode,
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
}
