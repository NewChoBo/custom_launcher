import 'package:equatable/equatable.dart';

/// 애플리케이션에서 발생하는 모든 에러의 기본 클래스
abstract class AppError extends Equatable implements Exception {
  /// 에러 코드
  final String code;

  /// 에러 메시지
  final String message;

  /// 기술적인 상세 정보
  final String? details;

  /// 원본 에러 (있는 경우)
  final Object? cause;

  /// 스택 트레이스
  final StackTrace? stackTrace;

  const AppError({
    required this.code,
    required this.message,
    this.details,
    this.cause,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [code, message, details, cause, stackTrace];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 구성 파일 관련 에러
class ConfigurationError extends AppError {
  const ConfigurationError({
    required String message,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'CONFIG_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );
}

/// 파일 시스템 관련 에러
class FileSystemError extends AppError {
  /// 파일 경로
  final String? filePath;

  const FileSystemError({
    required String message,
    this.filePath,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'FILE_SYSTEM_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  List<Object?> get props => [...super.props, filePath];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (filePath != null) {
      buffer.write(', filePath: $filePath');
    }

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 애플리케이션 실행 관련 에러
class AppLaunchError extends AppError {
  /// 애플리케이션 ID
  final String? appId;

  /// 실행 파일 경로
  final String? executablePath;

  const AppLaunchError({
    required String message,
    this.appId,
    this.executablePath,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'APP_LAUNCH_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  List<Object?> get props => [...super.props, appId, executablePath];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (appId != null) {
      buffer.write(', appId: $appId');
    }

    if (executablePath != null) {
      buffer.write(', executablePath: $executablePath');
    }

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 윈도우 관리 관련 에러
class WindowManagementError extends AppError {
  /// 윈도우 작업 타입
  final String? operation;

  const WindowManagementError({
    required String message,
    this.operation,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'WINDOW_MANAGEMENT_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  List<Object?> get props => [...super.props, operation];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (operation != null) {
      buffer.write(', operation: $operation');
    }

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 네트워크 관련 에러
class NetworkError extends AppError {
  /// HTTP 상태 코드
  final int? statusCode;

  /// 요청 URL
  final String? url;

  const NetworkError({
    required String message,
    this.statusCode,
    this.url,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'NETWORK_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  List<Object?> get props => [...super.props, statusCode, url];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (statusCode != null) {
      buffer.write(', statusCode: $statusCode');
    }

    if (url != null) {
      buffer.write(', url: $url');
    }

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 검증 관련 에러
class ValidationError extends AppError {
  /// 검증 실패 필드
  final String? field;

  /// 검증 실패 값
  final dynamic value;

  const ValidationError({
    required String message,
    this.field,
    this.value,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'VALIDATION_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );

  @override
  List<Object?> get props => [...super.props, field, value];

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType(code: $code, message: $message');

    if (field != null) {
      buffer.write(', field: $field');
    }

    if (value != null) {
      buffer.write(', value: $value');
    }

    if (details != null) {
      buffer.write(', details: $details');
    }

    if (cause != null) {
      buffer.write(', cause: $cause');
    }

    buffer.write(')');
    return buffer.toString();
  }
}

/// 알 수 없는 에러
class UnknownError extends AppError {
  const UnknownError({
    required String message,
    String? details,
    Object? cause,
    StackTrace? stackTrace,
  }) : super(
         code: 'UNKNOWN_ERROR',
         message: message,
         details: details,
         cause: cause,
         stackTrace: stackTrace,
       );
}
