# 설정파일 구성 계획

## 1. Launcher 설정파일

```
{
    launchers: {
        steam: {
            "text": "Steam",
            "memo": "The game store I love",
            "icons": {
                "btntype1": "@/icons/steam.png", ...
            },
            "actions": {
                "onClick": "C:/Program Files (x86)/Steam/Steam.exe"
            }
        }, ...
    }
}
```

## 2. Layout 설정파일

```
{
    "title": "작업모드",
    "layout": {
        "type":"column",
        "children":[
            {
                "type":"row",
                "children":[
                    {
                        "type": "launcher",
                        "appName": "steam",
                        "settings": {...}, // optional, launcher 설정 덮어씌우기
                        "width": 5,
                        "height": 5",
                        ...
                    },
                    ...
                ],
            },
            ...
        ],
        ...
    }
}
```
