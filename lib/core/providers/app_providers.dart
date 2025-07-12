import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/core/di/injection_container.dart';
import 'package:custom_launcher/core/di/service_locator.dart';
import 'package:custom_launcher/core/error/error_handler.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';

import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/get_apps.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/get_app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/launch_app.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/update_app.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/save_settings.dart';

final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return sl.get<ErrorHandler>();
});

final loggerProvider = Provider<Logger>((ref) {
  return LogManager.instance.logger;
});

final appLocalDataSourceProvider = Provider<AppLocalDataSource>((ref) {
  return sl.get<AppLocalDataSource>();
});

final appRepositoryProvider = Provider<AppRepository>((ref) {
  return sl.get<AppRepository>();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return sl.get<SettingsRepository>();
});

final layoutRepositoryProvider = Provider<LayoutRepository>((ref) {
  return sl.get<LayoutRepository>();
});

final getAppsUseCaseProvider = Provider<GetApps>((ref) {
  return GetApps(ref.read(appRepositoryProvider));
});

final getAppSettingsUseCaseProvider = Provider<GetAppSettings>((ref) {
  return GetAppSettings(ref.read(settingsRepositoryProvider));
});

final launchAppUseCaseProvider = Provider<LaunchApp>((ref) {
  return LaunchApp(ref.read(appRepositoryProvider));
});

final updateAppUseCaseProvider = Provider<UpdateApp>((ref) {
  return UpdateApp(ref.read(appRepositoryProvider));
});

final saveSettingsUseCaseProvider = Provider<SaveSettings>((ref) {
  return SaveSettings(ref.read(settingsRepositoryProvider));
});

class AppListNotifier extends StateNotifier<AsyncValue<List<AppModel>>> {
  final GetApps _getAppsUseCase;
  final LaunchApp _launchAppUseCase;
  final UpdateApp _updateAppUseCase;
  final ErrorHandler _errorHandler;
  final Logger _logger;

  AppListNotifier(
    this._getAppsUseCase,
    this._launchAppUseCase,
    this._updateAppUseCase,
    this._errorHandler,
    this._logger,
  ) : super(const AsyncValue.loading()) {
    Future.microtask(() => _loadApps());
  }

