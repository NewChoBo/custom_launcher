import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/entities/window_enums.dart';
import 'package:custom_launcher/core/logging/logging.dart';

class WindowService {
  static Future<void> initialize([AppSettings? settings]) async {
    final AppSettings config =
        settings ??
        const AppSettings(
          mode: 'default',
          ui: UiSettings(
            showAppBar: false,
            colors: ColorsSettings(
              appBarColor: '#2196F3',
              backgroundColor: '#424242',
            ),
            opacity: OpacitySettings(
              appBarOpacity: 0.5,
              backgroundOpacity: 0.1,
            ),
          ),
          window: WindowSettings(
            size: SizeSettings(windowWidth: '80%', windowHeight: '50%'),
            position: PositionSettings(
              horizontalPosition: 'center',
              verticalPosition: 'bottom',
            ),
            behavior: BehaviorSettings(
              windowLevel: 'normal',
              skipTaskbar: true,
            ),
          ),
          system: SystemSettings(monitorIndex: 0),
        );

    await windowManager.ensureInitialized();

    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final Size initialSize = _calculateWindowSize(
      config.window.size.windowWidth,
      config.window.size.windowHeight,
      primaryDisplay,
      config.window.position.margin,
    );

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: initialSize,
        center: false,
        backgroundColor: Colors.transparent,
        skipTaskbar: config.window.behavior.skipTaskbar,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
        alwaysOnTop:
            config.window.behavior.windowLevel == WindowLevel.alwaysOnTop.name,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);
        await windowManager.setAsFrameless();
        await _applyWindowPosition(config);
        await _configureWindowLevel(config.window.behavior.windowLevel);

