import 'package:custom_launcher/core/logging/logger.dart';
import 'package:custom_launcher/core/logging/console_logger.dart';
import 'package:custom_launcher/core/logging/log_level.dart';

class LogManager {
  static LogManager? _instance;
  static LogManager get instance => _instance ??= LogManager._();

  LogManager._();

  Logger? _logger;

  Logger get logger => _logger ?? _defaultLogger;

  static final Logger _defaultLogger = ConsoleLogger(
    minLevel: LogLevel.debug,
    useColors: true,
    includeTimestamp: true,
  );

  void initialize({Logger? logger}) {
    _logger = logger ?? _defaultLogger;
  }

  void setLogger(Logger logger) {
    _logger?.dispose();
    _logger = logger;
  }

  void dispose() {
    _logger?.dispose();
    _logger = null;
  }

  static void debug(String message, {String? tag}) {
    instance.logger.debug(message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    instance.logger.info(message, tag: tag);
  }

  static void warn(String message, {String? tag, Object? error}) {
    instance.logger.warn(message, tag: tag, error: error);
  }

  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    instance.logger.error(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    instance.logger.fatal(
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

final log = LogManager.instance.logger;
