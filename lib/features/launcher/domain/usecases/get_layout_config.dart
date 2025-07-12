import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class GetLayoutConfig extends UseCase<LayoutConfig> {
  final LayoutRepository repository;

  GetLayoutConfig(this.repository);

  @override
  Future<LayoutConfig> execute() async {
    return await repository.getLayoutConfig();
  }
}
