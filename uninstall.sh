#!/bin/bash

# ============================================
# meeting-soundcheck — Uninstaller
# ============================================

INSTALL_DIR="$HOME/.meeting-soundcheck"
PLIST_PATH="$HOME/Library/LaunchAgents/com.meeting-soundcheck.plist"
APP_PATH="$HOME/Applications/MeetingSoundcheck.app"

echo "============================================"
echo "  meeting-soundcheck — Uninstall"
echo "============================================"
echo ""

# --- Stop any running instance ---
echo "[1/5] Stopping running instances..."
pkill -f "meeting_soundcheck.sh" 2>/dev/null || true
echo "  Done."

# --- Remove launchd service ---
echo "[2/5] Removing auto-start service..."
if [ -f "$PLIST_PATH" ]; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    rm -f "$PLIST_PATH"
    echo "  Service removed."
else
    echo "  No service found. Skipping."
fi

# --- Remove old .app if exists from previous install ---
echo "[3/5] Cleaning up old app (if any)..."
if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_PATH"
    echo "  Removed $APP_PATH"
else
    echo "  No old app found. Skipping."
fi

# --- Remove installed files ---
echo "[4/5] Removing installed files..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "  Removed $INSTALL_DIR"
else
    echo "  No installed files found. Skipping."
fi

# --- Clean up logs ---
echo "[5/5] Cleaning up..."
rm -f /tmp/meeting-soundcheck.log
rm -f /tmp/meeting-soundcheck.err

# --- Optionally remove icalBuddy ---
read -p "  Remove icalBuddy? (y/n): " REMOVE_ICAL
if [ "$REMOVE_ICAL" = "y" ] || [ "$REMOVE_ICAL" = "Y" ]; then
    if command -v brew &>/dev/null; then
        brew uninstall ical-buddy 2>/dev/null || true
        echo "  icalBuddy removed."
    else
        echo "  Homebrew not found. Remove icalBuddy manually."
    fi
else
    echo "  Skipped."
fi

echo ""
echo "============================================"
echo "  Uninstall complete!"
echo ""
echo "  Note: The repo folder is untouched."
echo "  Delete it manually if you want:"
echo "  rm -rf $(cd "$(dirname "$0")" && pwd)"
echo "============================================"
