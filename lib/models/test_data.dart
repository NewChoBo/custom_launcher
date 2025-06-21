import 'package:custom_launcher/models/launcher_item.dart';
import 'package:custom_launcher/models/app_settings.dart';

/// Test data generator for launcher items
class TestDataGenerator {
  /// Generate sample launcher items for testing
  static List<LauncherItem> generateSampleItems() {
    return [
      // Sample executable items
      LauncherItem(
        id: 'notepad',
        name: 'Notepad',
        path: 'C:\\Windows\\System32\\notepad.exe',
        itemType: LauncherItemType.executable,
        position: const ItemPosition(x: 50, y: 50, gridRow: 0, gridColumn: 0),
      ),
      LauncherItem(
        id: 'calculator',
        name: 'Calculator',
        path: 'C:\\Windows\\System32\\calc.exe',
        itemType: LauncherItemType.executable,
        position: const ItemPosition(x: 150, y: 50, gridRow: 0, gridColumn: 1),
      ),

      // Sample URL items
      LauncherItem(
        id: 'google',
        name: 'Google',
        path: 'https://www.google.com',
        itemType: LauncherItemType.url,
        position: const ItemPosition(x: 250, y: 50, gridRow: 0, gridColumn: 2),
      ),
      LauncherItem(
        id: 'github',
        name: 'GitHub',
        path: 'https://github.com',
        itemType: LauncherItemType.url,
        position: const ItemPosition(x: 350, y: 50, gridRow: 0, gridColumn: 3),
      ),

      // Second row
      LauncherItem(
        id: 'vscode',
        name: 'VS Code',
        path:
            'C:\\Users\\%USERNAME%\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe',
        itemType: LauncherItemType.executable,
        position: const ItemPosition(x: 50, y: 150, gridRow: 1, gridColumn: 0),
      ),
      LauncherItem(
        id: 'youtube',
        name: 'YouTube',
        path: 'https://www.youtube.com',
        itemType: LauncherItemType.url,
        position: const ItemPosition(x: 150, y: 150, gridRow: 1, gridColumn: 1),
      ),
    ];
  }

  /// Generate AppSettings with sample launcher items
  static AppSettings generateSampleSettings() {
    return AppSettings(
      backgroundOpacity: 0.95,
      appBarOpacity: 0.9,
      windowWidth: "800",
      windowHeight: "600",
      skipTaskbar: true,
      showAppBar: true,
      windowLevel: WindowLevel.normal,
      horizontalPosition: HorizontalPosition.center,
      verticalPosition: VerticalPosition.center,
      monitorIndex: 1,
      launcherItems: generateSampleItems(),
      layoutMode: LauncherLayoutMode.grid,
      textPosition: TextPosition.below,
      clickBehavior: ClickBehavior.singleClick,
      showIcons: true,
      showText: true,
      gridColumns: 4,
      itemSpacing: 16.0,
      iconSize: 48.0,
    );
  }

  /// Create a minimal settings for testing JSON serialization
  static AppSettings generateMinimalSettings() {
    return const AppSettings(launcherItems: []);
  }
}
