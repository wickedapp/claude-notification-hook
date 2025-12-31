#!/bin/bash
# Claude Code TTS 通知脚本
# macOS 中文语音通知 + 系統通知

# ============================================
# 自定义配置区域 - 在此修改你的消息
# ============================================

# 稱呼
NICKNAME="老闆"

# 通知開關
ENABLE_TTS=true           # 語音通知
ENABLE_NOTIFICATION=true  # 系統通知 (通知中心)

# 中文语音选择
VOICE="Yue (Premium)"

# 语速 (默认 180, 范围 1-500)
RATE=180

# idle_prompt 靜默時間（秒）
# 如果在此時間內已發送過 Stop 通知，則不發送 idle_prompt 通知
IDLE_SILENCE_PERIOD=120

# ============================================
# 脚本逻辑 - 无需修改
# ============================================

# 狀態檔案目錄
STATE_DIR="/tmp/claude-notification"
mkdir -p "$STATE_DIR"

# 读取 stdin 中的 JSON 数据
INPUT=$(cat)

# 解析 JSON 数据
eval "$(/usr/bin/python3 -c "
import sys, json
data = json.loads('''$INPUT''')
print(f\"HOOK_EVENT='{data.get('hook_event_name', '')}'\" )
print(f\"NOTIFICATION_TYPE='{data.get('notification_type', '')}'\" )
print(f\"CWD='{data.get('cwd', '')}'\" )
" 2>/dev/null)"

# 從工作目錄提取任務名（最後一個資料夾名稱）
TASK_NAME=$(basename "$CWD")
if [ -z "$TASK_NAME" ]; then
    TASK_NAME="任務"
fi

# 狀態檔案路徑（每個任務一個）
STATE_FILE="${STATE_DIR}/${TASK_NAME}.state"

# 檢查是否應該跳過 idle_prompt 通知
SKIP_NOTIFICATION=false

if [ "$HOOK_EVENT" = "Notification" ] && [ "$NOTIFICATION_TYPE" = "idle_prompt" ]; then
    # 檢查是否最近已發送過 Stop 通知
    if [ -f "$STATE_FILE" ]; then
        LAST_STOP_TIME=$(cat "$STATE_FILE" 2>/dev/null)
        CURRENT_TIME=$(date +%s)
        TIME_DIFF=$((CURRENT_TIME - LAST_STOP_TIME))

        if [ "$TIME_DIFF" -lt "$IDLE_SILENCE_PERIOD" ]; then
            # 最近已發送過 Stop 通知，跳過 idle_prompt
            SKIP_NOTIFICATION=true
        fi
    fi
fi

# 如果是 Stop 事件，記錄時間戳
if [ "$HOOK_EVENT" = "Stop" ] || [ "$HOOK_EVENT" = "SubagentStop" ]; then
    date +%s > "$STATE_FILE"
fi

# 如果應該跳過，直接退出
if [ "$SKIP_NOTIFICATION" = true ]; then
    exit 0
fi

# 根据事件类型选择消息
case "$HOOK_EVENT" in
    "Stop"|"SubagentStop")
        TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務完成啦，請看看"
        NOTIF_TITLE="任務完成"
        NOTIF_MESSAGE="${TASK_NAME} 任務完成啦，請看看"
        ;;
    "Notification")
        case "$NOTIFICATION_TYPE" in
            "idle_prompt")
                TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務在等你指示呢"
                NOTIF_TITLE="等待輸入"
                NOTIF_MESSAGE="${TASK_NAME} 任務在等你指示"
                ;;
            "permission_prompt")
                TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務需要你批准一下喔"
                NOTIF_TITLE="需要授權"
                NOTIF_MESSAGE="${TASK_NAME} 任務需要你批准"
                ;;
            *)
                TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務在等你指示呢"
                NOTIF_TITLE="等待輸入"
                NOTIF_MESSAGE="${TASK_NAME} 任務在等你指示"
                ;;
        esac
        ;;
    *)
        TTS_MESSAGE="${NICKNAME}，${TASK_NAME} 任務完成啦，請看看"
        NOTIF_TITLE="任務完成"
        NOTIF_MESSAGE="${TASK_NAME} 任務完成啦，請看看"
        ;;
esac

# 自動偵測當前終端 App (動態獲取 Bundle ID)
ACTIVATE_APP=""
if [ -n "$TERM_PROGRAM" ]; then
    # 嘗試直接用 TERM_PROGRAM 作為 App 名稱獲取 Bundle ID
    ACTIVATE_APP=$(/usr/bin/osascript -e "id of app \"$TERM_PROGRAM\"" 2>/dev/null)

    # 如果失敗，嘗試常見的名稱對應
    if [ -z "$ACTIVATE_APP" ]; then
        case "$TERM_PROGRAM" in
            "vscode")
                ACTIVATE_APP="com.microsoft.VSCode"
                ;;
            "Apple_Terminal")
                ACTIVATE_APP="com.apple.Terminal"
                ;;
            "iTerm.app")
                ACTIVATE_APP="com.googlecode.iterm2"
                ;;
        esac
    fi
fi

# macOS 系統通知 (使用 terminal-notifier，點擊可跳轉)
# 使用 -group 參數確保通知不會重複，點擊後自動清除
if [ "$ENABLE_NOTIFICATION" = true ]; then
    # 生成唯一的 group ID（基於任務名和事件類型）
    GROUP_ID="claude-${TASK_NAME}-${HOOK_EVENT}"

    if [ -n "$ACTIVATE_APP" ]; then
        /opt/homebrew/bin/terminal-notifier \
            -title "Claude Code" \
            -subtitle "$NOTIF_TITLE" \
            -message "$NOTIF_MESSAGE" \
            -sound "Glass" \
            -group "$GROUP_ID" \
            -activate "$ACTIVATE_APP" \
            -ignoreDnD
    else
        /opt/homebrew/bin/terminal-notifier \
            -title "Claude Code" \
            -subtitle "$NOTIF_TITLE" \
            -message "$NOTIF_MESSAGE" \
            -sound "Glass" \
            -group "$GROUP_ID" \
            -ignoreDnD
    fi
fi

# 語音通知
if [ "$ENABLE_TTS" = true ]; then
    /usr/bin/say -v "$VOICE" -r "$RATE" "$TTS_MESSAGE"
fi

exit 0
