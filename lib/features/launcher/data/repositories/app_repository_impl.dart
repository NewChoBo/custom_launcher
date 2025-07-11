import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/entities/app_settings.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/data/data_sources/app_local_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource localDataSource;

  AppRepositoryImpl({required this.localDataSource});

  @override
  Future<List<AppInfo>> getAppInfoList() async {
    return await localDataSource.getAppInfoList();
  }

  @override
  Future<AppSettings> getAppSettings() async {
    return await localDataSource.getAppSettings();
  }
}
