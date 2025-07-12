import 'package:custom_launcher/features/launcher/domain/entities/layout_config.dart';

abstract class LayoutRepository {
  // 레이아웃 설정 조회
  Future<LayoutConfig> getLayoutConfig();

  // 레이아웃 설정 저장
  Future<void> saveLayoutConfig(LayoutConfig layoutConfig);

  // 레이아웃 요소 업데이트
  Future<void> updateLayoutElement(
    String elementPath,
    Map<String, dynamic> updates,
  );

  // 레이아웃 요소 추가
  Future<void> addLayoutElement(
    String parentPath,
    Map<String, dynamic> elementData,
  );

  // 레이아웃 요소 제거
  Future<void> removeLayoutElement(String elementPath);

  // 레이아웃 요소 이동 (순서 변경)
  Future<void> moveLayoutElement(
    String elementPath,
    String newParentPath,
    int newIndex,
  );

  // 레이아웃 프리셋 관리
  Future<List<String>> getLayoutPresets();
  Future<void> saveLayoutPreset(String presetName, LayoutConfig layoutConfig);
  Future<LayoutConfig> loadLayoutPreset(String presetName);
  Future<void> deleteLayoutPreset(String presetName);

  // 레이아웃 초기화
  Future<void> resetToDefaultLayout();

  // 레이아웃 내보내기/가져오기
  Future<String> exportLayoutToJson();
  Future<void> importLayoutFromJson(String jsonString);
}
