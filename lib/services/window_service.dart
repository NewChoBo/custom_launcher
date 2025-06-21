import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Window management service for desktop applications
/// Handles window initialization, configuration, and lifecycle
class WindowService {
  /// Initialize window manager with settings-based configuration
  static Future<void> initialize([AppSettings? settings]) async {
    final config = settings ?? const AppSettings();

    await windowManager.ensureInitialized();

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(config.windowWidth, config.windowHeight),
        center: false, // We'll set position manually
        backgroundColor: Colors.transparent,
        skipTaskbar: config.skipTaskbar,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);

        // Set position based on settings
        await _applyWindowPosition(config);

        // Configure window level based on settings
        await _configureWindowLevel(config.windowLevel);

        debugPrint('Window initialized with settings: $config');
      },
    );
  }

  /// Apply window position based on settings using window_manager's built-in utilities
  static Future<void> _applyWindowPosition(AppSettings config) async {
    try {
      // Get window size for position calculation
      final size = Size(
        config.windowWidth,
        config.windowHeight,
      ); // Get target display based on monitor preference
      final targetDisplay = await _getTargetDisplay(config.monitorIndex);

      // Calculate alignment based on position settings
      final alignment = _getAlignmentFromPosition(
        config.horizontalPosition,
        config.verticalPosition,
      );

      // Calculate position using the target display
      final position = await _calcWindowPositionForDisplay(
        size,
        alignment,
        targetDisplay,
      );

      debugPrint(
        'Setting window position to: $position (alignment: $alignment, display: ${targetDisplay.size})',
      );

      // Apply the calculated position
      await windowManager.setPosition(position);
    } catch (e) {
      debugPrint('Error applying window position: $e');
      // Fallback to center positioning
      await windowManager.center();
    }
  }

  /// Get target display based on monitor preference
  static Future<Display> _getTargetDisplay(int monitorIndex) async {
    try {
      final primaryDisplay = await screenRetriever.getPrimaryDisplay();
      final allDisplays = await screenRetriever.getAllDisplays();

      debugPrint('Available displays: ${allDisplays.length}');
      for (int i = 0; i < allDisplays.length; i++) {
        final display = allDisplays[i];
        debugPrint('Display $i: ${display.size} at ${display.visiblePosition}');
      } // Handle monitor index (1-based numbering, 0 = auto)
      if (monitorIndex == 0) {
        // Auto mode: Use cursor position to determine current display
        final cursorPos = await screenRetriever.getCursorScreenPoint();
        return allDisplays.firstWhere((display) {
          final displayRect = Rect.fromLTWH(
            display.visiblePosition?.dx ?? 0,
            display.visiblePosition?.dy ?? 0,
            display.size.width,
            display.size.height,
          );
          return displayRect.contains(cursorPos);
        }, orElse: () => primaryDisplay);
      } else {
        // Specific monitor (1-based, so subtract 1 for 0-based array index)
        final displayIndex = monitorIndex - 1;
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

  /// Calculate window position for specific display
  static Future<Offset> _calcWindowPositionForDisplay(
    Size windowSize,
    Alignment alignment,
    Display display,
  ) async {
    // Use visible size if available (excludes taskbar, etc.)
    final screenSize = display.visibleSize ?? display.size;
    final screenOffset = display.visiblePosition ?? const Offset(0, 0);

    debugPrint('Screen size: $screenSize, offset: $screenOffset');

    double x = screenOffset.dx;
    double y = screenOffset.dy;

    // Calculate position based on alignment
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

  /// Convert position settings to Flutter Alignment
  static Alignment _getAlignmentFromPosition(
    HorizontalPosition horizontal,
    VerticalPosition vertical,
  ) {
    // Create alignment matrix
    const alignments = [
      [Alignment.topLeft, Alignment.topCenter, Alignment.topRight],
      [Alignment.centerLeft, Alignment.center, Alignment.centerRight],
      [Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight],
    ];

    final verticalIndex = vertical == VerticalPosition.top
        ? 0
        : vertical == VerticalPosition.center
        ? 1
        : 2;
    final horizontalIndex = horizontal == HorizontalPosition.left
        ? 0
        : horizontal == HorizontalPosition.center
        ? 1
        : 2;

    return alignments[verticalIndex][horizontalIndex];
  }

  /// Configure window level (z-order) based on settings
  static Future<void> _configureWindowLevel(WindowLevel level) async {
    try {
      debugPrint('Configuring window level: $level');

      switch (level) {
        case WindowLevel.alwaysOnTop:
          debugPrint('Setting window to always on top');
          // First disable bottom if available
          try {
            await windowManager.setAlwaysOnBottom(false);
          } catch (e) {
            debugPrint('setAlwaysOnBottom not available or failed: $e');
          }

          // Add small delay to ensure previous setting is applied
          await Future.delayed(const Duration(milliseconds: 50));

          // Then enable top
          await windowManager.setAlwaysOnTop(true);
          debugPrint('Always on top enabled');
          break;

        case WindowLevel.alwaysBelow:
          debugPrint('Setting window to always below');
          // First disable top
          await windowManager.setAlwaysOnTop(false);

          // Add small delay
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
          // Disable both
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
}
