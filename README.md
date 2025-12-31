# Claude Code 通知 Hook

當 Claude Code 完成任務或等待輸入時，透過 macOS 語音和系統通知提醒你。

## 功能特色

- **語音通知 (TTS)** - 使用 macOS 中文語音播報任務狀態
- **系統通知** - 推送到 macOS 通知中心，支援自訂提示音
- **點擊跳轉** - 點擊通知自動跳轉到對應的終端 App
- **自動偵測終端** - 支援 VS Code、Terminal、iTerm2、Tabby、Cursor 等多種終端
- **任務名顯示** - 自動從工作目錄提取專案名稱，方便同時運行多個任務時識別

## 觸發事件

| 事件 | 說明 | 語音示例 |
|------|------|----------|
| `Stop` | Claude 完成任務時 | 老闆，my-project 任務完成啦，請看看 |
| `Notification (idle_prompt)` | Claude 等待輸入超過 60 秒 | 老闆，my-project 任務在等你指示呢 |
| `Notification (permission_prompt)` | Claude 需要授權操作時 | 老闆，my-project 任務需要你批准一下喔 |

## 系統需求

- macOS（已在 macOS Tahoe 測試）
- Python 3（macOS 內建）
- [terminal-notifier](https://github.com/julienXX/terminal-notifier)（用於系統通知和點擊跳轉）

## 安裝步驟

### 1. 安裝 terminal-notifier

```bash
brew install terminal-notifier
```

### 2. 下載腳本

```bash
# 克隆倉庫
git clone https://github.com/wickedapp/claude-notification-hook.git

# 或直接下載腳本
curl -o ~/claude-tts-notify.sh https://raw.githubusercontent.com/wickedapp/claude-notification-hook/main/claude-tts-notify.sh
chmod +x ~/claude-tts-notify.sh
```

### 3. 設定 Claude Code Hooks

編輯 `~/.claude/settings.json`，加入以下配置：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-tts-notify.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "idle_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-tts-notify.sh",
            "timeout": 30
          }
        ]
      },
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/claude-tts-notify.sh",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

> **注意**：請將 `/path/to/claude-tts-notify.sh` 替換為腳本的實際路徑。

你也可以直接複製 `hooks-settings.json` 的內容到你的設定檔中。

### 4. 開啟通知權限

首次執行時，需要在 macOS 中開啟 terminal-notifier 的通知權限：

1. 打開 **系統設定 (System Settings)**
2. 點擊 **通知 (Notifications)**
3. 找到 **terminal-notifier**
4. 開啟 **「允許通知」**
5. 建議設定為 **「提示」(Alerts)** 樣式

### 5. 重啟 Claude Code

設定完成後，重啟 Claude Code 使 hooks 生效。

## 自訂設定

編輯 `claude-tts-notify.sh` 頂部的配置區域：

```bash
# 稱呼
NICKNAME="老闆"

# 通知開關
ENABLE_TTS=true           # 語音通知
ENABLE_NOTIFICATION=true  # 系統通知 (通知中心)

# 中文語音選擇
VOICE="Yue (Premium)"

# 語速 (默認 180, 範圍 1-500)
RATE=180
```

---

## 語音選擇指南

### 步驟 1：查看可用的中文語音

在終端執行以下命令，列出所有中文語音：

```bash
say -v '?' | grep -i "zh\|chinese"
```

輸出示例：
```
Han (Premium)       zh_CN    # 你好！我叫瀚。
Meijia              zh_TW    # 你好，我叫美佳。
Meijia (Premium)    zh_TW    # 你好，我叫美佳。
Sinji               zh_HK    # 你好！我叫善怡。
Tingting            zh_CN    # 你好！我叫婷婷。
Yue (Premium)       zh_CN    # 你好！我叫月。
```

### 步驟 2：試聽語音

逐一測試每個語音，選擇你喜歡的：

```bash
# 普通話 (大陸) - 女聲
say -v "Tingting" "老闆，任務完成啦，請看看"

# 普通話 (大陸) - 女聲高級版
say -v "Yue (Premium)" "老闆，任務完成啦，請看看"

# 普通話 (大陸) - 男聲高級版
say -v "Han (Premium)" "老闆，任務完成啦，請看看"

# 普通話 (台灣) - 女聲
say -v "Meijia" "老闆，任務完成啦，請看看"

# 普通話 (台灣) - 女聲高級版
say -v "Meijia (Premium)" "老闆，任務完成啦，請看看"

# 粵語 (香港) - 女聲
say -v "Sinji" "老闆，任務完成啦，請看看"
```

### 步驟 3：設定語音

選定語音後，編輯 `claude-tts-notify.sh`，修改 `VOICE` 變數：

```bash
# 將 VOICE 改為你選擇的語音名稱
VOICE="Yue (Premium)"    # 例如：使用月（女聲高級版）
```

### 步驟 4：調整語速（可選）

如果語音太快或太慢，可以調整 `RATE` 參數：

```bash
RATE=180    # 默認語速
RATE=150    # 較慢
RATE=200    # 較快
```

測試不同語速：

