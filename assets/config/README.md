# 설정파일 구성 계획

## 1. Launcher 설정파일

```json
{
    "version": "1.0",
    "launchers": {
        "steam": {
            "id": "steam",
            "displayName": "Steam",
            "description": "The game store I love",
            "category": "gaming",
            "images": {
                "default": "@/icons/steam.png",
                "large": "@/icons/steam_large.png",
                "small": "@/icons/steam_small.png",
                "banner": "@/icons/steam_banner.jpg",
                "logo": "@/icons/steam_logo.svg"
            },
            "actions": {
                "default": {
                    "type": "execute",
                    "target": "C:/Program Files (x86)/Steam/Steam.exe",
                    "arguments": [],
                    "workingDirectory": ""
                },
                "bigpicture": {
                    "type": "execute",
                    "target": "C:/Program Files (x86)/Steam/Steam.exe",
                    "arguments": ["-bigpicture"]
                },
                "library": {
                    "arguments": ["-silent"]
                },
                "quickstart": {
                    "arguments": ["-login", "anonymous"]
                }
            }
        }
    }
}
```

## 2. Layout 설정파일

```json
{
    "version": "1.0",
    "metadata": {
        "title": "Work Mode",
        "description": "Productivity focused layout",
        "author": "User",
        "created": "2025-07-04",
        "tags": ["work", "productivity"]
    },
    "frame": {
        "ui": {
            "showAppBar": false,
            "colors": {
                "appBarColor": "#2196F3",
                "backgroundColor": "#424242"
            },
            "opacity": {
                "appBarOpacity": 0.5,
                "backgroundOpacity": 0.1
            }
        },
        "window": {
            "size": {
                "windowWidth": "80%",
                "windowHeight": "50%"
            },
            "position": {
                "horizontalPosition": "center",
                "verticalPosition": "bottom"
            },
            "behavior": {
                "windowLevel": "alwaysOnTop",
                "skipTaskbar": true
            }
        },
        "system": {
            "monitorIndex": 2
        }
    },
    "layout": {
        "type": "column",
        "spacing": 8,
        "padding": {"top": 16, "bottom": 16, "left": 16, "right": 16},
        "children": [
            {
                "type": "row",
                "spacing": 8,
                "children": [
                    {
                        "type": "launcher",
                        "id": "steam_launcher_1",
                        "launcherRef": "steam",
                        "overrides": {
                            "displayName": "Steam (Gaming)",
                            "imageType": "large",
                            "action": "bigpicture"
                        },
                        "position": {
                            "width": 5,
                            "height": 5,
                            "flex": 1
                        },
                        "style": {
                            "backgroundColor": "#1e3a8a",
                            "borderRadius": 8,
                            "elevation": 2
                        }
                    }
                ]
            }
        ]
    },
    "globalSettings": {
        "theme": "dark",
        "animations": true,
        "autoHide": false,
        "defaultImageType": "default",
        "defaultActionType": "default"
    }
}
```

## 3. 주요 특징

### 자유로운 키 네이밍

**Images 섹션** - `default` 외에는 원하는 이름 사용 가능:

```json
"images": {
    "default": "@/icons/steam.png",    // 필수: 기본 이미지
    "myCustomIcon": "@/icons/custom.png",
    "evenMoreCustom": "@/icons/whatever.jpg",
    "사용자정의이름": "@/icons/korean.svg"
}
```

**Actions 섹션** - `default` 외에는 원하는 이름 사용 가능:

```json
"actions": {
    "default": {...},                  // 필수: 기본 액션
    "quickLaunch": {...},
    "adminMode": {...},
    "특별실행": {...}
}
```

### 설정 상속 및 오버라이드

**기본 원리**: 모든 액션은 `default` 설정을 먼저 상속받은 후, 명시된 속성만 덮어씌웁니다.

### 통합된 프레임 설정

**Frame 섹션**: 기존 `app_settings.json`의 모든 기능을 레이아웃별로 설정 가능

