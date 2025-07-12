# 프로젝트 아키텍처 및 개발 가이드라인

이 문서는 Custom Launcher Flutter 프로젝트의 아키텍처 전략, 파일 구조, 그리고 다양한 구성 요소의 주요 책임을 설명합니다.

## 1. 전반적인 전략 및 계획

Custom Launcher는 고도로 사용자 정의 가능하고 효율적인 애플리케이션 실행 경험을 제공하는 것을 목표로 합니다. 우리의 개발 전략은 다음 사항에 중점을 둡니다:

* **모듈성:** 애플리케이션을 명확하고 관리 가능한 기능과 핵심 서비스로 분할합니다.
* **관심사 분리:** 데이터, 도메인 로직, 프레젠테이션 계층에 대한 책임을 명확하게 정의합니다.
* **상태 관리:** 강력하고 확장 가능한 상태 관리를 위해 Riverpod을 활용합니다.
* **플랫폼 통합:** Flutter의 플랫폼 채널을 활용하여 운영 체제와 깊이 있게 상호 작용합니다.
* **사용자 경험:** 유동적이고 반응성이 뛰어나며 시각적으로 매력적인 사용자 인터페이스를 우선시합니다.
* **확장성:** 향후 기능 및 잠재적인 플러그인 시스템을 지원하도록 아키텍처를 설계합니다.

## 2. 파일 구조

프로젝트는 클린 아키텍처에서 영감을 받은 구조를 따르며, 주로 `lib/` 디렉토리 내에 구성됩니다:

``` tree
lib/
├── main.dart                     # 애플리케이션 진입점
├── core/                         # 핵심 서비스, 유틸리티 및 인프라
│   ├── providers/                # 전역 Riverpod 프로바이더
│   │   └── app_providers.dart    # 핵심 서비스 및 데이터 리포지토리를 위한 프로바이더
│   ├── services/                 # 플랫폼별 서비스 (예: 창 관리, 시스템 트레이)
│   │   ├── system_tray_service.dart
│   │   └── window_service.dart
│   └── utils/                    # 일반 유틸리티 함수
└── features/                     # 기능별 모듈
    └── launcher/                 # 예시: 런처 기능
        ├── data/                 # 데이터 소스, 리포지토리 및 모델
        │   ├── app_data_repository.dart # 애플리케이션 데이터 영속성 관리
        │   └── models/           # 데이터 모델 (예: AppModel, ImageCropModel)
        │       ├── app_model.dart
        │       └── app_model.g.dart # json_serializable에 의해 생성됨
        ├── domain/               # 비즈니스 로직, 엔티티, 유스케이스 및 인터페이스
        │   ├── entities/         # 핵심 비즈니스 엔티티 (예: AppInfo, AppSettings, LayoutConfig)
        │   │   ├── app_info.dart
        │   │   ├── app_settings.dart
        │   │   └── layout_config.dart
        │   └── usecases/         # 애플리케이션별 유스케이스 (예: GetAppSettings)
        │       └── get_app_settings.dart
        └── presentation/         # UI 구성 요소, 위젯 및 뷰 모델/컨트롤러
            ├── providers/        # 기능별 Riverpod 프로바이더
            │   └── launcher_providers.dart # UI 상태 및 상호 작용을 위한 프로바이더
            ├── pages/            # 최상위 화면/페이지
            │   └── home_page.dart
            └── widgets/          # 재사용 가능한 UI 위젯
                ├── cards/        # 애플리케이션 카드 관련 위젯
                │   ├── app_settings_modal.dart # 앱 설정 편집을 위한 모달
                │   ├── custom_card_widget.dart # 개별 애플리케이션 카드 위젯
                │   └── image_edit_dialog.dart # 이미지 자르기/편집을 위한 다이얼로그
                ├── dynamic_layout/ # 동적 레이아웃 렌더링을 위한 위젯
                │   ├── builders/   # 다양한 레이아웃 요소(예: 행)를 위한 빌더
                │   │   ├── row_builder.dart
                │   │   └── spacing_util.dart
                │   └── dynamic_layout_widget.dart # 동적 레이아웃 렌더링을 위한 메인 위젯
                └── shared/         # 공유 UI 구성 요소
                    └── cropped_image_widget.dart # 잘린 이미지를 표시하기 위한 위젯
```

## 3. 파일별 역할 및 주요 메서드

