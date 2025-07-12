import 'package:custom_launcher/core/di/service_locator.dart';
import 'package:custom_launcher/core/logging/logging.dart';
import 'package:custom_launcher/core/error/error_handler.dart';
import 'package:custom_launcher/core/services/system_tray_service.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';
import 'package:custom_launcher/features/launcher/data/repositories/app_repository_impl.dart';
import 'package:custom_launcher/features/launcher/data/repositories/settings_repository_impl.dart';
import 'package:custom_launcher/features/launcher/data/repositories/layout_repository_impl.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/settings_repository.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';

/// 의존성 주입 컨테이너 초기화
class InjectionContainer {
  static bool _initialized = false;

  /// 의존성 주입 컨테이너 초기화
  static Future<void> init() async {
    if (_initialized) return;

    LogManager.info('Initializing dependency injection container', tag: 'DI');

    // 1. 코어 서비스들
    await _initCoreServices();

    // 2. 데이터 소스들
    await _initDataSources();

    // 3. 리포지토리들
    await _initRepositories();

    // 4. 사용 사례들
    await _initUseCases();

    // 5. 서비스들
    await _initServices();

    _initialized = true;
    LogManager.info(
      'Dependency injection container initialized successfully',
      tag: 'DI',
    );
  }

  /// 코어 서비스들 초기화
  static Future<void> _initCoreServices() async {
    // 로깅 시스템
    sl.registerSingleton<LogManager>(LogManager.instance);

    // 에러 핸들러
    sl.registerSingleton<ErrorHandler>(ErrorHandler.instance);

    LogManager.debug('Core services registered', tag: 'DI');
  }

  /// 데이터 소스들 초기화
  static Future<void> _initDataSources() async {
    // 로컬 데이터 소스
    sl.registerLazySingleton<AppLocalDataSource>(
      () => AppLocalDataSourceImpl(),
    );

    LogManager.debug('Data sources registered', tag: 'DI');
  }

  /// 리포지토리들 초기화
  static Future<void> _initRepositories() async {
    // 앱 리포지토리
    sl.registerLazySingleton<AppRepository>(
      () => AppRepositoryImpl(localDataSource: sl.get<AppLocalDataSource>()),
    );

    // 설정 리포지토리
    sl.registerLazySingleton<SettingsRepository>(
      () =>
          SettingsRepositoryImpl(localDataSource: sl.get<AppLocalDataSource>()),
    );

    // 레이아웃 리포지토리
    sl.registerLazySingleton<LayoutRepository>(() => LayoutRepositoryImpl());

    LogManager.debug('Repositories registered', tag: 'DI');
  }

  /// 사용 사례들 초기화
  static Future<void> _initUseCases() async {
    // 사용 사례들은 필요에 따라 팩토리로 등록
    // 현재는 Riverpod을 사용하므로 여기서는 생략

    LogManager.debug('Use cases registered', tag: 'DI');
  }

  /// 서비스들 초기화
  static Future<void> _initServices() async {
    // 시스템 트레이 서비스
    sl.registerLazySingleton<SystemTrayService>(() => SystemTrayService());

    LogManager.debug('Services registered', tag: 'DI');
  }

  /// 의존성 주입 컨테이너 정리
  static void dispose() {
    LogManager.info('Disposing dependency injection container', tag: 'DI');

    // 등록된 서비스들 중 dispose 메서드가 있는 것들 정리
    try {
      if (sl.isRegistered<SystemTrayService>()) {
        sl.get<SystemTrayService>().dispose();
      }
    } catch (e) {
      LogManager.warn('Error disposing SystemTrayService', tag: 'DI', error: e);
    }

    // 서비스 로케이터 리셋
    sl.reset();
    _initialized = false;

    LogManager.info('Dependency injection container disposed', tag: 'DI');
  }

  /// 등록된 서비스들 정보 출력
  static void printRegisteredServices() {
    final services = sl.getRegisteredServices();
    LogManager.info('Registered services (${services.length}):', tag: 'DI');

    for (final service in services) {
      LogManager.info('  - ${service.toString()}', tag: 'DI');
    }
  }
}

/// 의존성 주입 컨테이너 초기화를 위한 단축 함수
Future<void> initializeDependencies() async {
  await InjectionContainer.init();
}
