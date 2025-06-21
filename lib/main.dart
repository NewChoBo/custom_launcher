import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setPreventClose(true);
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  final SystemTray _systemTray = SystemTray();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initSystemTray();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initSystemTray() async {
    try {
      // Use platform-appropriate icon files
      String iconPath = Platform.isWindows
          ? 'assets/icons/app_icon.ico'
          : Platform.isMacOS
          ? 'assets/icons/app_icon.icns'
          : 'assets/icons/app_icon.png';

      await _systemTray.initSystemTray(
        title: "Custom Launcher",
        iconPath: iconPath,
        toolTip: "Custom Launcher - Click to show/hide",
      ); // Create context menu
      final Menu menu = Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: 'Show Window',
          onClicked: (menuItem) => _showWindow(),
        ),
        MenuItemLabel(
          label: 'Hide Window',
          onClicked: (menuItem) => _hideWindow(),
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: 'Exit',
          onClicked: (menuItem) => _exitApplication(),
        ),
      ]);

      await _systemTray.setContextMenu(
        menu,
      ); // Register system tray event handlers
      _systemTray.registerSystemTrayEventHandler((eventName) {
        debugPrint("System tray event: $eventName");
        if (eventName == kSystemTrayEventClick) {
          _toggleWindow();
        } else if (eventName == kSystemTrayEventRightClick) {
          _systemTray.popUpContextMenu();
        }
      });
    } catch (e) {
      debugPrint('Error initializing system tray: $e');
    }
  }

  Future<void> _showWindow() async {
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _hideWindow() async {
    await windowManager.hide();
  }

  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await _hideWindow();
    } else {
      await _showWindow();
    }
  }

  Future<void> _exitApplication() async {
    await _systemTray.destroy();
    exit(0);
  }

  @override
  void onWindowClose() async {
    // Hide to tray instead of closing when user clicks X
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await _hideWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Launcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Custom Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.minimize),
            onPressed: () async {
              await windowManager.hide();
            },
            tooltip: 'Hide to System Tray',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.rocket_launch, size: 100, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              'Custom Launcher',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Running in System Tray',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Card(
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'System Tray Features:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('• Left click tray icon to show/hide window'),
                    Text('• Right click tray icon for context menu'),
                    Text('• Click minimize button to hide to tray'),
                    Text('• App continues running in background'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
