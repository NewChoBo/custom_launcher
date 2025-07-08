import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';

class WindowService {
  static Future<void> initialize([AppSettings? settings]) async {
    final AppSettings config = settings ?? const AppSettings();

    await windowManager.ensureInitialized();

    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final Size initialSize = _calculateWindowSize(
      config.windowWidth,
      config.windowHeight,
      primaryDisplay,
    );

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: initialSize,
        center: false,
        backgroundColor: Colors.transparent,
        skipTaskbar: config.skipTaskbar,
        titleBarStyle: TitleBarStyle.hidden,
        windowButtonVisibility: false,
        alwaysOnTop: config.windowLevel == WindowLevel.alwaysOnTop,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);
        await windowManager.setAsFrameless();
        await _applyWindowPosition(config);
        await _configureWindowLevel(config.windowLevel);

        debugPrint('Window initialized with settings: $config');
      },
    );
  }

  static Future<void> _applyWindowPosition(AppSettings config) async {
    try {
      final Display targetDisplay = await _getTargetDisplay(
        config.monitorIndex,
      );

      final Size size = _calculateWindowSize(
        config.windowWidth,
        config.windowHeight,
        targetDisplay,
      );

      final Alignment alignment = _getAlignmentFromPosition(
        config.horizontalPosition,
        config.verticalPosition,
      );

      final Offset position = await _calcWindowPositionForDisplay(
        size,
        alignment,
        targetDisplay,
      );

      debugPrint(
        'Setting window size to: $size and position to: $position (alignment: $alignment, display: ${targetDisplay.size})',
      );

      await windowManager.setSize(size);
      await windowManager.setPosition(position);
    } catch (e) {
      debugPrint('Error applying window position: $e');
      await windowManager.center();
    }
  }

  static Future<Display> _getTargetDisplay(int monitorIndex) async {
    try {
      final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
      final List<Display> allDisplays = await screenRetriever.getAllDisplays();

      debugPrint('Available displays: ${allDisplays.length}');
      for (int i = 0; i < allDisplays.length; i++) {
        final Display display = allDisplays[i];
        debugPrint('Display $i: ${display.size} at ${display.visiblePosition}');
      }
      if (monitorIndex == 0) {
        final Offset cursorPos = await screenRetriever.getCursorScreenPoint();
        return allDisplays.firstWhere((Display display) {
          final Rect displayRect = Rect.fromLTWH(
            display.visiblePosition?.dx ?? 0,
            display.visiblePosition?.dy ?? 0,
            display.size.width,
            display.size.height,
          );
          return displayRect.contains(cursorPos);
        }, orElse: () => primaryDisplay);
      } else {
        final int displayIndex = monitorIndex - 1;
        if (displayIndex >= 0 && displayIndex < allDisplays.length) {
          return allDisplays[displayIndex];
        } else {
          debugPrint(
            'Monitor $monitorIndex not available (only ${allDisplays.length} displays), falling back to Monitor 1',
          );
          return allDisplays.isNotEmpty ? allDisplays[0] : primaryDisplay;
        }
      }
    } catch (e) {
      debugPrint('Error getting target display: $e');
      return await screenRetriever.getPrimaryDisplay();
    }
  }

  static Future<Offset> _calcWindowPositionForDisplay(
    Size windowSize,
    Alignment alignment,
    Display display,
  ) async {
    final Size screenSize = display.visibleSize ?? display.size;
    final Offset screenOffset = display.visiblePosition ?? const Offset(0, 0);

    debugPrint('Screen size: $screenSize, offset: $screenOffset');

    double x = screenOffset.dx;
    double y = screenOffset.dy;

    if (alignment == Alignment.topLeft) {
      x += 0;
      y += 0;
    } else if (alignment == Alignment.topCenter) {
      x += (screenSize.width - windowSize.width) / 2;
      y += 0;
    } else if (alignment == Alignment.topRight) {
      x += screenSize.width - windowSize.width;
      y += 0;
    } else if (alignment == Alignment.centerLeft) {
      x += 0;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.center) {
      x += (screenSize.width - windowSize.width) / 2;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.centerRight) {
      x += screenSize.width - windowSize.width;
      y += (screenSize.height - windowSize.height) / 2;
    } else if (alignment == Alignment.bottomLeft) {
      x += 0;
      y += screenSize.height - windowSize.height;
    } else if (alignment == Alignment.bottomCenter) {
      x += (screenSize.width - windowSize.width) / 2;
      y += screenSize.height - windowSize.height;
    } else if (alignment == Alignment.bottomRight) {
      x += screenSize.width - windowSize.width;
      y += screenSize.height - windowSize.height;
    }

    return Offset(x, y);
  }

  static Alignment _getAlignmentFromPosition(
    HorizontalPosition horizontal,
    VerticalPosition vertical,
  ) {
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

    final int verticalIndex = vertical == VerticalPosition.top
        ? 0
        : vertical == VerticalPosition.center
        ? 1
        : 2;
    final int horizontalIndex = horizontal == HorizontalPosition.left
        ? 0
        : horizontal == HorizontalPosition.center
        ? 1
        : 2;

    return alignments[verticalIndex][horizontalIndex];
  }

  static Future<void> _configureWindowLevel(WindowLevel level) async {
    try {
      debugPrint('Configuring window level: $level');

      switch (level) {
        case WindowLevel.alwaysOnTop:
          debugPrint('Setting window to always on top');
          try {
            await windowManager.setAlwaysOnBottom(false);
          } catch (e) {
            debugPrint('setAlwaysOnBottom not available or failed: $e');
          }

          await Future.delayed(const Duration(milliseconds: 50));
          await windowManager.setAlwaysOnTop(true);
          debugPrint('Always on top enabled');
          break;

        case WindowLevel.alwaysBelow:
          debugPrint('Setting window to always below');

          await windowManager.setAlwaysOnTop(false);
          await Future.delayed(const Duration(milliseconds: 50));

          try {
            await windowManager.setAlwaysOnBottom(true);
            debugPrint('Always below enabled');
          } catch (e) {
            debugPrint('setAlwaysOnBottom not supported on this platform: $e');
          }
          break;

        case WindowLevel.normal:
          debugPrint('Setting window to normal level');
          await windowManager.setAlwaysOnTop(false);
          try {
            await windowManager.setAlwaysOnBottom(false);
          } catch (e) {
            debugPrint('setAlwaysOnBottom not available: $e');
          }
          debugPrint('Normal window level set');
          break;
      }
    } catch (e) {
      debugPrint('Error configuring window level: $e');
    }
  }

  static Size _calculateWindowSize(
    String widthStr,
    String heightStr,
    Display display,
  ) {
    final Size screenSize = display.visibleSize ?? display.size;
    double width;
    if (widthStr.endsWith('%')) {
      final String percentStr = widthStr.substring(0, widthStr.length - 1);
      final double percent = double.tryParse(percentStr) ?? 80.0;
      width = screenSize.width * (percent / 100.0);
    } else {
      width = double.tryParse(widthStr) ?? 800.0;
    }

    double height;
    if (heightStr.endsWith('%')) {
      final String percentStr = heightStr.substring(0, heightStr.length - 1);
      final double percent = double.tryParse(percentStr) ?? 60.0;
      height = screenSize.height * (percent / 100.0);
    } else {
      height = double.tryParse(heightStr) ?? 600.0;
    }

    width = width.clamp(200.0, screenSize.width);
    height = height.clamp(150.0, screenSize.height);

    return Size(width, height);
  }
}
