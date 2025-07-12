import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:custom_launcher/core/services/base_service.dart';

/// Keyboard shortcut action types
/// 키보드 단축키 액션 타입들
enum ShortcutAction {
  openSettings,
  toggleSearch,
  launchApp,
  refreshApps,
  hideToTray,
  toggleFullscreen,
  focusNext,
  focusPrevious,
  selectAll,
  undo,
  redo,
}

/// Keyboard shortcut definition
/// 키보드 단축키 정의
class KeyboardShortcut {
  final ShortcutAction action;
  final LogicalKeySet keySet;
  final String description;
  final VoidCallback? callback;

  const KeyboardShortcut({
    required this.action,
    required this.keySet,
    required this.description,
    this.callback,
  });

  @override
  String toString() {
    return '${action.name}: ${keySet.keys.map((k) => k.keyLabel).join(' + ')} - $description';
  }
}

/// Keyboard service for handling global shortcuts
/// 전역 키보드 단축키를 처리하는 서비스
class KeyboardService extends BaseService {
  final Map<LogicalKeySet, KeyboardShortcut> _shortcuts = {};
  final Map<ShortcutAction, VoidCallback> _actionCallbacks = {};

  /// Default keyboard shortcuts
  static final List<KeyboardShortcut> defaultShortcuts = [
    // Settings and UI
    KeyboardShortcut(
      action: ShortcutAction.openSettings,
      keySet: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.comma,
      ),
      description: 'Open Settings',
    ),
    KeyboardShortcut(
      action: ShortcutAction.toggleSearch,
      keySet: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyF,
      ),
      description: 'Toggle Search',
    ),
    KeyboardShortcut(
      action: ShortcutAction.refreshApps,
      keySet: LogicalKeySet(LogicalKeyboardKey.f5),
      description: 'Refresh Apps',
    ),
    KeyboardShortcut(
      action: ShortcutAction.hideToTray,
      keySet: LogicalKeySet(LogicalKeyboardKey.escape),
      description: 'Hide to System Tray',
    ),
    KeyboardShortcut(
      action: ShortcutAction.toggleFullscreen,
      keySet: LogicalKeySet(LogicalKeyboardKey.f11),
      description: 'Toggle Fullscreen',
    ),

    // Navigation
    KeyboardShortcut(
      action: ShortcutAction.focusNext,
      keySet: LogicalKeySet(LogicalKeyboardKey.tab),
      description: 'Focus Next Element',
    ),
    KeyboardShortcut(
      action: ShortcutAction.focusPrevious,
      keySet: LogicalKeySet(LogicalKeyboardKey.shift, LogicalKeyboardKey.tab),
      description: 'Focus Previous Element',
    ),

    // Editing
    KeyboardShortcut(
      action: ShortcutAction.selectAll,
      keySet: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyA,
      ),
      description: 'Select All',
    ),
    KeyboardShortcut(
      action: ShortcutAction.undo,
      keySet: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyZ,
      ),
      description: 'Undo',
    ),
    KeyboardShortcut(
      action: ShortcutAction.redo,
      keySet: LogicalKeySet(
        LogicalKeyboardKey.control,
        LogicalKeyboardKey.keyY,
      ),
      description: 'Redo',
    ),
  ];

  @override
  Future<void> onInitialize() async {
    logInfo('Initializing keyboard shortcuts');

    // Register default shortcuts
    for (final shortcut in defaultShortcuts) {
      registerShortcut(shortcut);
    }

    logInfo('Registered ${_shortcuts.length} keyboard shortcuts');
  }

  @override
  Future<void> onDispose() async {
    logInfo('Disposing keyboard shortcuts');
    _shortcuts.clear();
    _actionCallbacks.clear();
  }

  /// Register a keyboard shortcut
  void registerShortcut(KeyboardShortcut shortcut) {
    _shortcuts[shortcut.keySet] = shortcut;
    logDebug('Registered shortcut: $shortcut');
  }

  /// Unregister a keyboard shortcut
  void unregisterShortcut(LogicalKeySet keySet) {
    final removed = _shortcuts.remove(keySet);
    if (removed != null) {
      logDebug('Unregistered shortcut: $removed');
    }
  }

  /// Register callback for a specific action
  void registerActionCallback(ShortcutAction action, VoidCallback callback) {
    _actionCallbacks[action] = callback;
    logDebug('Registered callback for action: ${action.name}');
  }

  /// Unregister callback for a specific action
  void unregisterActionCallback(ShortcutAction action) {
    final removed = _actionCallbacks.remove(action);
    if (removed != null) {
      logDebug('Unregistered callback for action: ${action.name}');
    }
  }

  /// Handle key event
  bool handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final pressedKeys = LogicalKeySet.fromSet(
      HardwareKeyboard.instance.logicalKeysPressed,
    );

    for (final entry in _shortcuts.entries) {
      if (entry.key == pressedKeys) {
        final shortcut = entry.value;
        logDebug('Executing shortcut: ${shortcut.action.name}');

        // Try shortcut-specific callback first
        if (shortcut.callback != null) {
          shortcut.callback!();
          return true;
        }

        // Try action callback
        final actionCallback = _actionCallbacks[shortcut.action];
        if (actionCallback != null) {
          actionCallback();
          return true;
        }

        logWarning(
          'No callback registered for shortcut: ${shortcut.action.name}',
        );
        return true; // Consume the event even if no callback
      }
    }

    return false; // Event not handled
  }

  /// Get all registered shortcuts
  List<KeyboardShortcut> get shortcuts => _shortcuts.values.toList();

  /// Get shortcuts for a specific action
  List<KeyboardShortcut> getShortcutsForAction(ShortcutAction action) {
    return _shortcuts.values.where((s) => s.action == action).toList();
  }

  /// Check if a key combination is already registered
  bool isKeySetRegistered(LogicalKeySet keySet) {
    return _shortcuts.containsKey(keySet);
  }

  /// Create a shortcuts widget for Flutter
  Widget createShortcutsWidget({
    required Widget child,
    Map<ShortcutAction, VoidCallback>? additionalCallbacks,
  }) {
    final Map<LogicalKeySet, Intent> shortcuts = {};
    final Map<Type, Action<Intent>> actions = {};

    // Create intents and actions for each shortcut
    for (final shortcut in _shortcuts.values) {
      final intent = _ShortcutIntent(shortcut.action);
      shortcuts[shortcut.keySet] = intent;

      if (!actions.containsKey(_ShortcutIntent)) {
        actions[_ShortcutIntent] = _ShortcutAction(this, additionalCallbacks);
      }
    }

    return Shortcuts(
      shortcuts: shortcuts,
      child: Actions(actions: actions, child: child),
    );
  }
}

/// Intent for keyboard shortcuts
class _ShortcutIntent extends Intent {
  final ShortcutAction action;

  const _ShortcutIntent(this.action);
}

/// Action for keyboard shortcuts
class _ShortcutAction extends Action<_ShortcutIntent> {
  final KeyboardService keyboardService;
  final Map<ShortcutAction, VoidCallback>? additionalCallbacks;

  _ShortcutAction(this.keyboardService, this.additionalCallbacks);

  @override
  Object? invoke(_ShortcutIntent intent) {
    // Try additional callbacks first
    if (additionalCallbacks?.containsKey(intent.action) == true) {
      additionalCallbacks![intent.action]!();
      return null;
    }

    // Try registered action callbacks
    final callback = keyboardService._actionCallbacks[intent.action];
    if (callback != null) {
      callback();
      return null;
    }

    keyboardService.logWarning(
      'No callback for shortcut action: ${intent.action.name}',
    );
    return null;
  }
}
