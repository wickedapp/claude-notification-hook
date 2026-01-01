# Claude Code Notification Hook

[English](#english) | [中文](#中文)

---

<a name="english"></a>

Get notified via macOS TTS voice and system notifications when Claude Code completes a task or waits for your input.

## Features

- **Voice Notification (TTS)** - Uses macOS text-to-speech to announce task status
- **System Notification** - Push notifications to macOS Notification Center with custom sounds
- **Click to Focus** - Click notification to jump to the corresponding terminal app
- **Auto Terminal Detection** - Supports VS Code, Terminal, iTerm2, Tabby, Cursor, and more
- **Project Name Display** - Automatically extracts project name from working directory
- **Smart Notification** - Prevents duplicate notifications when you've already responded

## Trigger Events

| Event | Description | Voice Example |
|-------|-------------|---------------|
| `Stop` | When Claude completes a task | Boss, my-project task is done |
| `Notification (idle_prompt)` | When Claude waits for input > 60s | Boss, my-project is waiting |
| `Notification (permission_prompt)` | When Claude needs permission | Boss, my-project needs approval |

## Requirements

- macOS (tested on macOS Tahoe)
- Python 3 (built-in on macOS)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier) (for system notifications)

## Installation

### 1. Install terminal-notifier

```bash
brew install terminal-notifier
```

### 2. Download the Script

```bash
# Clone the repository
git clone https://github.com/wickedapp/claude-notification-hook.git

# Or download directly
curl -o ~/claude-tts-notify.sh https://raw.githubusercontent.com/wickedapp/claude-notification-hook/main/claude-tts-notify.sh
chmod +x ~/claude-tts-notify.sh
```

### 3. Configure Claude Code Hooks

Edit `~/.claude/settings.json`:

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

> **Note**: Replace `/path/to/claude-tts-notify.sh` with the actual path.

### 4. Enable Notification Permissions

1. Open **System Settings**
2. Click **Notifications**
3. Find **terminal-notifier**
4. Enable **"Allow Notifications"**
5. Set style to **"Alerts"** (recommended)

### 5. Restart Claude Code

Restart Claude Code to activate the hooks.

---

## Configuration

Edit the configuration section at the top of `claude-tts-notify.sh`:

```bash
# Nickname/Title
NICKNAME="Boss"

# Notification toggles
ENABLE_TTS=true           # Voice notification
ENABLE_NOTIFICATION=true  # System notification

# Voice selection
VOICE="Samantha"

# Speech rate (default 180, range 1-500)
RATE=180

# Smart notification: silence period in seconds
# If a Stop notification was sent within this period, skip idle_prompt
IDLE_SILENCE_PERIOD=120
```

---

## Smart Notification Logic

The script prevents duplicate notifications using intelligent state tracking:

```
Stop notification sent → Record timestamp
         ↓
idle_prompt received within 120 seconds?
         ↓
       Yes → Skip notification (you already know)
       No  → Send "waiting for input" notification
```

**Why this matters**: When Claude completes a task and you click the notification, you don't need another "waiting for input" reminder 60 seconds later - you're already there!

**Configurable**: Adjust `IDLE_SILENCE_PERIOD` (default: 120 seconds) to change the silence window.

---

## Voice Selection Guide

### Step 1: List Available Voices

```bash
# List all voices
say -v '?'

# English voices only
say -v '?' | grep -i "en_"

# Chinese voices only
say -v '?' | grep -i "zh\|chinese"
```

### Step 2: Test Voices

```bash
# English
say -v "Samantha" "Boss, the task is complete"
say -v "Alex" "Boss, the task is complete"

# Chinese
say -v "Yue (Premium)" "老闆，任務完成啦"
say -v "Tingting" "老闆，任務完成啦"
```

### Step 3: Set Your Voice

Edit `claude-tts-notify.sh`:

```bash
VOICE="Samantha"       # English female
VOICE="Alex"           # English male
VOICE="Yue (Premium)"  # Chinese female (Premium)
```

### Step 4: Adjust Speech Rate

```bash
RATE=180    # Default
RATE=150    # Slower
RATE=200    # Faster
```

### Common Voice Options

#### English Voices

| Voice | Gender | Description |
|-------|--------|-------------|
| `Samantha` | Female | US English - Recommended |
| `Alex` | Male | US English |
| `Victoria` | Female | US English |
| `Daniel` | Male | UK English |

#### Chinese Voices

| Voice | Language | Gender | Description |
|-------|----------|--------|-------------|
| `Tingting` | zh_CN | Female | Mandarin Basic |
| `Yue (Premium)` | zh_CN | Female | Mandarin Premium - Recommended |
| `Han (Premium)` | zh_CN | Male | Mandarin Premium |
| `Meijia` | zh_TW | Female | Taiwan Mandarin |
| `Sinji` | zh_HK | Female | Cantonese |

---

## Customizing Messages

Edit the `case` block in `claude-tts-notify.sh`:

