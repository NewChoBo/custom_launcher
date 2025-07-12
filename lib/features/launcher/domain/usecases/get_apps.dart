import 'package:custom_launcher/features/launcher/data/models/app_model.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/app_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class GetApps extends UseCase<List<AppModel>> {
  final AppRepository repository;

  GetApps(this.repository);

  @override
  Future<List<AppModel>> execute() async {
    return await repository.getApps();
  }
}
