import 'package:flutter/material.dart';
import 'package:custom_launcher/core/error/app_error.dart';
import 'package:custom_launcher/core/logging/logging.dart';

class ErrorHandlingResult {
  final String userMessage;
  final ErrorSeverity severity;
  final bool isRecoverable;
  final VoidCallback? recoveryAction;
  final String? recoveryActionLabel;

  const ErrorHandlingResult({
    required this.userMessage,
    required this.severity,
    this.isRecoverable = false,
    this.recoveryAction,
    this.recoveryActionLabel,
  });
}

enum ErrorSeverity { info, warning, error, critical }

class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  ErrorHandlingResult handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    _logError(error, stackTrace: stackTrace, context: context);

    if (error is AppError) {
      return _handleAppError(error);
    } else {
      return _handleUnknownError(error, stackTrace: stackTrace);
    }
  }

  void showErrorSnackBar(BuildContext context, ErrorHandlingResult result) {
    final color = _getColorForSeverity(result.severity);
    final icon = _getIconForSeverity(result.severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                result.userMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: Duration(
          seconds: result.severity == ErrorSeverity.critical ? 10 : 4,
        ),
        action: result.recoveryAction != null
            ? SnackBarAction(
                label: result.recoveryActionLabel ?? 'Retry',
                textColor: Colors.white,
                onPressed: result.recoveryAction!,
              )
            : null,
      ),
    );
  }

  void showErrorDialog(
    BuildContext context,
    ErrorHandlingResult result, {
    String? title,
  }) {
    showDialog(
      context: context,
      barrierDismissible: result.severity != ErrorSeverity.critical,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getIconForSeverity(result.severity),
              color: _getColorForSeverity(result.severity),
            ),
            const SizedBox(width: 8),
            Text(title ?? _getTitleForSeverity(result.severity)),
          ],
        ),
        content: Text(result.userMessage),
        actions: [
          if (result.recoveryAction != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                result.recoveryAction!();
              },
              child: Text(result.recoveryActionLabel ?? 'Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  ErrorHandlingResult _handleAppError(AppError error) {
    switch (error.runtimeType) {
      case ConfigurationError:
        return ErrorHandlingResult(
          userMessage: 'Configuration error: ${error.message}',
          severity: ErrorSeverity.error,
          isRecoverable: true,
        );

      case FileSystemError:
        return ErrorHandlingResult(
          userMessage: 'File system error: ${error.message}',
          severity: ErrorSeverity.error,
          isRecoverable: true,
        );

      case AppLaunchError:
        return ErrorHandlingResult(
          userMessage: 'Failed to launch application: ${error.message}',
          severity: ErrorSeverity.error,
          isRecoverable: true,
        );

      case WindowManagementError:
        return ErrorHandlingResult(
          userMessage: 'Window management error: ${error.message}',
          severity: ErrorSeverity.warning,
          isRecoverable: true,
        );

      case NetworkError:
        return ErrorHandlingResult(
          userMessage: 'Network error: ${error.message}',
          severity: ErrorSeverity.error,
          isRecoverable: true,
        );

      case ValidationError:
        return ErrorHandlingResult(
          userMessage: 'Validation error: ${error.message}',
          severity: ErrorSeverity.warning,
          isRecoverable: true,
        );

      default:
        return ErrorHandlingResult(
          userMessage: 'An unexpected error occurred: ${error.message}',
          severity: ErrorSeverity.error,
          isRecoverable: false,
        );
    }
  }

  ErrorHandlingResult _handleUnknownError(
    Object error, {
    StackTrace? stackTrace,
  }) {
    return const ErrorHandlingResult(
      userMessage: 'An unexpected error occurred. Please try again.',
      severity: ErrorSeverity.error,
      isRecoverable: false,
    );
  }

  void _logError(Object error, {StackTrace? stackTrace, String? context}) {
    final contextStr = context != null ? '[$context] ' : '';

    if (error is AppError) {
      LogManager.error(
        '${contextStr}AppError: ${error.message}',
        tag: 'ErrorHandler',
        error: error,
        stackTrace: stackTrace ?? error.stackTrace,
      );
    } else {
      LogManager.error(
        '${contextStr}Unknown error: $error',
        tag: 'ErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Color _getColorForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Colors.blue;
      case ErrorSeverity.warning:
        return Colors.orange;
      case ErrorSeverity.error:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getIconForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return Icons.info;
      case ErrorSeverity.warning:
        return Icons.warning;
      case ErrorSeverity.error:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.dangerous;
    }
  }

  String _getTitleForSeverity(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.info:
        return 'Information';
      case ErrorSeverity.warning:
        return 'Warning';
      case ErrorSeverity.error:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }
}

final errorHandler = ErrorHandler.instance;
