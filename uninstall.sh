#!/bin/bash

# ============================================
# meeting-soundcheck — Uninstaller
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.meeting-soundcheck.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "============================================"
echo "  meeting-soundcheck — Uninstall"
echo "============================================"
echo ""

# --- Stop the background service ---
if [ -f "$PLIST_PATH" ]; then
    echo "[1/3] Stopping background service..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    rm -f "$PLIST_PATH"
    echo "  Service stopped and removed."
else
    echo "[1/3] No background service found. Skipping."
fi

# --- Kill any running instance ---
echo "[2/3] Stopping running instances..."
pkill -f "meeting_soundcheck.sh" 2>/dev/null || true
echo "  Done."

# --- Clean up logs ---
echo "[3/3] Cleaning up logs..."
rm -f /tmp/meeting-soundcheck.log
rm -f /tmp/meeting-soundcheck.err
echo "  Done."

echo ""
echo "============================================"
echo "  Uninstall complete!"
echo ""
echo "  Note: Your config.sh and sounds/ are still"
echo "  intact. Delete the folder manually if you"
echo "  want to remove everything:"
echo "  rm -rf $SCRIPT_DIR"
echo "============================================"
