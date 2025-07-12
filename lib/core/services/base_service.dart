import 'package:custom_launcher/core/mixins/logging_mixin.dart';
import 'package:custom_launcher/core/mixins/error_handling_mixin.dart';
import 'package:custom_launcher/core/di/service_locator.dart';

/// Base service class with common functionality
/// 공통 기능을 제공하는 베이스 서비스 클래스
abstract class BaseService with LoggingMixin, ErrorHandlingMixin {
  /// Whether the service is initialized
  bool _isInitialized = false;

  /// Whether the service is disposed
  bool _isDisposed = false;

  /// Get service from service locator
  T getService<T>() => sl.get<T>();

  /// Check if service is registered
  bool isServiceRegistered<T>() => sl.isRegistered<T>();

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;

    logInfo('Initializing $runtimeType');

    try {
      await onInitialize();
      _isInitialized = true;
      logInfo('$runtimeType initialized successfully');
    } catch (error, stackTrace) {
      logError(
        'Failed to initialize $runtimeType: $error',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_isDisposed) return;

    logInfo('Disposing $runtimeType');

    try {
      await onDispose();
      _isDisposed = true;
      logInfo('$runtimeType disposed successfully');
    } catch (error, stackTrace) {
      logError(
        'Failed to dispose $runtimeType: $error',
        error: error,
        stackTrace: stackTrace,
      );
      // Don't rethrow on dispose to prevent cascading errors
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Check if service is disposed
  bool get isDisposed => _isDisposed;

  /// Ensure service is initialized
  void ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        '$runtimeType is not initialized. Call initialize() first.',
      );
    }
    if (_isDisposed) {
      throw StateError('$runtimeType is disposed and cannot be used.');
    }
  }

  /// Execute operation with service state check
  Future<T> executeWithStateCheck<T>(
    Future<T> Function() operation,
    String operationName,
  ) async {
    ensureInitialized();

    return await executeWithErrorHandling(
          operation,
          operationName: operationName,
        ) ??
        (throw StateError('$operationName failed'));
  }

  /// Override this method to perform custom initialization
  Future<void> onInitialize() async {
    // Default implementation - override in subclasses
  }

  /// Override this method to perform custom disposal
  Future<void> onDispose() async {
    // Default implementation - override in subclasses
  }
}

/// Base repository class with common functionality
/// 공통 기능을 제공하는 베이스 리포지토리 클래스
abstract class BaseRepository with LoggingMixin, ErrorHandlingMixin {
  /// Cache for repository data
  final Map<String, dynamic> _cache = {};

  /// Get cached data
  T? getCached<T>(String key) {
    return _cache[key] as T?;
  }

  /// Set cached data
  void setCached<T>(String key, T data) {
    _cache[key] = data;
    logDebug('Cached data for key: $key');
  }

  /// Clear cached data
  void clearCache([String? key]) {
    if (key != null) {
      _cache.remove(key);
      logDebug('Cleared cache for key: $key');
    } else {
      _cache.clear();
      logDebug('Cleared all cache');
    }
  }

  /// Execute operation with caching
  Future<T> executeWithCache<T>(
    String cacheKey,
    Future<T> Function() operation, {
    Duration? cacheDuration,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = getCached<T>(cacheKey);
      if (cached != null) {
        logDebug('Using cached data for key: $cacheKey');
        return cached;
      }
    }

    final result = await executeWithErrorHandling(
      operation,
      operationName: 'Cache operation for $cacheKey',
    );

    if (result != null) {
      setCached(cacheKey, result);

      // Set cache expiration if duration is provided
      if (cacheDuration != null) {
        Future.delayed(cacheDuration, () {
          clearCache(cacheKey);
        });
      }
    }

    return result ?? (throw StateError('Operation failed for $cacheKey'));
  }
}
