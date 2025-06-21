## GitHub Copilot 사용 지침서: Custom Desktop App (Flutter Desktop)

### 1. 목적

- Copilot 제안을 효율적으로 활용하여 생산성 극대화
- 코드 스타일, 포맷, import 방식을 일관되게 유지
- 작업 전 계획 공유 및 승인 절차 강화
- **UI에 표시될 텍스트는 영어로 작성**
- **라이브러리는 가능한 최신 버전으로 사용 및 유지**, 버전별 사용법 차이를 고려하여 공식 문서 자주 확인
- **질문과 요청을 구분하여 동작**: 질문에는 옵션 및 설명 제공, 요청에는 계획 공유 후 실행
- **명령어 실행 요청 시**, 사용자 환경(Windows PowerShell, macOS 터미널, Linux 셸 등)에 맞는 명령어로 작성
- 요청된 작업만 수행하고, 추가 작업이 필요할 경우 반드시 사전 계획 공유 및 승인을 받아야 합니다.

### 2. 코드 작성 전 확인 사항

1. **프로젝트 구조 탐색**

   ```dart
   // NOTE [Copilot]: lib/ 폴더 구조와 파일 위치를 먼저 확인해주세요.
   ```

2. **코딩 규칙 파악**
   Copilot은 타 코드 파일을 분석하여 네이밍, 들여쓰기, 에러 처리 방식 등 팀의 규칙을 학습해야 합니다.

   ```text
   Copilot: 프로젝트의 기존 코드 스타일(네이밍, 예외 처리, 주석 등)을 분석했습니다.
   주요 규칙:
   - 클래스·메서드 네이밍: PascalCase / camelCase
   - 들여쓰기: 2-space
   - 예외 처리: try-catch 후 로깅
   계속 진행하겠습니다.
   ```

3. **질문 vs 요청 구분**

   ```text
   Copilot: 사용자의 입력이 '질문'인지 '요청'인지 판별했습니다.
   - 질문: 구현 방법, 옵션, 모범 사례 제시
   - 요청: 코드 작성, 변경, 수정 작업 수행 (승인 절차 후)
   ```

4. **베스트 프랙티스 조사**

   ```text
   Copilot: 해당 기능 구현을 위한 몇 가지 베스트 프랙티스:
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

4. **라이브러리 버전 확인**: 제안된 코드에 사용하는 패키지의 버전을 명시하고, 공식 문서를 참고하여 사용법 차이를 설명하도록 요청하세요.

   ```text
   Copilot: 이 코드에서는 `window_manager` 최신 버전(v0.5.x)을 사용합니다. 해당 버전의 공식 문서를 참고하여 API 사용법이 달라진 부분이 있는지 확인해주세요.
   ```

5. **명령어 실행 요청**: 사용자가 실행을 요청한 명령어는 현재 환경에 맞게 작성해야 합니다.

   ```text
   Copilot: Windows PowerShell 환경에서 실행할 명령어는 `.\script.ps1` 형식으로, macOS/Linux 셸에서는 `./script.sh` 형식으로 제안드립니다.
   ```

6. **작업 분할 및 승인 프로세스**

   ```text
   Copilot: 변경 계획 제안
   1) 수정 파일: features/window_management/usecases.dart
   2) 작업 내용: MaximizeWindow, MinimizeWindow 메서드 추가
   3) 예상 변경량: 약 50줄
   계속 진행해도 될까요?
   ```

7. **모르는 내용 처리**: 모르면 `잘 모르겠습니다.` 명시

   ```dart
   // NOTE [Copilot]: 공식 문서를 참조하거나, 모르면 "잘 모르겠습니다."라고 알려주세요.
   ```

8. **인터넷 참조**: 공식 문서나 StackOverflow 링크 삽입 권장

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

- 변경 전 반드시 채팅으로 계획을 공유하고 승인을 받아야 합니다.
- 각 단계 완료 후에도 채팅으로 진행 여부를 확인해야 합니다.

### 6. 방지할 이슈

Copilot 제안 시 다음 문제를 발생시키지 않도록 주의하세요:

- **들여쓰기·개행 불일치**: 프로젝트 규칙(2-space, 새 줄) 준수
- **상대경로 import**: 항상 `package:custom_desktop/...` 절대 경로 사용
- **DI 등록 누락**: `injection.dart`에 모든 구현체 등록
- **deprecated API 제안**: 최신 릴리즈 노트를 반영

### 7. 예시 대화 흐름

```text
Copilot: 프로젝트 코드 스타일을 분석했습니다.
- 네이밍: PascalCase / camelCase
- 들여쓰기: 2-space
- 예외 처리: try-catch 후 로깅

Copilot: 사용자의 입력이 질문인지 요청인지 판별했습니다.
- 질문: 옵션 제시, 설명 제공
- 요청: 코드 작업 계획 제안 및 승인 후 실행

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
3) 예상 변경량: 약 40줄

위 계획으로 진행해도 될까요?

(사용자: 좋아요, 진행해주세요.)

[Copilot이 부분 구현 후 다시 멈추고]
Copilot: 첫 번째 메서드 구현이 완료되었습니다. 계속 진행할까요?
```

---

_이 문서는 Copilot과의 협업 시 핵심 절차와 규칙만 담고 있습니다._
