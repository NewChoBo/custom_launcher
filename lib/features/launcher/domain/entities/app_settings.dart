import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final String mode;
  final UiSettings ui;
  final WindowSettings window;
  final SystemSettings system;

  const AppSettings({
    required this.mode,
    required this.ui,
    required this.window,
    required this.system,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      mode: json['mode'] as String,
      ui: UiSettings.fromJson(json['ui'] as Map<String, dynamic>),
      window: WindowSettings.fromJson(json['window'] as Map<String, dynamic>),
      system: SystemSettings.fromJson(json['system'] as Map<String, dynamic>),
    );
  }

  AppSettings copyWith({
    String? mode,
    UiSettings? ui,
    WindowSettings? window,
    SystemSettings? system,
  }) {
    return AppSettings(
      mode: mode ?? this.mode,
      ui: ui ?? this.ui,
      window: window ?? this.window,
      system: system ?? this.system,
    );
  }

  @override
  List<Object?> get props => [mode, ui, window, system];
}

class UiSettings extends Equatable {
  final bool showAppBar;
  final ColorsSettings colors;
  final OpacitySettings opacity;

  const UiSettings({
    required this.showAppBar,
    required this.colors,
    required this.opacity,
  });

  factory UiSettings.fromJson(Map<String, dynamic> json) {
    return UiSettings(
      showAppBar: json['showAppBar'] as bool,
      colors: ColorsSettings.fromJson(json['colors'] as Map<String, dynamic>),
      opacity: OpacitySettings.fromJson(
        json['opacity'] as Map<String, dynamic>,
      ),
    );
  }

  UiSettings copyWith({
    bool? showAppBar,
    ColorsSettings? colors,
    OpacitySettings? opacity,
  }) {
    return UiSettings(
      showAppBar: showAppBar ?? this.showAppBar,
      colors: colors ?? this.colors,
      opacity: opacity ?? this.opacity,
    );
  }

  @override
  List<Object?> get props => [showAppBar, colors, opacity];
}

class ColorsSettings extends Equatable {
  final String appBarColor;
  final String backgroundColor;

  const ColorsSettings({
    required this.appBarColor,
    required this.backgroundColor,
  });

  factory ColorsSettings.fromJson(Map<String, dynamic> json) {
    return ColorsSettings(
      appBarColor: json['appBarColor'] as String,
      backgroundColor: json['backgroundColor'] as String,
    );
  }

