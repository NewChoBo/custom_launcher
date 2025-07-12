import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class LaunchApp extends UseCaseWithParams<void, AppIdParams> {
  final AppRepository repository;

  LaunchApp(this.repository);

  @override
  Future<void> execute(AppIdParams params) async {
    await repository.launchApp(params.appId);
  }
}
