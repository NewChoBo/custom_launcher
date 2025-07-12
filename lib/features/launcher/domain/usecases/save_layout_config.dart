import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class SaveLayoutConfigParams extends UseCaseParams {
  final LayoutConfig layoutConfig;

  const SaveLayoutConfigParams(this.layoutConfig);

  @override
  List<Object?> get props => [layoutConfig];
}

class SaveLayoutConfig extends UseCaseWithParams<void, SaveLayoutConfigParams> {
  final LayoutRepository repository;

  SaveLayoutConfig(this.repository);

  @override
  Future<void> execute(SaveLayoutConfigParams params) async {
    await repository.saveLayoutConfig(params.layoutConfig);
  }
}
