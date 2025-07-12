import 'package:custom_launcher/core/logging/log_level.dart';

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  String format() {
    final timeStr = timestamp.toIso8601String();
    final levelStr = level.displayName.padRight(5);
    final tagStr = tag != null ? '[$tag] ' : '';
    final errorStr = error != null ? '\nError: $error' : '';
    final stackStr = stackTrace != null ? '\nStack: $stackTrace' : '';

    return '$timeStr $levelStr $tagStr$message$errorStr$stackStr';
  }
}

abstract class Logger {
  LogLevel get minLevel;

  void log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  });

  void debug(String message, {String? tag}) {
    log(LogLevel.debug, message, tag: tag);
  }

  void info(String message, {String? tag}) {
    log(LogLevel.info, message, tag: tag);
  }

  void warn(String message, {String? tag, Object? error}) {
    log(LogLevel.warn, message, tag: tag, error: error);
  }

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

  void dispose() {}
}
