import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';
import 'package:custom_launcher/features/launcher/data/repositories/app_repository_impl.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';

import 'package:custom_launcher/features/launcher/data/app_data_repository.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

// Data Sources
final appLocalDataSourceProvider = Provider<AppLocalDataSource>(
  (ref) => AppLocalDataSourceImpl(),
);

// Repositories
final appRepositoryProvider = Provider<AppRepository>(
  (ref) =>
      AppRepositoryImpl(localDataSource: ref.read(appLocalDataSourceProvider)),
);

// Use Cases
final getAppInfoListProvider = FutureProvider<List<AppInfo>>(
  (ref) => ref.read(appRepositoryProvider).getAppInfoList(),
);

final getAppSettingsProvider = FutureProvider<AppSettings>(
  (ref) => ref.read(appRepositoryProvider).getAppSettings(),
);

final appDataRepositoryProvider =
    AsyncNotifierProvider<AppDataRepository, List<AppModel>>(() {
      return AppDataRepository();
    });
