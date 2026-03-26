#!/bin/bash

# ============================================
# meeting-soundcheck — Installer
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.meeting-soundcheck"
PLIST_PATH="$HOME/Library/LaunchAgents/com.meeting-soundcheck.plist"

# Ensure Homebrew paths are available (Apple Silicon + Intel)
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

echo "============================================"
echo "  meeting-soundcheck — Install"
echo "============================================"
echo ""

# --- Step 1: Check/install icalBuddy ---
echo "[1/5] Checking icalBuddy..."
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

# --- Step 2: Copy files to ~/.meeting-soundcheck ---
echo "[2/5] Installing files to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR/sounds"
cp "$SCRIPT_DIR/meeting_soundcheck.sh" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/config.sh" "$INSTALL_DIR/"
# Copy sound files if any exist
if ls "$SCRIPT_DIR/sounds/"* &>/dev/null; then
    cp "$SCRIPT_DIR/sounds/"* "$INSTALL_DIR/sounds/"
fi
echo "  Done."

# --- Step 3: Set permissions ---
echo "[3/5] Setting permissions..."
chmod +x "$INSTALL_DIR/meeting_soundcheck.sh"
chmod +x "$INSTALL_DIR/config.sh"
echo "  Done."

# --- Step 4: Verify calendar access ---
echo "[4/5] Checking calendar access..."
EVENT_CHECK=$(icalBuddy -n -li 1 eventsToday+1 2>/dev/null || true)
if [ -z "$EVENT_CHECK" ]; then
    echo "  Warning: No calendar events found."
    echo "  Make sure your calendar is synced in System Settings > Internet Accounts."
else
    echo "  Calendar accessible."
fi

# --- Step 5: Auto-start on login (optional) ---
echo "[5/5] Auto-start on login?"
echo "  This will run meeting-soundcheck in the background when you log in."
read -p "  Enable auto-start? (y/n): " AUTOSTART

if [ "$AUTOSTART" = "y" ] || [ "$AUTOSTART" = "Y" ]; then
    cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.meeting-soundcheck</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$INSTALL_DIR/meeting_soundcheck.sh</string>
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
    echo "  Auto-start enabled."
    echo "  Runs automatically on every login."
    echo "  Logs at /tmp/meeting-soundcheck.log"
else
    echo "  Skipped. Run manually with: ~/.meeting-soundcheck/meeting_soundcheck.sh"
fi

echo ""
echo "============================================"
echo "  Installation complete!"
echo ""
echo "  Installed to: $INSTALL_DIR"
echo "  Config: $INSTALL_DIR/config.sh"
echo "  Sounds: $INSTALL_DIR/sounds/"
echo ""
echo "  To change settings, edit: $INSTALL_DIR/config.sh"
echo "  To add sounds, drop files into: $INSTALL_DIR/sounds/"
echo "============================================"