        LogManager.info(
          'Window initialized with settings: $config',
          tag: 'WindowService',
        );
      },
    );
  }

  static Future<void> _applyWindowPosition(AppSettings config) async {
    try {
      final Display targetDisplay = await _getTargetDisplay(
        config.system.monitorIndex,
      );

      final Size size = _calculateWindowSize(
        config.window.size.windowWidth,
        config.window.size.windowHeight,
        targetDisplay,
        config.window.position.margin,
      );

      final Alignment alignment = _getAlignmentFromPosition(
        config.window.position.horizontalPosition,
        config.window.position.verticalPosition,
      );

      final Offset position = await _calcWindowPositionForDisplay(
        size,
        alignment,
        targetDisplay,
        config.window.position.margin,
      );

      LogManager.debug(
        'Setting window size to: $size and position to: $position (alignment: $alignment, display: ${targetDisplay.size})',
        tag: 'WindowService',
      );

      await windowManager.setSize(size);
      await windowManager.setPosition(position);
    } on Object catch (e) {
      LogManager.error(
        'Error applying window position',
        tag: 'WindowService',
        error: e,
      );
      await windowManager.center();
    }
  }

  static Alignment _getAlignmentFromPosition(
    String horizontal,
    String vertical,
  ) {
    final HorizontalPosition horizontalEnum = HorizontalPosition.values
        .firstWhere(
          (e) => e.name == horizontal,
          orElse: () => HorizontalPosition.center,
        );
    final VerticalPosition verticalEnum = VerticalPosition.values.firstWhere(
      (e) => e.name == vertical,
      orElse: () => VerticalPosition.bottom,
    );

    const List<List<Alignment>> alignments = <List<Alignment>>[
      <Alignment>[Alignment.topLeft, Alignment.topCenter, Alignment.topRight],
      <Alignment>[
        Alignment.centerLeft,
        Alignment.center,
        Alignment.centerRight,
      ],
      <Alignment>[
        Alignment.bottomLeft,
        Alignment.bottomCenter,
        Alignment.bottomRight,
      ],
    ];

    final int verticalIndex = verticalEnum == VerticalPosition.top
        ? 0
        : verticalEnum == VerticalPosition.center
        ? 1
        : 2;
    final int horizontalIndex = horizontalEnum == HorizontalPosition.left
        ? 0
        : horizontalEnum == HorizontalPosition.center
        ? 1
        : 2;

    return alignments[verticalIndex][horizontalIndex];
  }

  static Future<void> _configureWindowLevel(String level) async {
    try {
      final WindowLevel windowLevel = WindowLevel.values.firstWhere(
        (e) => e.name == level,
        orElse: () => WindowLevel.normal,
      );

      LogManager.debug(
        'Configuring window level: $windowLevel',
        tag: 'WindowService',
      );

      switch (windowLevel) {
        case WindowLevel.alwaysOnTop:
          LogManager.debug(
            'Setting window to always on top',
            tag: 'WindowService',
          );
          try {
            await windowManager.setAlwaysOnBottom(false);
          } on Object catch (e) {
            LogManager.warn(
              'setAlwaysOnBottom not available or failed',
              tag: 'WindowService',
              error: e,
            );
          }

          await Future.delayed(const Duration(milliseconds: 50));
          await windowManager.setAlwaysOnTop(true);
          LogManager.info('Always on top enabled', tag: 'WindowService');
          break;

        case WindowLevel.alwaysBelow:
          LogManager.debug(
            'Setting window to always below',
            tag: 'WindowService',
          );

          await windowManager.setAlwaysOnTop(false);
          await Future.delayed(const Duration(milliseconds: 50));

          try {
            await windowManager.setAlwaysOnBottom(true);
            LogManager.info('Always below enabled', tag: 'WindowService');
          } on Object catch (e) {
            LogManager.warn(
              'setAlwaysOnBottom not supported on this platform',
              tag: 'WindowService',
              error: e,
            );
          }
          break;

        case WindowLevel.normal:
          LogManager.debug(
            'Setting window to normal level',
            tag: 'WindowService',
          );
          await windowManager.setAlwaysOnTop(false);
          try {
            await windowManager.setAlwaysOnBottom(false);
          } on Object catch (e) {
            LogManager.warn(
              'setAlwaysOnBottom not available',
              tag: 'WindowService',
              error: e,
            );
          }
          LogManager.info('Normal window level set', tag: 'WindowService');
          break;
      }
    } on Object catch (e) {
      LogManager.error(
        'Error configuring window level',
        tag: 'WindowService',
        error: e,
      );
    }
  }

  static Future<Display> _getTargetDisplay(int monitorIndex) async {
    try {
      final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
      final List<Display> allDisplays = await screenRetriever.getAllDisplays();

      LogManager.debug(
        'Available displays: ${allDisplays.length}',
        tag: 'WindowService',
      );
      for (int i = 0; i < allDisplays.length; i++) {
        final Display display = allDisplays[i];
        LogManager.debug(
          'Display $i: ${display.size} at ${display.visiblePosition}',
          tag: 'WindowService',
        );
      }
      if (monitorIndex == 0) {
        final Offset cursorPos = await screenRetriever.getCursorScreenPoint();
        return allDisplays.firstWhere((Display display) {
          final Size displaySize = display.visibleSize ?? display.size;
          final Rect displayRect = Rect.fromLTWH(
            display.visiblePosition?.dx ?? 0,
            display.visiblePosition?.dy ?? 0,
            displaySize.width,
            displaySize.height,
          );
          return displayRect.contains(cursorPos);
        }, orElse: () => primaryDisplay);
      } else {
        final int displayIndex = monitorIndex - 1;
        if (displayIndex >= 0 && displayIndex < allDisplays.length) {
          return allDisplays[displayIndex];
        } else {
          LogManager.warn(
            'Monitor $monitorIndex not available (only ${allDisplays.length} displays), falling back to Monitor 1',
            tag: 'WindowService',
          );
          return allDisplays.isNotEmpty ? allDisplays[0] : primaryDisplay;
        }
      }
    } on Object catch (e) {
      LogManager.error(
        'Error getting target display',
        tag: 'WindowService',
        error: e,
      );
      return await screenRetriever.getPrimaryDisplay();
    }
  }

  static Future<Offset> _calcWindowPositionForDisplay(
    Size windowSize,
    Alignment alignment,
    Display display,
    MarginSettings margin,
  ) async {
    final Size screenSize = display.visibleSize ?? display.size;
    final Offset screenOffset = display.visiblePosition ?? const Offset(0, 0);

    LogManager.debug(
      'Screen size: $screenSize, offset: $screenOffset, margin: $margin',
      tag: 'WindowService',
    );

    double x = screenOffset.dx;
    double y = screenOffset.dy;

    if (alignment == Alignment.topLeft) {
      x += margin.left;
      y += margin.top;
    } else if (alignment == Alignment.topCenter) {
      x += (screenSize.width - windowSize.width) / 2;
      y += margin.top;
    } else if (alignment == Alignment.topRight) {
      x += screenSize.width - windowSize.width - margin.right;
      y += margin.top;
    } else if (alignment == Alignment.centerLeft) {
      x += margin.left;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.center) {
      x += (screenSize.width - windowSize.width) / 2;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.centerRight) {
      x += screenSize.width - windowSize.width - margin.right;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.bottomLeft) {
      x += margin.left;
      y += screenSize.height - windowSize.height - margin.bottom;
    } else if (alignment == Alignment.bottomCenter) {
      x += (screenSize.width - windowSize.width) / 2;
      y += screenSize.height - windowSize.height - margin.bottom;
    } else if (alignment == Alignment.bottomRight) {
      x += screenSize.width - windowSize.width - margin.right;
      y += screenSize.height - windowSize.height - margin.bottom;
    }

    return Offset(x, y);
  }

  static Size _calculateWindowSize(
    String widthStr,
    String heightStr,
    Display display,
    MarginSettings margin,
  ) {
    final Size screenSize = display.visibleSize ?? display.size;
    double width = 0.0;
    if (widthStr.endsWith('%')) {
      final String percentStr = widthStr.substring(0, widthStr.length - 1);
      final double percent = double.tryParse(percentStr) ?? 80.0;
      width =
          screenSize.width * (percent / 100.0) - (margin.left + margin.right);
    } else {
      width = double.tryParse(widthStr) ?? 800.0;
    }

    double height = 0.0;
    if (heightStr.endsWith('%')) {
      final String percentStr = heightStr.substring(0, heightStr.length - 1);
      final double percent = double.tryParse(percentStr) ?? 60.0;
      height =
          screenSize.height * (percent / 100.0) - (margin.top + margin.bottom);
    } else {
      height = double.tryParse(heightStr) ?? 600.0;
    }

    width = width.clamp(200.0, screenSize.width - (margin.left + margin.right));
    height = height.clamp(
      150.0,
      screenSize.height - (margin.top + margin.bottom),
    );

    return Size(width, height);
  }
}
