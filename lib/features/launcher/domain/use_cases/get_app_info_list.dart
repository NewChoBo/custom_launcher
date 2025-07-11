import 'package:custom_launcher/features/launcher/domain/entities/app_info.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';

class GetAppInfoList {
  final AppRepository repository;

  GetAppInfoList(this.repository);

  Future<List<AppInfo>> call() async {
    return await repository.getAppInfoList();
  }
}
