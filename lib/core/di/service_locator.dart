class ServiceLocator {
  static ServiceLocator? _instance;
  static ServiceLocator get instance => _instance ??= ServiceLocator._();

  ServiceLocator._();

  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, dynamic Function()> _lazyFactories = {};

  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  void registerLazySingleton<T>(T Function() factory) {
    _lazyFactories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    if (_lazyFactories.containsKey(T)) {
      final factory = _lazyFactories[T]!;
      final instance = factory();
      _singletons[T] = instance;
      _lazyFactories.remove(T);
      return instance as T;
    }

    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }

    throw Exception('Service of type $T is not registered');
  }

  bool isRegistered<T>() {
    return _singletons.containsKey(T) ||
        _lazyFactories.containsKey(T) ||
        _factories.containsKey(T);
  }

  void unregister<T>() {
    _singletons.remove(T);
    _lazyFactories.remove(T);
    _factories.remove(T);
  }

  void reset() {
    _singletons.clear();
    _lazyFactories.clear();
    _factories.clear();
  }

  List<Type> getRegisteredServices() {
    final services = <Type>{};
    services.addAll(_singletons.keys);
    services.addAll(_lazyFactories.keys);
    services.addAll(_factories.keys);
    return services.toList();
  }
}

final sl = ServiceLocator.instance;

mixin Injectable {
  T get<T>() => sl.get<T>();
  bool isRegistered<T>() => sl.isRegistered<T>();
}