```json
"frame": {
    "ui": {
        "showAppBar": false,              // 앱바 표시 여부
        "colors": {
            "appBarColor": "#2196F3",     // 앱바 색상
            "backgroundColor": "#424242"   // 배경 색상
        },
        "opacity": {
            "appBarOpacity": 0.5,         // 앱바 투명도
            "backgroundOpacity": 0.1      // 배경 투명도
        }
    },
    "window": {
        "size": {
            "windowWidth": "80%",         // 창 너비 (px 또는 %)
            "windowHeight": "50%"         // 창 높이 (px 또는 %)
        },
        "position": {
            "horizontalPosition": "center", // left, center, right
            "verticalPosition": "bottom"    // top, center, bottom
        },
        "behavior": {
            "windowLevel": "alwaysOnTop",   // normal, alwaysOnTop, alwaysOnBottom
            "skipTaskbar": true             // 작업표시줄에서 숨김
        }
    },
    "system": {
        "monitorIndex": 2                 // 다중 모니터 지원 (0부터 시작)
    }
}
```

**레이아웃별 개별 설정**: 각 레이아웃마다 다른 창 설정 가능

- 작업 모드: 큰 창, 중앙 정렬
- 게임 모드: 작은 창, 우측 하단
- 미디어 모드: 투명 배경, 항상 위에

**예시 - 위 Steam 설정에서**:

```json
// default 액션의 모든 속성
"default": {
    "type": "execute",
    "target": "C:/Program Files (x86)/Steam/Steam.exe", 
    "arguments": [],
    "workingDirectory": ""
}

// library 액션 = default 상속 + arguments만 오버라이드
"library": {
    "arguments": ["-silent"]
    // type, target, workingDirectory는 default에서 자동 상속
}

// 실제 실행 시 library는 다음과 같이 해석됨:
{
    "type": "execute",
    "target": "C:/Program Files (x86)/Steam/Steam.exe",
    "arguments": ["-silent"],
    "workingDirectory": ""
}
```

**생략 가능한 속성들**:

- `type` - default에서 상속
- `target` - default에서 상속  
- `workingDirectory` - default에서 상속
- `arguments` - 필요시에만 오버라이드

### 확장성 (Scalability)

- `version` 필드로 스키마 버전 관리
- `category`로 런처 그룹화 지원
- `metadata`로 레이아웃 정보 체계적 관리

### 유연성 (Flexibility)

- 다중 액션 지원 (`primary`, `secondary`)
- 다양한 아이콘 크기/타입 지원
- 세밀한 오버라이드 옵션 (`overrides`)

### 사용성 (Usability)

- 키보드 단축키 지원
- 가시성 제어 옵션
- 스타일링 옵션 (색상, 모서리, 그림자)

### 유지보수성 (Maintainability)

- 명확한 참조 시스템 (`launcherRef`)
- 구조화된 설정 분리
- 일관된 네이밍 규칙

## 4. 통합된 설정 구조

### Frame 설정으로 app_settings.json 대체

기존의 `app_settings.json` 파일 기능이 레이아웃 설정의 `frame` 섹션으로 통합되었습니다:

**장점:**

- **레이아웃별 맞춤 설정**: 각 레이아웃마다 다른 창 동작
- **설정 통합**: 별도 파일 관리 불필요
- **컨텍스트 기반**: 레이아웃 용도에 맞는 UI 설정

**마이그레이션 가이드:**

```json
// 기존 app_settings.json → 새로운 layout의 frame 섹션
{
  "window": {"size": {"windowWidth": "80%"}} 
  → "frame": {"window": {"size": {"windowWidth": "80%"}}}
}
```

## 5. 추가 고려사항

1. **조건부 표시**: 특정 앱이 설치된 경우에만 표시
2. **동적 경로**: 환경변수나 레지스트리 기반 경로 해석
3. **플러그인 시스템**: 커스텀 액션 타입 확장
4. **테마 시스템**: 다양한 UI 테마 지원
