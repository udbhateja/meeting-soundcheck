#!/bin/bash

# ============================================
# meeting-soundcheck — Installer
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.meeting-soundcheck.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "============================================"
echo "  meeting-soundcheck — Install"
echo "============================================"
echo ""

# --- Step 1: Check/install icalBuddy ---
echo "[1/4] Checking icalBuddy..."
if ! command -v icalBuddy &>/dev/null; then
    echo "  icalBuddy not found. Installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "  Error: Homebrew is required. Install it from https://brew.sh"
        exit 1
    fi
    brew install ical-buddy
    echo "  icalBuddy installed."
else
    echo "  icalBuddy found."
fi

# --- Step 2: Make scripts executable ---
echo "[2/4] Setting permissions..."
chmod +x "$SCRIPT_DIR/meeting_soundcheck.sh"
chmod +x "$SCRIPT_DIR/config.sh"
echo "  Done."

# --- Step 3: Verify calendar access ---
echo "[3/4] Checking calendar access..."
EVENT_CHECK=$(icalBuddy -n -li 1 eventsToday+1 2>/dev/null || true)
if [ -z "$EVENT_CHECK" ]; then
    echo "  Warning: No calendar events found."
    echo "  Make sure your calendar is synced in System Settings > Internet Accounts."
else
    echo "  Calendar accessible."
fi

# --- Step 4: Auto-start on login (optional) ---
echo "[4/4] Auto-start on login?"
echo "  This will run meeting-soundcheck in the background when you log in."
read -p "  Enable auto-start? (y/n): " AUTOSTART

if [ "$AUTOSTART" = "y" ] || [ "$AUTOSTART" = "Y" ]; then
    cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_DIR/meeting_soundcheck.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/meeting-soundcheck.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/meeting-soundcheck.err</string>
</dict>
</plist>
PLIST
    launchctl load "$PLIST_PATH" 2>/dev/null || true
    echo "  Auto-start enabled. Logs at /tmp/meeting-soundcheck.log"
else
    echo "  Skipped. Run manually with: ./meeting_soundcheck.sh"
fi

echo ""
echo "============================================"
echo "  Installation complete!"
echo ""
echo "  Quick start:"
echo "    1. Drop a sound file into sounds/ folder"
echo "    2. Edit config.sh to customize"
echo "    3. Run: ./meeting_soundcheck.sh"
echo "============================================"
