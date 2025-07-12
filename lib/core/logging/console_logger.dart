import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:custom_launcher/core/logging/logger.dart';
import 'package:custom_launcher/core/logging/log_level.dart';

class ConsoleLogger implements Logger {
  final LogLevel _minLevel;
  final bool _useColors;
  final bool _includeTimestamp;

  ConsoleLogger({
    LogLevel minLevel = LogLevel.debug,
    bool useColors = true,
    bool includeTimestamp = true,
  }) : _minLevel = minLevel,
       _useColors = useColors,
       _includeTimestamp = includeTimestamp;

  @override
  LogLevel get minLevel => _minLevel;

  @override
  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level.isBelow(_minLevel)) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    final formattedMessage = _formatMessage(entry);

    if (kDebugMode) {
      debugPrint(formattedMessage);
    } else {
      developer.log(
        formattedMessage,
        name: tag ?? 'CustomLauncher',
        level: _getDeveloperLogLevel(level),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  String _formatMessage(LogEntry entry) {
    final buffer = StringBuffer();

    if (_includeTimestamp) {
      buffer.write('[${_formatTimestamp(entry.timestamp)}] ');
    }

    if (_useColors && kDebugMode) {
      buffer.write(_getColoredLevel(entry.level));
    } else {
      buffer.write('[${entry.level.displayName}] ');
    }

    if (entry.tag != null) {
      buffer.write('[${entry.tag}] ');
    }

    buffer.write(entry.message);

    if (entry.error != null) {
      buffer.write('\n  Error: ${entry.error}');
    }

    if (entry.stackTrace != null && entry.level.isAtOrAbove(LogLevel.error)) {
      buffer.write(
        '\n  Stack: ${entry.stackTrace.toString().split('\n').take(10).join('\n  ')}',
      );
    }

    return buffer.toString();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String _getColoredLevel(LogLevel level) {
    const reset = '\x1B[0m';
    switch (level) {
      case LogLevel.debug:
        return '\x1B[36m[${level.displayName}]$reset ';
      case LogLevel.info:
        return '\x1B[32m[${level.displayName}]$reset ';
      case LogLevel.warn:
        return '\x1B[33m[${level.displayName}]$reset ';
      case LogLevel.error:
        return '\x1B[31m[${level.displayName}]$reset ';
      case LogLevel.fatal:
        return '\x1B[35m[${level.displayName}]$reset ';
    }
  }

  int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warn:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  @override
  void debug(String message, {String? tag}) {
    log(LogLevel.debug, message, tag: tag);
  }

  @override
  void info(String message, {String? tag}) {
    log(LogLevel.info, message, tag: tag);
  }

  @override
  void warn(String message, {String? tag, Object? error}) {
    log(LogLevel.warn, message, tag: tag, error: error);
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void dispose() {}
}