```bash
case "$HOOK_EVENT" in
    "Stop"|"SubagentStop")
        TTS_MESSAGE="${NICKNAME}, ${TASK_NAME} task is complete"
        NOTIF_TITLE="Task Complete"
        NOTIF_MESSAGE="${TASK_NAME} task is complete"
        ;;
    # ... more cases
esac
```

### Available Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `${NICKNAME}` | Your configured nickname | Boss |
| `${TASK_NAME}` | Project name from cwd | my-project |

---

## How It Works

```
┌─────────────────┐
│  Claude Code    │
│  Task Complete  │
└────────┬────────┘
         │ Trigger Hook
         ▼
┌─────────────────┐
│  Hook sends JSON│
│  (via stdin)    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  claude-tts-notify.sh               │
│                                     │
│  1. Parse JSON                      │
│  2. Check smart notification state  │
│  3. Extract project name from cwd   │
│  4. Detect terminal app             │
│  5. Send system notification        │
│  6. Play TTS voice                  │
└─────────────────────────────────────┘
         │
         ▼
┌─────────────────┐     ┌─────────────────┐
│  Notification   │     │  Voice (TTS)    │
│  Center         │     │                 │
└─────────────────┘     └─────────────────┘
```

### Auto Terminal Detection

| Terminal | TERM_PROGRAM | Auto-detected |
|----------|--------------|---------------|
| VS Code | `vscode` | ✅ |
| Terminal.app | `Apple_Terminal` | ✅ |
| iTerm2 | `iTerm.app` | ✅ |
| Tabby | `Tabby` | ✅ |
| Cursor | `cursor` | ✅ |
| Others | Dynamic | ✅ |

---

## Testing

```bash
# Test task complete
echo '{"hook_event_name": "Stop", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh

# Test waiting for input
echo '{"hook_event_name": "Notification", "notification_type": "idle_prompt", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh

# Test permission required
echo '{"hook_event_name": "Notification", "notification_type": "permission_prompt", "cwd": "/test/my-project"}' | ./claude-tts-notify.sh
```

---

## Troubleshooting

### Can't See Notifications
1. Check terminal-notifier: `which terminal-notifier`
2. Check permissions: System Settings → Notifications → terminal-notifier
3. Disable Do Not Disturb

### Can't Hear Voice
1. Check system volume
2. Test voice: `say -v "Samantha" "Test"`
3. Try another voice

### Click Doesn't Focus App
1. Check `$TERM_PROGRAM`: `echo $TERM_PROGRAM`
2. Script auto-detects most terminals

---

## License

MIT License

---

<a name="中文"></a>
# Claude Code 通知 Hook（中文）

當 Claude Code 完成任務或等待輸入時，透過 macOS 語音和系統通知提醒你。

## 功能特色

- **語音通知 (TTS)** - 使用 macOS 中文語音播報任務狀態
- **系統通知** - 推送到 macOS 通知中心
- **點擊跳轉** - 點擊通知自動跳轉到對應的終端 App
- **自動偵測終端** - 支援 VS Code、Terminal、iTerm2、Tabby、Cursor 等
- **智能通知** - 避免重複通知打擾

## 智能通知邏輯

腳本會追蹤通知狀態，避免重複打擾：

```
發送 Stop 通知 → 記錄時間戳
         ↓
120 秒內收到 idle_prompt？
         ↓
       是 → 跳過通知（你已經知道了）
       否 → 發送「等待輸入」通知
```

**可調整參數**：修改 `IDLE_SILENCE_PERIOD`（預設 120 秒）

## 安裝步驟

### 1. 安裝 terminal-notifier

```bash
brew install terminal-notifier
```

### 2. 下載腳本

```bash
git clone https://github.com/wickedapp/claude-notification-hook.git
```

### 3. 設定 Claude Code Hooks

編輯 `~/.claude/settings.json`，加入 hooks 配置（詳見英文版）

### 4. 開啟通知權限

系統設定 → 通知 → terminal-notifier → 允許通知

### 5. 重啟 Claude Code

## 語音選擇

### 可用的中文語音

| 語音名稱 | 說明 |
|----------|------|
| `Tingting` | 普通話（大陸）基本版 |
| `Yue (Premium)` | 普通話（大陸）高級版 - 推薦 |
| `Han (Premium)` | 普通話（大陸）男聲高級版 |
| `Meijia` | 普通話（台灣）|
| `Sinji` | 粵語（香港）|

### 試聽語音

```bash
say -v "Yue (Premium)" "老闆，任務完成啦，請看看"
say -v "Tingting" "老闆，任務完成啦，請看看"
say -v "Han (Premium)" "老闆，任務完成啦，請看看"
```

### 設定語音

編輯 `claude-tts-notify.sh`：

```bash
VOICE="Yue (Premium)"
RATE=180
```

## 自訂訊息

編輯 `claude-tts-notify.sh` 中的訊息：

```bash
# 稱呼
NICKNAME="老闆"

# 任務完成訊息
TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務完成啦，請看看"
```

## License

MIT License
