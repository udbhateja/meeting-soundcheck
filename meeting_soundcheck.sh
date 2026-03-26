#!/bin/bash

# ============================================
# meeting-soundcheck
# Play a custom entrance sound before your meetings
# https://github.com/udbhateja/meeting-soundcheck
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Ensure PATH includes Homebrew (needed for launchd) ---
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# --- Load config ---
CONFIG_FILE="$SCRIPT_DIR/config.sh"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.sh not found at $SCRIPT_DIR"
    echo "Run install.sh first or copy config.sh to the script directory."
    exit 1
fi
source "$CONFIG_FILE"

# --- Resolve sound file ---
get_sound_file() {
    if [ -n "$SOUND_FILE" ] && [ -f "$SOUND_FILE" ]; then
        echo "$SOUND_FILE"
        return
    fi

    # Auto-detect from sounds/ directory
    local custom_sound
    custom_sound=$(find "$SCRIPT_DIR/sounds" -type f \( -name "*.mp3" -o -name "*.aiff" -o -name "*.wav" -o -name "*.m4a" \) 2>/dev/null | head -1)

    if [ -n "$custom_sound" ]; then
        echo "$custom_sound"
        return
    fi

    # Fallback to macOS system sound
    echo "/System/Library/Sounds/Hero.aiff"
}

# --- Get next event details ---
get_next_event() {
    icalBuddy -n -nc -nrd -ea -li 1 \
        -iep "title,datetime,notes" \
        -po "datetime,title,notes" \
        -df "%Y-%m-%d" -tf "%H:%M:%S" \
        -b "" \
        eventsToday+1 2>/dev/null
}

# --- Extract start time as epoch ---
get_event_start_epoch() {
    local event_info="$1"
    # icalBuddy format: "2026-03-26 at 19:30:00 - 20:30:00"
    local raw_line
    raw_line=$(echo "$event_info" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2} at [0-9]{2}:[0-9]{2}:[0-9]{2}' | head -1)
    local date_time
    date_time=$(echo "$raw_line" | sed 's/ at / /')

    if [ -z "$date_time" ]; then
        echo ""
        return
    fi

    date -j -f "%Y-%m-%d %H:%M:%S" "$date_time" "+%s" 2>/dev/null
}

# --- Extract title ---
get_event_title() {
    local event_info="$1"
    echo "$event_info" | grep -v '[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}' | grep -v "notes:" | grep -v "location:" | grep -v "^$" | grep -v "teams.microsoft.com" | head -1 | xargs
}

# --- Check if event is a Teams meeting ---
is_teams_meeting() {
    local event_info="$1"
    echo "$event_info" | grep -qi "teams.microsoft.com"
}

# --- Play the sound ---
play_sound() {
    local sound
    sound=$(get_sound_file)
    echo "   Playing: $(basename "$sound")"
    afplay "$sound" &
    SOUND_PID=$!
}

# --- Stop sound if still playing ---
stop_sound() {
    if [ -n "$SOUND_PID" ] && kill -0 "$SOUND_PID" 2>/dev/null; then
        kill "$SOUND_PID" 2>/dev/null
    fi
}

# --- Cleanup on exit ---
cleanup() {
    stop_sound
    echo ""
    echo "meeting-soundcheck stopped."
    exit 0
}
trap cleanup SIGINT SIGTERM

# --- Main ---
# Only clear screen if running in a terminal (not launchd)
if [ -t 1 ]; then clear; fi
echo "============================================"
echo "  meeting-soundcheck"
echo "============================================"
echo "  Lead time  : ${LEAD_TIME_SECONDS}s before meeting"
echo "  Check every: ${CHECK_INTERVAL}s"
echo "  Sound      : $(basename "$(get_sound_file)")"
echo "  Teams only : ${TEAMS_ONLY}"
echo "============================================"
echo "  Press Ctrl+C to stop"
echo ""

LAST_PLAYED_EVENT=""
SOUND_PID=""

while true; do
    NOW=$(date "+%s")
    EVENT_INFO=$(get_next_event)

    if [ -n "$EVENT_INFO" ]; then
        EVENT_EPOCH=$(get_event_start_epoch "$EVENT_INFO")
        EVENT_TITLE=$(get_event_title "$EVENT_INFO")

        if [ -n "$EVENT_EPOCH" ] && [ -n "$EVENT_TITLE" ]; then
            DIFF=$((EVENT_EPOCH - NOW))

            # Skip non-Teams meetings if TEAMS_ONLY is enabled
            if [ "$TEAMS_ONLY" = true ] && ! is_teams_meeting "$EVENT_INFO"; then
                echo -ne "\r  Skipping (not Teams): \"$EVENT_TITLE\"                    "
                sleep "$CHECK_INTERVAL"
                continue
            fi

            if [ "$DIFF" -gt 0 ] && [ "$DIFF" -le "$LEAD_TIME_SECONDS" ]; then
                if [ "$LAST_PLAYED_EVENT" != "$EVENT_TITLE-$EVENT_EPOCH" ]; then
                    echo ""
                    echo "  Meeting in ${DIFF}s: $EVENT_TITLE"
                    play_sound
                    LAST_PLAYED_EVENT="$EVENT_TITLE-$EVENT_EPOCH"
                fi
            elif [ "$DIFF" -gt "$LEAD_TIME_SECONDS" ]; then
                MINS=$((DIFF / 60))
                SECS=$((DIFF % 60))
                echo -ne "\r  Next: \"$EVENT_TITLE\" in ${MINS}m ${SECS}s                    "
            else
                echo -ne "\r  In progress: \"$EVENT_TITLE\"                    "
            fi
        fi
    else
        echo -ne "\r  No upcoming meetings found                    "
    fi

    sleep "$CHECK_INTERVAL"
done