### `lib/main.dart`

* **역할:** Flutter 애플리케이션의 진입점입니다. Riverpod을 초기화하고, 창 리스너를 설정하며, 루트 `MaterialApp`을 정의합니다.
* **주요 메서드:**
  * `main()`: 애플리케이션 부트스트랩.
  * `_MyAppState.initState()`: 창 리스너를 초기화합니다.
  * `_MyAppState.build()`: `MaterialApp` 및 `HomePage`를 포함한 메인 애플리케이션 위젯 트리를 빌드합니다.

### `lib/core/providers/app_providers.dart`

* **역할:** 핵심 서비스 및 데이터 리포지토리를 위한 전역 Riverpod 프로바이더를 중앙 집중화하여 애플리케이션 전체에서 접근할 수 있도록 합니다.
* **주요 프로바이더:**
  * `appLocalDataSourceProvider`: `AppLocalDataSource` 인스턴스를 제공합니다.
  * `appRepositoryProvider`: `AppRepository` 인스턴스를 제공합니다.
  * `getAppSettingsProvider`: 애플리케이션 설정을 비동기적으로 가져오는 `FutureProvider`.
  * `appDataRepositoryProvider`: 애플리케이션 데이터(`List<AppModel>`)를 관리하고 제공하는 `AsyncNotifierProvider`.

### `lib/core/services/system_tray_service.dart`

* **역할:** 시스템 트레이 아이콘 등록, 컨텍스트 메뉴 설정, 트레이 아이콘 클릭 이벤트 처리 등 시스템 트레이 관련 상호 작용을 관리합니다.
* **주요 메서드:** (`tray_manager` 패키지에 따라 다르며, 일반적으로 `initSystemTray`, `setContextMenu`, `onMenuItemClick`을 포함합니다.)

### `lib/core/services/window_service.dart`

* **역할:** 창 크기 조절, 위치 설정, 최소화/최대화, 창 수준(항상 위) 설정 등 애플리케이션 창의 다양한 속성과 동작을 제어합니다.
* **주요 메서드:** (`window_manager` 패키지에 따라 다르며, 일반적으로 `initWindowManager`, `setWindowSize`, `setWindowPosition`, `setWindowLevel`을 포함합니다.)

### `lib/features/launcher/data/app_data_repository.dart`

* **역할:** 로컬 JSON 파일에서 애플리케이션 데이터(`AppModel` 목록)의 로드, 저장 및 업데이트를 관리합니다. 애플리케이션 데이터의 단일 진실 공급원 역할을 합니다.
* **주요 메서드:**
  * `_localPath`: 로컬 애플리케이션 문서 디렉토리 경로에 대한 Getter.
  * `_localFile`: `app_data.json` 파일에 대한 Getter.
  * `_initiateData()`: `app_data.json`이 존재하도록 보장하며, 존재하지 않으면 에셋에서 복사합니다.
  * `build()`: (`AsyncNotifier`에서 상속) 초기 앱 데이터를 로드합니다.
  * `getAppById(String id)`: ID로 `AppModel`을 검색합니다.
  * `updateApp(AppModel updatedApp)`: 기존 `AppModel`을 업데이트하고 변경 사항을 파일에 영속화합니다.
  * `_saveData(List<AppModel> appsToSave)`: 현재 앱 목록을 JSON 파일에 쓰는 내부 메서드.

### `lib/features/launcher/data/models/app_model.dart`

* **역할:** `json_serializable`을 사용하여 개별 애플리케이션의 데이터 구조(속성 및 직렬화/역직렬화 로직 포함)를 정의합니다. 또한 이미지 자르기 데이터를 위한 `ImageCropModel`을 정의합니다.
* **주요 클래스:**
  * `AppModel`: 애플리케이션을 나타냅니다.
  * `ImageCropModel`: 이미지 자르기 변환 데이터를 나타냅니다.
* **주요 메서드:**
  * `AppModel.fromJson(Map<String, dynamic> json)`: 역직렬화를 위한 팩토리 생성자.
  * `AppModel.toJson()`: `AppModel`을 JSON으로 변환합니다.
  * `AppModel.copyWith()`: 업데이트된 속성으로 새 `AppModel` 인스턴스를 생성합니다.
  * `ImageCropModel.fromJson(Map<String, dynamic> json)`: 역직렬화를 위한 팩토리 생성자.
  * `ImageCropModel.toJson()`: `ImageCropModel`을 JSON으로 변환합니다.

