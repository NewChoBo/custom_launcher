import 'package:flutter/material.dart';
import 'package:custom_launcher/core/error/error_handler.dart';
import 'package:custom_launcher/core/mixins/logging_mixin.dart';

/// Common error handling functionality mixin
/// 공통 에러 처리 기능을 제공하는 Mixin
mixin ErrorHandlingMixin on LoggingMixin {
  /// Error handler instance
  ErrorHandler get errorHandler => ErrorHandler.instance;

  /// Handle error with logging and optional context
  void handleError(Object error, {StackTrace? stackTrace, String? context}) {
    final result = errorHandler.handleError(
      error,
      stackTrace: stackTrace,
      context: context,
    );

    // Log the error for debugging
    logError(
      'Error handled: ${result.userMessage}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Handle error and show SnackBar
  void handleErrorWithSnackBar(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? contextMessage,
  }) {
    final result = errorHandler.handleError(
      error,
      stackTrace: stackTrace,
      context: contextMessage,
    );

    logError(
      'Error handled with SnackBar: ${result.userMessage}',
      error: error,
      stackTrace: stackTrace,
    );

    errorHandler.showErrorSnackBar(context, result);
  }

  /// Handle error and show dialog
  void handleErrorWithDialog(
    BuildContext context,
    Object error, {
    StackTrace? stackTrace,
    String? contextMessage,
    String? title,
  }) {
    final result = errorHandler.handleError(
      error,
      stackTrace: stackTrace,
      context: contextMessage,
    );

    logError(
      'Error handled with Dialog: ${result.userMessage}',
      error: error,
      stackTrace: stackTrace,
    );

    errorHandler.showErrorDialog(context, result, title: title);
  }

  /// Execute operation with error handling
  Future<T?> executeWithErrorHandling<T>(
    Future<T> Function() operation, {
    String? operationName,
    bool logSuccess = true,
  }) async {
    final opName = operationName ?? 'Operation';

    try {
      logInfo('Starting $opName');
      final result = await operation();

      if (logSuccess) {
        logInfo('$opName completed successfully');
      }

      return result;
    } catch (error, stackTrace) {
      logError('$opName failed: $error', error: error, stackTrace: stackTrace);

      handleError(error, stackTrace: stackTrace, context: opName);
      return null;
    }
  }

  /// Execute operation with error handling and context
  Future<T?> executeWithErrorHandlingAndContext<T>(
    BuildContext context,
    Future<T> Function() operation, {
    String? operationName,
    bool showSnackBar = true,
    bool logSuccess = true,
  }) async {
    final opName = operationName ?? 'Operation';

    try {
      logInfo('Starting $opName');
      final result = await operation();

      if (logSuccess) {
        logInfo('$opName completed successfully');
      }

      return result;
    } catch (error, stackTrace) {
      logError('$opName failed: $error', error: error, stackTrace: stackTrace);

      if (showSnackBar) {
        handleErrorWithSnackBar(
          context,
          error,
          stackTrace: stackTrace,
          contextMessage: opName,
        );
      } else {
        handleError(error, stackTrace: stackTrace, context: opName);
      }

      return null;
    }
  }
}
