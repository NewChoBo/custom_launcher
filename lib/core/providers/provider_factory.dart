import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/di/service_locator.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error_handler.dart';

/// Provider factory for common provider patterns
/// 공통 프로바이더 패턴을 위한 팩토리 클래스
class ProviderFactory {
  /// Create a provider from service locator
  static Provider<T> fromServiceLocator<T>() {
    return Provider<T>((ref) => sl.get<T>());
  }

  /// Create a lazy provider with error handling
  static Provider<T> lazy<T>(T Function() create) {
    return Provider<T>((ref) {
      try {
        return create();
      } catch (error, stackTrace) {
        LogManager.error(
          'Failed to create provider for ${T.toString()}',
          tag: 'ProviderFactory',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    });
  }

  /// Create a provider with dependency injection
  static Provider<T> withDependencies<T>(T Function(Ref ref) create) {
    return Provider<T>((ref) {
      try {
        return create(ref);
      } catch (error, stackTrace) {
        LogManager.error(
          'Failed to create provider for ${T.toString()} with dependencies',
          tag: 'ProviderFactory',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    });
  }

  /// Create a singleton provider
  static Provider<T> singleton<T>(T Function() create) {
    return Provider<T>((ref) {
      ref.keepAlive();
      return create();
    });
  }
}

/// Common provider patterns
/// 공통 프로바이더 패턴들
class CommonProviders {
  /// Logger provider
  static final loggerProvider = ProviderFactory.lazy<Logger>(
    () => LogManager.instance.logger,
  );

  /// Error handler provider
  static final errorHandlerProvider =
      ProviderFactory.fromServiceLocator<ErrorHandler>();

  /// Create a repository provider from service locator
  static Provider<T> repository<T>() => ProviderFactory.fromServiceLocator<T>();

  /// Create a use case provider with repository dependency
  static Provider<T> useCase<T>(T Function(Ref ref) create) =>
      ProviderFactory.withDependencies<T>(create);
}

/// StateNotifier factory patterns
/// StateNotifier 팩토리 패턴들
class StateNotifierFactory {
  /// Create a StateNotifier provider with error handling
  static StateNotifierProvider<T, S> create<T extends StateNotifier<S>, S>(
    T Function(Ref ref) create,
  ) {
    return StateNotifierProvider<T, S>((ref) {
      try {
        return create(ref);
      } catch (error, stackTrace) {
        LogManager.error(
          'Failed to create StateNotifier for ${T.toString()}',
          tag: 'StateNotifierFactory',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    });
  }
}

/// FutureProvider factory patterns
/// FutureProvider 팩토리 패턴들
class FutureProviderFactory {
  /// Create a FutureProvider with error handling
  static FutureProvider<T> create<T>(Future<T> Function(Ref ref) create) {
    return FutureProvider<T>((ref) async {
      try {
        LogManager.debug(
          'Starting FutureProvider for ${T.toString()}',
          tag: 'FutureProviderFactory',
        );
        final result = await create(ref);
        LogManager.debug(
          'FutureProvider completed for ${T.toString()}',
          tag: 'FutureProviderFactory',
        );
        return result;
      } catch (error, stackTrace) {
        LogManager.error(
          'FutureProvider failed for ${T.toString()}',
          tag: 'FutureProviderFactory',
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      }
    });
  }
}