  ColorsSettings copyWith({String? appBarColor, String? backgroundColor}) {
    return ColorsSettings(
      appBarColor: appBarColor ?? this.appBarColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  @override
  List<Object?> get props => [appBarColor, backgroundColor];
}

class OpacitySettings extends Equatable {
  final double appBarOpacity;
  final double backgroundOpacity;

  const OpacitySettings({
    required this.appBarOpacity,
    required this.backgroundOpacity,
  });

  factory OpacitySettings.fromJson(Map<String, dynamic> json) {
    return OpacitySettings(
      appBarOpacity: (json['appBarOpacity'] as num).toDouble(),
      backgroundOpacity: (json['backgroundOpacity'] as num).toDouble(),
    );
  }

  OpacitySettings copyWith({double? appBarOpacity, double? backgroundOpacity}) {
    return OpacitySettings(
      appBarOpacity: appBarOpacity ?? this.appBarOpacity,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    );
  }

  @override
  List<Object?> get props => [appBarOpacity, backgroundOpacity];
}

class WindowSettings extends Equatable {
  final SizeSettings size;
  final PositionSettings position;
  final BehaviorSettings behavior;

  const WindowSettings({
    required this.size,
    required this.position,
    required this.behavior,
  });

  factory WindowSettings.fromJson(Map<String, dynamic> json) {
    return WindowSettings(
      size: SizeSettings.fromJson(json['size'] as Map<String, dynamic>),
      position: PositionSettings.fromJson(
        json['position'] as Map<String, dynamic>,
      ),
      behavior: BehaviorSettings.fromJson(
        json['behavior'] as Map<String, dynamic>,
      ),
    );
  }

  WindowSettings copyWith({
    SizeSettings? size,
    PositionSettings? position,
    BehaviorSettings? behavior,
  }) {
    return WindowSettings(
      size: size ?? this.size,
      position: position ?? this.position,
      behavior: behavior ?? this.behavior,
    );
  }

  @override
  List<Object?> get props => [size, position, behavior];
}

class SizeSettings extends Equatable {
  final String windowWidth;
  final String windowHeight;

  const SizeSettings({required this.windowWidth, required this.windowHeight});

  factory SizeSettings.fromJson(Map<String, dynamic> json) {
    return SizeSettings(
      windowWidth: json['windowWidth'] as String,
      windowHeight: json['windowHeight'] as String,
    );
  }

  SizeSettings copyWith({String? windowWidth, String? windowHeight}) {
    return SizeSettings(
      windowWidth: windowWidth ?? this.windowWidth,
      windowHeight: windowHeight ?? this.windowHeight,
    );
  }

  @override
  List<Object?> get props => [windowWidth, windowHeight];
}

class PositionSettings extends Equatable {
  final String horizontalPosition;
  final String verticalPosition;
  final MarginSettings margin;

  const PositionSettings({
    required this.horizontalPosition,
    required this.verticalPosition,
    this.margin = const MarginSettings(),
  });

  factory PositionSettings.fromJson(Map<String, dynamic> json) {
    return PositionSettings(
      horizontalPosition: json['horizontalPosition'] as String,
      verticalPosition: json['verticalPosition'] as String,
      margin: json['margin'] != null
          ? MarginSettings.fromJson(json['margin'] as Map<String, dynamic>)
          : const MarginSettings(),
    );
  }

  PositionSettings copyWith({
    String? horizontalPosition,
    String? verticalPosition,
    MarginSettings? margin,
  }) {
    return PositionSettings(
      horizontalPosition: horizontalPosition ?? this.horizontalPosition,
      verticalPosition: verticalPosition ?? this.verticalPosition,
      margin: margin ?? this.margin,
    );
  }

  @override
  List<Object?> get props => [horizontalPosition, verticalPosition, margin];
}

class MarginSettings extends Equatable {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const MarginSettings({
    this.top = 0.0,
    this.right = 0.0,
    this.bottom = 0.0,
    this.left = 0.0,
  });

  factory MarginSettings.fromJson(Map<String, dynamic> json) {
    return MarginSettings(
      top: (json['top'] as num?)?.toDouble() ?? 0.0,
      right: (json['right'] as num?)?.toDouble() ?? 0.0,
      bottom: (json['bottom'] as num?)?.toDouble() ?? 0.0,
      left: (json['left'] as num?)?.toDouble() ?? 0.0,
    );
  }

  MarginSettings copyWith({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) {
    return MarginSettings(
      top: top ?? this.top,
      right: right ?? this.right,
      bottom: bottom ?? this.bottom,
      left: left ?? this.left,
    );
  }

  @override
  List<Object?> get props => [top, right, bottom, left];
}

class BehaviorSettings extends Equatable {
  final String windowLevel;
  final bool skipTaskbar;

  const BehaviorSettings({
    required this.windowLevel,
    required this.skipTaskbar,
  });

  factory BehaviorSettings.fromJson(Map<String, dynamic> json) {
    return BehaviorSettings(
      windowLevel: json['windowLevel'] as String,
      skipTaskbar: json['skipTaskbar'] as bool,
    );
  }

  BehaviorSettings copyWith({String? windowLevel, bool? skipTaskbar}) {
    return BehaviorSettings(
      windowLevel: windowLevel ?? this.windowLevel,
      skipTaskbar: skipTaskbar ?? this.skipTaskbar,
    );
  }

  @override
  List<Object?> get props => [windowLevel, skipTaskbar];
}

class SystemSettings extends Equatable {
  final int monitorIndex;

  const SystemSettings({required this.monitorIndex});

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(monitorIndex: json['monitorIndex'] as int);
  }

  SystemSettings copyWith({int? monitorIndex}) {
    return SystemSettings(monitorIndex: monitorIndex ?? this.monitorIndex);
  }

  @override
  List<Object?> get props => [monitorIndex];
}
