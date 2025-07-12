import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';
import 'package:custom_launcher/features/launcher/data/models/app_model.dart';

class UpdateApp extends UseCaseWithParams<void, UpdateAppParams> {
  final AppRepository repository;

  UpdateApp(this.repository);

  @override
  Future<void> execute(UpdateAppParams params) async {
    await repository.updateApp(
      AppModel.fromJson({'id': params.appId, ...params.updates}),
    );
  }
}