### `lib/features/launcher/presentation/providers/launcher_providers.dart`

* **역할:** 런처 기능의 UI별 상태, 특히 애플리케이션 카드의 대화형 편집과 관련된 상태를 관리합니다.
* **주요 프로바이더:**
  * `editingAppIdProvider`: 현재 편집 중인 애플리케이션의 ID(이미지 자르기/위치 지정용)를 보유하는 `StateProvider`. 편집 중인 앱이 없으면 `null`입니다.
  * `editingTransformationControllerProvider`: 현재 편집 중인 앱 이미지의 `TransformationController` 인스턴스를 보유하는 `StateProvider`. 이 컨트롤러는 `CustomCardWidget`에 의해 생성되고 해제됩니다.

### `lib/features/launcher/presentation/widgets/cards/custom_card_widget.dart`

* **역할:** 개별 애플리케이션 카드를 표시하고, 애플리케이션 실행을 처리하며, 대화형 이미지 편집(자르기/확대) 기능을 관리합니다. 자체 `TransformationController`를 생성하고 해제할 책임이 있습니다.
* **주요 메서드:**
  * `_CustomCardState.build()`: 카드의 UI를 빌드하며, `isEditing`이 true일 때 이미지 편집을 위한 `InteractiveViewer`를 포함합니다.
  * `_CustomCardState._launchApplication()`: `Process.start`를 사용하여 연결된 애플리케이션을 실행합니다.
  * `_CustomCardState.initState()`: 위젯의 상태를 초기화합니다.
  * `_CustomCardState.dispose()`: 존재하는 경우 `TransformationController`를 포함한 리소스를 해제합니다.

### `lib/features/launcher/presentation/widgets/dynamic_layout/builders/row_builder.dart`

* **역할:** 레이아웃 구성을 기반으로 위젯 행을 빌드하며, 요소 재정렬을 지원합니다. 앱이 편집 모드일 때는 재정렬을 비활성화합니다.
* **주요 메서드:**
  * `RowBuilder.buildRow()`: `ReorderableRow` 또는 표준 `Row`를 구성하는 정적 메서드.
  * `_ReorderableRowWrapperState._onReorder()`: 자식 요소의 재정렬 로직을 처리합니다.
  * `_ReorderableRowWrapperState.build()`: `editingAppIdProvider`에 따라 `ReorderableRow` 또는 `Row`를 조건부로 렌더링합니다.

### `lib/features/launcher/presentation/widgets/shared/cropped_image_widget.dart`

* **역할:** `Matrix4`를 사용하여 적용된 지정된 자르기 변환으로 이미지를 표시합니다.
* **주요 메서드:**
  * `build()`: `Transform` 및 `ClipRect`를 사용하여 이미지에 `Matrix4` 변환을 적용합니다.

## 4. 미사용 코드 제거

문서 작성이 완료된 후, 미사용 코드를 최종적으로 확인하고 제거할 것입니다. 이전 상호 작용을 기반으로 `custom_card_widget.dart`의 `_showSettingsModal` 메서드는 이미 제거되었습니다. 다른 데드 코드가 남아 있지 않은지 확인할 것입니다.

## 5. 현재 진행 상황 및 향후 업데이트

이 문서는 Custom Launcher 프로젝트의 현재 아키텍처 상태를 반영합니다. 최근의 중요한 개발 내용은 다음과 같습니다:

* **`AppDataRepository` 리팩토링:** `AppDataRepository`는 `AsyncNotifierProvider`를 사용하여 로컬 파일 영속성을 포함한 애플리케이션 데이터의 더욱 강력하고 비동기적인 데이터 관리를 위해 리팩토링되었습니다.
* **향상된 이미지 편집:** `InteractiveViewer` 및 `TransformationController`를 사용하여 애플리케이션 카드에 대한 대화형 이미지 자르기 및 위치 지정 기능이 구현되었습니다. `TransformationController`의 관리는 `CustomCardWidget` 내에서 적절한 생명 주기 처리 및 리소스 해제를 보장하도록 개선되었습니다.

이 문서는 살아있는 가이드이며, Custom Launcher 프로젝트 내의 변경 사항, 새로운 기능 및 진화하는 아키텍처 결정을 반영하기 위해 지속적으로 업데이트될 것입니다.
