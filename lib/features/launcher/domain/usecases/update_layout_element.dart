import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

class UpdateLayoutElementParams extends UseCaseParams {
  final String elementPath;
  final Map<String, dynamic> updates;

  const UpdateLayoutElementParams({
    required this.elementPath,
    required this.updates,
  });

  @override
  List<Object?> get props => [elementPath, updates];
}

class UpdateLayoutElement
    extends UseCaseWithParams<void, UpdateLayoutElementParams> {
  final LayoutRepository repository;

  UpdateLayoutElement(this.repository);

  @override
  Future<void> execute(UpdateLayoutElementParams params) async {
    await repository.updateLayoutElement(params.elementPath, params.updates);
  }
}