  Future<void> _loadApps() async {
    try {
      state = const AsyncValue.loading();
      final result = await _getAppsUseCase();

      if (mounted) {
        result
            .onSuccess((apps) {
              state = AsyncValue.data(apps);
            })
            .onFailure((error) {
              _logger.error(
                'Failed to load apps: ${error.message}',
                tag: 'AppListNotifier',
              );
              state = AsyncValue.error(error, StackTrace.current);
            });
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in _loadApps: $e',
        tag: 'AppListNotifier',
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> updateApp(String appId, Map<String, dynamic> updates) async {
    try {
      final params = UpdateAppParams(appId: appId, updates: updates);
      final result = await _updateAppUseCase(params);

      if (mounted) {
        result
            .onSuccess((_) {
              _logger.info(
                'App updated successfully: $appId',
                tag: 'AppListNotifier',
              );
              _loadApps();
            })
            .onFailure((error) {
              _logger.error(
                'Failed to update app: ${error.message}',
                tag: 'AppListNotifier',
              );
              _errorHandler.handleError(error);
            });
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in updateApp: $e',
        tag: 'AppListNotifier',
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> launchApp(String appId) async {
    try {
      final params = AppIdParams(appId);
      final result = await _launchAppUseCase(params);

      if (mounted) {
        result
            .onSuccess((_) {
              _logger.info(
                'App launched successfully: $appId',
                tag: 'AppListNotifier',
              );
              _loadApps();
            })
            .onFailure((error) {
              _logger.error(
                'Failed to launch app: ${error.message}',
                tag: 'AppListNotifier',
              );
              _errorHandler.handleError(error);
            });
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in launchApp: $e',
        tag: 'AppListNotifier',
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    await _loadApps();
  }
}

final appListNotifierProvider =
    StateNotifierProvider<AppListNotifier, AsyncValue<List<AppModel>>>(
      (ref) => AppListNotifier(
        ref.read(getAppsUseCaseProvider),
        ref.read(launchAppUseCaseProvider),
        ref.read(updateAppUseCaseProvider),
        ref.read(errorHandlerProvider),
        ref.read(loggerProvider),
      ),
    );

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final GetAppSettings _getSettingsUseCase;
  final SaveSettings _saveSettingsUseCase;
  final ErrorHandler _errorHandler;
  final Logger _logger;

  SettingsNotifier(
    this._getSettingsUseCase,
    this._saveSettingsUseCase,
    this._errorHandler,
    this._logger,
  ) : super(const AsyncValue.loading()) {
    Future.microtask(() => _loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      state = const AsyncValue.loading();
      final result = await _getSettingsUseCase();

      if (mounted) {
        result
            .onSuccess((settings) {
              state = AsyncValue.data(settings);
            })
            .onFailure((error) {
              _logger.error(
                'Failed to load settings: ${error.message}',
                tag: 'SettingsNotifier',
              );
              state = AsyncValue.error(error, StackTrace.current);
            });
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in _loadSettings: $e',
        tag: 'SettingsNotifier',
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    try {
      final result = await _saveSettingsUseCase(settings);

      if (mounted) {
        result
            .onSuccess((_) {
              _logger.info(
                'Settings saved successfully',
                tag: 'SettingsNotifier',
              );
              state = AsyncValue.data(settings);
            })
            .onFailure((error) {
              _logger.error(
                'Failed to save settings: ${error.message}',
                tag: 'SettingsNotifier',
              );
              _errorHandler.handleError(error);
            });
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Unexpected error in saveSettings: $e',
        tag: 'SettingsNotifier',
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>(
      (ref) => SettingsNotifier(
        ref.read(getAppSettingsUseCaseProvider),
        ref.read(saveSettingsUseCaseProvider),
        ref.read(errorHandlerProvider),
        ref.read(loggerProvider),
      ),
    );

class LayoutNotifier extends StateNotifier<AsyncValue<LayoutConfig>> {
  final LayoutRepository _layoutRepository;
  final Logger _logger;

  LayoutNotifier(this._layoutRepository, this._logger)
    : super(const AsyncValue.loading()) {
    Future.microtask(() => _loadLayoutConfig());
  }

  Future<void> _loadLayoutConfig() async {
    try {
      state = const AsyncValue.loading();
      final config = await _layoutRepository.getLayoutConfig();
      if (mounted) {
        state = AsyncValue.data(config);
      }
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to load layout config: $e',
        tag: 'LayoutNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> saveLayoutConfig(LayoutConfig config) async {
    try {
      await _layoutRepository.saveLayoutConfig(config);
      if (mounted) {
        state = AsyncValue.data(config);
      }
      _logger.info('Layout config saved successfully', tag: 'LayoutNotifier');
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to save layout config: $e',
        tag: 'LayoutNotifier',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        state = AsyncValue.error(e, stackTrace);
      }
    }
  }

  Future<void> updateElement(
    String elementPath,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _layoutRepository.updateLayoutElement(elementPath, updates);
      await _loadLayoutConfig();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to update layout element: $e',
        tag: 'LayoutNotifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> addElement(
    String parentPath,
    Map<String, dynamic> elementData,
  ) async {
    try {
      await _layoutRepository.addLayoutElement(parentPath, elementData);
      await _loadLayoutConfig();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to add layout element: $e',
        tag: 'LayoutNotifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> removeElement(String elementPath) async {
    try {
      await _layoutRepository.removeLayoutElement(elementPath);
      await _loadLayoutConfig();
    } catch (e, stackTrace) {
      _logger.error(
        'Failed to remove layout element: $e',
        tag: 'LayoutNotifier',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> refresh() async {
    await _loadLayoutConfig();
  }
}

final layoutNotifierProvider =
    StateNotifierProvider<LayoutNotifier, AsyncValue<LayoutConfig>>(
      (ref) => LayoutNotifier(
        ref.read(layoutRepositoryProvider),
        ref.read(loggerProvider),
      ),
    );

final getAppSettingsProvider = FutureProvider<AppSettings>((ref) async {
  final useCase = ref.read(getAppSettingsUseCaseProvider);
  final result = await useCase();

  if (result.isSuccess) {
    return result.data!;
  } else {
    throw result.error!;
  }
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final logger = ref.read(loggerProvider);

  logger.info('Initializing app dependencies...', tag: 'AppInitialization');

  try {
    await InjectionContainer.init();
    logger.info(
      'App dependencies initialized successfully',
      tag: 'AppInitialization',
    );
  } catch (e, stackTrace) {
    logger.error(
      'Failed to initialize app dependencies: $e',
      tag: 'AppInitialization',
      error: e,
      stackTrace: stackTrace,
    );
    rethrow;
  }
});
