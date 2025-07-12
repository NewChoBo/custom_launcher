import 'package:equatable/equatable.dart';
import 'package:custom_launcher/core/error/app_error.dart';
import 'package:custom_launcher/core/mixins/logging_mixin.dart';
import 'package:custom_launcher/core/mixins/error_handling_mixin.dart';

/// UseCase 실행 결과를 나타내는 클래스
abstract class UseCaseResult<T> extends Equatable {
  const UseCaseResult();
}

class Success<T> extends UseCaseResult<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

class Failure<T> extends UseCaseResult<T> {
  final AppError error;

  const Failure(this.error);

  @override
  List<Object?> get props => [error];
}

/// UseCase 확장 메서드
extension UseCaseResultExtensions<T> on UseCaseResult<T> {
  bool get isSuccess => this is Success<T>;

  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;

  AppError? get error => isFailure ? (this as Failure<T>).error : null;

  UseCaseResult<T> onSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  UseCaseResult<T> onFailure(void Function(AppError error) callback) {
    if (isFailure) {
      callback((this as Failure<T>).error);
    }
    return this;
  }

  UseCaseResult<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e, stackTrace) {
        return Failure(
          UnknownError(
            message: 'Data transformation failed',
            cause: e,
            stackTrace: stackTrace,
          ),
        );
      }
    }
    return Failure((this as Failure<T>).error);
  }
}

abstract class UseCase<T> with LoggingMixin, ErrorHandlingMixin {
  String get name => runtimeType.toString();

  Future<UseCaseResult<T>> call() async {
    logInfo('Executing UseCase: $name');

    try {
      final result = await execute();
      logInfo('UseCase $name completed successfully');
      return Success(result);
    } on AppError catch (e) {
      logError('UseCase $name failed with AppError: ${e.message}', error: e);
      return Failure(e);
    } catch (e, stackTrace) {
      logError(
        'UseCase $name failed with unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      final appError = UnknownError(
        message: 'Unexpected error in $name',
        cause: e,
        stackTrace: stackTrace,
      );
      return Failure(appError);
    }
  }

  Future<T> execute();
}

abstract class UseCaseWithParams<T, P> with LoggingMixin, ErrorHandlingMixin {
  String get name => runtimeType.toString();

  Future<UseCaseResult<T>> call(P params) async {
    logInfo('Executing UseCase: $name with params: $params');

    try {
      final result = await execute(params);
      logInfo('UseCase $name completed successfully');
      return Success(result);
    } on AppError catch (e) {
      logError('UseCase $name failed with AppError: ${e.message}', error: e);
      return Failure(e);
    } catch (e, stackTrace) {
      logError(
        'UseCase $name failed with unexpected error: $e',
        error: e,
        stackTrace: stackTrace,
      );
      final appError = UnknownError(
        message: 'Unexpected error in $name',
        cause: e,
        stackTrace: stackTrace,
      );
      return Failure(appError);
    }
  }

  Future<T> execute(P params);
}

/// 매개변수 클래스들
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

class AppIdParams extends UseCaseParams {
  final String appId;

  const AppIdParams(this.appId);

  @override
  List<Object?> get props => [appId];
}

class UpdateAppParams extends UseCaseParams {
  final String appId;
  final Map<String, dynamic> updates;

  const UpdateAppParams({required this.appId, required this.updates});

  @override
  List<Object?> get props => [appId, updates];
}

class SaveSettingsParams extends UseCaseParams {
  final Map<String, dynamic> settings;

  const SaveSettingsParams(this.settings);

  @override
  List<Object?> get props => [settings];
}
