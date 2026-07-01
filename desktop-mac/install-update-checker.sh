#!/bin/bash
# ============================================================================
# Installs a background checker (macOS LaunchAgent) that, at login and once a
# day, checks whether Claude Desktop updated and — if so — pops a dialog asking
# if you want to update your RTL apps. "Update now" runs update-rtl.sh for you.
#
#   ./install-update-checker.sh              install / re-install
#   ./install-update-checker.sh --uninstall  remove it
#
# Note: the LaunchAgent points at this repo folder. If you move or delete the
# folder, re-run this installer from the new location.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LABEL="com.claude-rtl.update-check"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [ "${1:-}" = "--uninstall" ]; then
    launchctl unload "$PLIST" 2>/dev/null || true
    rm -f "$PLIST"
    echo "✅ Update checker removed."
    exit 0
fi

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$SCRIPT_DIR/check-update.sh</string>
    <string>--prompt</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>StartCalendarInterval</key>
  <dict><key>Hour</key><integer>10</integer><key>Minute</key><integer>0</integer></dict>
</dict>
</plist>
EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "✅ Update checker installed."
echo "   Runs at login and daily at 10:00. When Claude updates, you'll get a dialog."
echo "   Remove with: $0 --uninstall"
