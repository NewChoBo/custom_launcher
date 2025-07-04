import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter/material.dart';
import 'package:custom_launcher/services/launcher_config_service.dart';
import 'package:custom_launcher/models/layout_config.dart';

/// Window management service for desktop applications
/// Handles window initialization, configuration, and lifecycle
class WindowService {
  /// Initialize window manager with layout configuration
  static Future<void> initializeWithConfig(
    LauncherConfigService configService,
  ) async {
    await windowManager.ensureInitialized();

    // Get layout configuration
    final LayoutConfig? layout = configService.getCurrentLayout();
    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();

    // Calculate window size from layout config or use defaults
    Size windowSize;
    if (layout?.frame.window.size != null) {
      final SizeConfig frameSize = layout!.frame.window.size;
      windowSize = Size(
        _parseSize(frameSize.windowWidth, primaryDisplay.size.width),
        _parseSize(frameSize.windowHeight, primaryDisplay.size.height),
      );
    } else {
      windowSize = Size(
        primaryDisplay.size.width * 0.8,
        primaryDisplay.size.height * 0.6,
      );
    }

    // Get window behavior settings
    final bool skipTaskbar = layout?.frame.window.behavior.skipTaskbar ?? true;

    // Calculate window position
    final String horizontalPos =
        layout?.frame.window.position.horizontalPosition ?? 'center';
    final String verticalPos =
        layout?.frame.window.position.verticalPosition ?? 'center';
    final bool centerWindow =
        horizontalPos == 'center' && verticalPos == 'center';

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: windowSize,
        center: centerWindow,
        backgroundColor: Colors.transparent,
        skipTaskbar: skipTaskbar,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();

        // Set custom position if not centered
        if (!centerWindow) {
          await _setCustomPosition(
            windowSize,
            horizontalPos,
            verticalPos,
            primaryDisplay,
            layout,
          );
        }

        await windowManager.focus();
        await windowManager.setPreventClose(true);

        debugPrint(
          'Window initialized with layout config: ${layout?.metadata.title ?? 'default'}',
        );
      },
    );
  }

  /// Initialize window manager with default configuration (legacy method)
  static Future<void> initialize() async {
    await windowManager.ensureInitialized();

    // Get primary display for initial size calculation
    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final Size initialSize = Size(
      primaryDisplay.size.width * 0.8,
      primaryDisplay.size.height * 0.6,
    );

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: initialSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: true,
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setPreventClose(true);

        debugPrint('Window initialized with default settings');
      },
    );
  }

  /// Set custom window position based on layout configuration
  static Future<void> _setCustomPosition(
    Size windowSize,
    String horizontalPos,
    String verticalPos,
    Display primaryDisplay,
    LayoutConfig? layout,
  ) async {
    double x = 0;
    double y = 0;

    // Get margin from layout config or use default
    double horizontalMargin = 20.0;
    double verticalMargin = 20.0;

    if (layout?.frame.window.position.margin != null) {
      horizontalMargin = layout!.frame.window.position.margin!.horizontal;
      verticalMargin = layout.frame.window.position.margin!.vertical;
    }

    // Calculate horizontal position
    switch (horizontalPos.toLowerCase()) {
      case 'left':
        x = horizontalMargin;
        break;
      case 'right':
        x = primaryDisplay.size.width - windowSize.width - horizontalMargin;
        break;
      case 'center':
      default:
        x = (primaryDisplay.size.width - windowSize.width) / 2;
        break;
    }

    // Calculate vertical position
    switch (verticalPos.toLowerCase()) {
      case 'top':
        y = verticalMargin;
        break;
      case 'bottom':
        y = primaryDisplay.size.height - windowSize.height - verticalMargin;
        break;
      case 'center':
      default:
        y = (primaryDisplay.size.height - windowSize.height) / 2;
        break;
    }

    await windowManager.setPosition(Offset(x, y));
    debugPrint(
      'Window positioned at: ($x, $y) - ${horizontalPos}_${verticalPos} with margin: (${horizontalMargin}, ${verticalMargin})',
    );
  }

  /// Parse size string (e.g., "80%", "1024", "fill") to pixel value
  static double _parseSize(String sizeStr, double referenceSize) {
    if (sizeStr.endsWith('%')) {
      final double percent =
          double.tryParse(sizeStr.substring(0, sizeStr.length - 1)) ?? 80;
      return referenceSize * (percent / 100);
    } else if (sizeStr.toLowerCase() == 'fill') {
      return referenceSize;
    } else {
      return double.tryParse(sizeStr) ?? referenceSize * 0.8;
    }
  }
}