```bash
say -v "Yue (Premium)" -r 150 "這是較慢的語速"
say -v "Yue (Premium)" -r 200 "這是較快的語速"
```

### 可用的中文語音列表

| 語音名稱 | 語言 | 性別 | 說明 |
|----------|------|------|------|
| `Tingting` | zh_CN | 女 | 普通話 (大陸) 基本版 |
| `Yue (Premium)` | zh_CN | 女 | 普通話 (大陸) 高級版 - 推薦 |
| `Han (Premium)` | zh_CN | 男 | 普通話 (大陸) 高級版 |
| `Meijia` | zh_TW | 女 | 普通話 (台灣) 基本版 |
| `Meijia (Premium)` | zh_TW | 女 | 普通話 (台灣) 高級版 |
| `Sinji` | zh_HK | 女 | 粵語 (香港) |

> **提示**：Premium 版本的語音更自然流暢，建議優先選用。

---

## 自訂通知訊息

如果想修改通知的文字內容，編輯 `claude-tts-notify.sh` 中的 `case` 區塊：

```bash
# 根据事件类型选择消息
case "$HOOK_EVENT" in
    "Stop"|"SubagentStop")
        # 任務完成時的訊息
        TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務完成啦，請看看"
        NOTIF_TITLE="任務完成"
        NOTIF_MESSAGE="${TASK_NAME} 任務完成啦，請看看"
        ;;
    "Notification")
        case "$NOTIFICATION_TYPE" in
            "idle_prompt")
                # 等待輸入時的訊息
                TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務在等你指示呢"
                NOTIF_TITLE="等待輸入"
                NOTIF_MESSAGE="${TASK_NAME} 任務在等你指示"
                ;;
            "permission_prompt")
                # 需要授權時的訊息
                TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務需要你批准一下喔"
                NOTIF_TITLE="需要授權"
                NOTIF_MESSAGE="${TASK_NAME} 任務需要你批准"
                ;;
        esac
        ;;
esac
```

### 可用的變數

| 變數 | 說明 | 示例 |
|------|------|------|
| `${NICKNAME}` | 你設定的稱呼 | 老闆 |
| `${TASK_NAME}` | 專案名稱（從工作目錄提取）| my-project |

### 訊息自訂示例

```bash
# 更正式的風格
TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 專案已完成，請審閱"

# 更活潑的風格
TTS_MESSAGE="嘿 ${NICKNAME}，${TASK_NAME} 搞定啦！快來看看"

# 簡潔風格
TTS_MESSAGE="${TASK_NAME} 完成"
```

## 工作原理

```
┌─────────────────┐
│  Claude Code    │
│  完成任務/等待   │
└────────┬────────┘
         │ 觸發 Hook
         ▼
┌─────────────────┐
│  Hook 傳送 JSON │
│  (stdin)        │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  claude-tts-notify.sh               │
│                                     │
│  1. 解析 JSON (hook_event_name,     │
│     notification_type, cwd)         │
│  2. 從 cwd 提取專案名稱             │
│  3. 偵測當前終端 App (TERM_PROGRAM) │
│  4. 發送系統通知 (terminal-notifier)│
│  5. 播放語音 (say)                  │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│  系統通知中心    │     │  語音播報       │
│  (可點擊跳轉)   │     │  (TTS)          │
└─────────────────┘     └─────────────────┘
```

### Hook 接收的 JSON 資料

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../transcript.jsonl",
  "cwd": "/path/to/your/project",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "notification_type": "idle_prompt"
}
```

### 自動終端偵測

腳本會讀取 `$TERM_PROGRAM` 環境變數，自動偵測當前使用的終端 App：

| 終端 | TERM_PROGRAM | Bundle ID |
|------|--------------|-----------|
| VS Code | `vscode` | `com.microsoft.VSCode` |
| Terminal.app | `Apple_Terminal` | `com.apple.Terminal` |
| iTerm2 | `iTerm.app` | `com.googlecode.iterm2` |
| Tabby | `Tabby` | `org.tabby` |
| 其他 | 自動獲取 | 動態偵測 |

## 測試

```bash
# 測試任務完成通知
echo '{"hook_event_name": "Stop", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh

# 測試等待輸入通知
echo '{"hook_event_name": "Notification", "notification_type": "idle_prompt", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh

# 測試需要授權通知
echo '{"hook_event_name": "Notification", "notification_type": "permission_prompt", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh
```

## 疑難排解

### 看不到系統通知

1. 確認已安裝 terminal-notifier: `which terminal-notifier`
2. 檢查通知權限：系統設定 → 通知 → terminal-notifier
3. 確認沒有開啟勿擾模式

### 聽不到語音

1. 確認系統音量沒有靜音
2. 測試語音是否可用：`say -v "Yue (Premium)" "測試"`
3. 如果語音不可用，嘗試其他語音如 `Tingting`

### 點擊通知沒有跳轉

1. 確認 `$TERM_PROGRAM` 環境變數已設定：`echo $TERM_PROGRAM`
2. 腳本會自動偵測大部分終端，如果你的終端不支援，可以手動修改腳本

## License

MIT License
