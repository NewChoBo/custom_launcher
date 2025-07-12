import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/services/window_service.dart';
import 'package:custom_launcher/core/providers/app_providers.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/services/keyboard_service.dart';
import 'package:custom_launcher/core/di/service_locator.dart';

import 'package:window_manager/window_manager.dart';
import 'package:custom_launcher/core/services/system_tray_service.dart';

import 'package:custom_launcher/features/launcher/presentation/pages/home_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LogManager.instance.initialize();

  final logger = LogManager.instance.logger;
  logger.info('Starting Custom Launcher application', tag: 'Main');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WindowListener {
  final SystemTrayService _systemTrayService = SystemTrayService();
  KeyboardService? _keyboardService;
  bool _windowInitialized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _systemTrayService.initialize();
    _initializeKeyboardService();
  }

  Future<void> _initializeKeyboardService() async {
    try {
      _keyboardService = sl.get<KeyboardService>();
      await _keyboardService!.initialize();

      // Register keyboard shortcut callbacks
      _keyboardService!.registerActionCallback(
        ShortcutAction.hideToTray,
        () => _systemTrayService.hideWindow(),
      );

      _keyboardService!.registerActionCallback(
        ShortcutAction.refreshApps,
        () => ref.refresh(appListNotifierProvider),
      );

      LogManager.info('Keyboard service initialized', tag: 'Main');
    } catch (e, stackTrace) {
      LogManager.error(
        'Failed to initialize keyboard service: $e',
        tag: 'Main',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _initializeWindowSettings() async {
    if (_windowInitialized) return;

    final logger = LogManager.instance.logger;

    try {
      final appSettings = await ref.read(getAppSettingsProvider.future);
      await WindowService.initialize(appSettings);
      _windowInitialized = true;
      logger.info('Window settings initialized successfully', tag: 'Main');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to initialize window settings: $e',
        tag: 'Main',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _systemTrayService.dispose();
    _keyboardService?.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      await _systemTrayService.hideWindow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final initializationAsyncValue = ref.watch(appInitializationProvider);

    return initializationAsyncValue.when(
      data: (_) => _buildMainApp(),
      loading: () => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Custom Launcher',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing Custom Launcher...'),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Custom Launcher',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize app',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $err',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(appInitializationProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainApp() {
    final appSettingsAsyncValue = ref.watch(getAppSettingsProvider);

    return appSettingsAsyncValue.when(
      data: (appSettings) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _initializeWindowSettings();
        });

        final materialApp = MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Custom Launcher',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,
          home: HomePage(
            title: 'Custom Launcher',
            onHideToTray: _systemTrayService.hideWindow,
          ),
        );

        // Wrap with keyboard shortcuts if service is available
        if (_keyboardService != null) {
          return _keyboardService!.createShortcutsWidget(
            child: materialApp,
            additionalCallbacks: {
              ShortcutAction.openSettings: () {
                // Navigate to settings page - placeholder for now
                LogManager.info('Settings shortcut pressed', tag: 'Main');
              },
            },
          );
        }

        return materialApp;
      },
      loading: () => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Custom Launcher',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading settings...'),
              ],
            ),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Custom Launcher',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.settings_applications_outlined,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load settings',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Error: $err',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(getAppSettingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
