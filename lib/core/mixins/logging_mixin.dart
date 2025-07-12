import 'package:custom_launcher/core/logging/logging.dart';

/// Common logging functionality mixin
/// 공통 로깅 기능을 제공하는 Mixin
mixin LoggingMixin {
  /// Logger instance
  Logger get logger => LogManager.instance.logger;

  /// Log tag for this class
  String get logTag => runtimeType.toString();

  /// Log debug message
  void logDebug(String message) {
    logger.debug(message, tag: logTag);
  }

  /// Log info message
  void logInfo(String message) {
    logger.info(message, tag: logTag);
  }

  /// Log warning message
  void logWarning(String message, {Object? error}) {
    logger.warn(message, tag: logTag, error: error);
  }

  /// Log error message
  void logError(String message, {Object? error, StackTrace? stackTrace}) {
    logger.error(message, tag: logTag, error: error, stackTrace: stackTrace);
  }

  /// Log fatal message
  void logFatal(String message, {Object? error, StackTrace? stackTrace}) {
    logger.fatal(message, tag: logTag, error: error, stackTrace: stackTrace);
  }
}
