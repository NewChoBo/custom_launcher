## GitHub Copilot 사용 지침서: Custom Desktop App (Flutter Desktop)

### 1. 목적

- Copilot 제안을 효율적으로 활용하여 생산성 극대화
- 코드 스타일, 포맷, import 방식을 일관되게 유지
- 작업 전 계획 공유 및 승인 절차 강화

### 2. 코드 작성 전 확인 사항

- Copilot은 코드를 생성하기 전에 프로젝트 구조를 직접 탐색해야 합니다:

```dart
// NOTE [Copilot]: lib/ 폴더 구조와 파일 위치를 먼저 확인해주세요.
```

- Copilot은 구현 전 관련된 **베스트 프랙티스**를 조사하여, 여러 옵션을 제시해야 합니다:

```text
Copilot: 해당 기능 구현을 위한 몇 가지 베스트 프랙티스가 있습니다. 아래 옵션 중 선택해주세요:
1) 간단한 API 호출 방식
2) 이벤트 기반 아키텍처 방식
3) 상태 관리 패턴 적용 방식

어떤 방법이 좋을까요?
```

### 3. Copilot 프롬프트 전략

1. **컨텍스트 주석**: 파일 상단에 기능 설명 및 경로 명시

```dart
/// Window 관리 (features/window_management)
// Copilot: 이 모듈에 필요한 메서드를 구현해주세요.
```

2. **DI 등록 요청**: `injection.dart` 로드 후 서비스 등록 지시

```dart
// TODO [Copilot]: core/di/injection.dart에 MyRepositoryImpl 등록
```

3. **절대 import 강제**: 상대경로 대신 절대 import 사용 유도

```dart
// FIXME [Copilot]: `package:custom_desktop/...` 절대 import로 수정해주세요
```

4. **작업 분할**: 복합 기능은 단계별로 요청하고, 각 변경은 최대 100줄 이하로 유지하세요.

```dart
// PROPOSAL [Copilot]:
// 1) 수정 파일: features/window_management/usecases.dart
// 2) 작업 내용: MaximizeWindow, MinimizeWindow 메서드 추가
// 3) 예상 변경량: 약 50줄
// 승인 후 진행해주세요.
```

5. **모르는 내용 처리**: 모르면 `잘 모르겠습니다.` 명시

```dart
// NOTE [Copilot]: 공식 문서를 참조하거나, 모르면 "잘 모르겠습니다."라고 알려주세요.
```

6. **인터넷 참조**: 공식 문서나 StackOverflow 링크 삽입 권장

```markdown
<!-- Copilot: Flutter 공식 문서(https://docs.flutter.dev/) 참고 -->
```

### 4. 주석 & 태그 패턴

| 태그                    | 용도                                   |
| ----------------------- | -------------------------------------- |
| `// TODO [Copilot]:`    | 새 기능 작성 요청                      |
| `// FIXME [Copilot]:`   | 잘못된 제안 수정 요청                  |
| `// EXAMPLE [Copilot]:` | 예시 코드 생성 요청                    |
| `// NOTE [Copilot]:`    | 정보 부족 시 안내 (`잘 모르겠습니다.`) |
| `// DO NOT MODIFY`      | 보호할 핵심 로직 표시                  |

### 5. 작업 계획 및 승인 절차

- Copilot은 변경 전 계획을 채팅 메시지로 공유하고, 사용자의 승인을 받은 후에 코드 작성하세요.
- 각 단계가 완료되면 다시 채팅으로 진행 여부를 확인해야 합니다.

### 6. 방지할 이슈

Copilot 제안 시 다음 문제를 발생시키지 않도록 주의하세요:

- **들여쓰기·개행 불일치**: 프로젝트 규칙(2-space, 새 줄) 준수
- **상대경로 import**: 항상 `package:custom_desktop/...` 절대 경로 사용
- **deprecated API 제안**: 최신 릴리즈 노트를 반영

### 7. 예시 대화 흐름

```text
Copilot: 해당 기능을 구현하기 전, 몇 가지 베스트 프랙티스를 조사했습니다.
옵션:
1) 간단한 API 호출 방식
2) 이벤트 기반 아키텍처 방식
3) 상태 관리 패턴 적용 방식

어떤 방법이 좋을까요?

(사용자: 2번)

Copilot: 변경 계획을 제안합니다:
1) 수정 파일: features/window_management/usecases.dart
2) 작업 내용: maximizeWindow(), minimizeWindow() 메서드 구현
3) 변경 예상량: 약 40줄

위 계획으로 진행해도 될까요?

(사용자: 좋아요, 진행해주세요.)

[Copilot이 부분 구현 후 다시 멈추고]
Copilot: 첫 번째 메서드 구현이 완료되었습니다. 계속 진행할까요?
```

---

_이 문서는 Copilot과의 협업 시 핵심 절차와 규칙만 담고 있습니다._
