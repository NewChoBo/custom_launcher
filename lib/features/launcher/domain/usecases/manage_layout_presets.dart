import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';
import 'package:custom_launcher/features/launcher/domain/repositories/layout_repository.dart';
import 'package:custom_launcher/features/launcher/domain/usecases/base_usecase.dart';

// 레이아웃 프리셋 목록 가져오기
class GetLayoutPresets extends UseCase<List<String>> {
  final LayoutRepository repository;

  GetLayoutPresets(this.repository);

  @override
  Future<List<String>> execute() async {
    return await repository.getLayoutPresets();
  }
}

// 레이아웃 프리셋 저장
class SaveLayoutPresetParams extends UseCaseParams {
  final String presetName;
  final LayoutConfig layoutConfig;

  const SaveLayoutPresetParams({
    required this.presetName,
    required this.layoutConfig,
  });

  @override
  List<Object?> get props => [presetName, layoutConfig];
}

class SaveLayoutPreset extends UseCaseWithParams<void, SaveLayoutPresetParams> {
  final LayoutRepository repository;

  SaveLayoutPreset(this.repository);

  @override
  Future<void> execute(SaveLayoutPresetParams params) async {
    await repository.saveLayoutPreset(params.presetName, params.layoutConfig);
  }
}

// 레이아웃 프리셋 로드
class LoadLayoutPresetParams extends UseCaseParams {
  final String presetName;

  const LoadLayoutPresetParams(this.presetName);

  @override
  List<Object?> get props => [presetName];
}

class LoadLayoutPreset
    extends UseCaseWithParams<LayoutConfig, LoadLayoutPresetParams> {
  final LayoutRepository repository;

  LoadLayoutPreset(this.repository);

  @override
  Future<LayoutConfig> execute(LoadLayoutPresetParams params) async {
    return await repository.loadLayoutPreset(params.presetName);
  }
}

// 레이아웃 프리셋 삭제
class DeleteLayoutPresetParams extends UseCaseParams {
  final String presetName;

  const DeleteLayoutPresetParams(this.presetName);

  @override
  List<Object?> get props => [presetName];
}

class DeleteLayoutPreset
    extends UseCaseWithParams<void, DeleteLayoutPresetParams> {
  final LayoutRepository repository;

  DeleteLayoutPreset(this.repository);

  @override
  Future<void> execute(DeleteLayoutPresetParams params) async {
    await repository.deleteLayoutPreset(params.presetName);
  }
}

// 레이아웃 초기화
class ResetToDefaultLayout extends UseCase<void> {
  final LayoutRepository repository;

  ResetToDefaultLayout(this.repository);

  @override
  Future<void> execute() async {
    await repository.resetToDefaultLayout();
  }
}

// 레이아웃 내보내기
class ExportLayoutToJson extends UseCase<String> {
  final LayoutRepository repository;

  ExportLayoutToJson(this.repository);

  @override
  Future<String> execute() async {
    return await repository.exportLayoutToJson();
  }
}

// 레이아웃 가져오기
class ImportLayoutFromJsonParams extends UseCaseParams {
  final String jsonString;

  const ImportLayoutFromJsonParams(this.jsonString);

  @override
  List<Object?> get props => [jsonString];
}

class ImportLayoutFromJson
    extends UseCaseWithParams<void, ImportLayoutFromJsonParams> {
  final LayoutRepository repository;

  ImportLayoutFromJson(this.repository);

  @override
  Future<void> execute(ImportLayoutFromJsonParams params) async {
    await repository.importLayoutFromJson(params.jsonString);
  }
}
