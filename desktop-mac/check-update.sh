#!/bin/bash
# ============================================================================
# Checks whether Claude Desktop (the original) is newer than the patched
# Claude-RTL, and if so, tells you — optionally with a "Update now?" dialog.
#
#   ./check-update.sh            → silent unless outdated; then a macOS notification
#   ./check-update.sh --prompt   → shows a dialog; "Update now" runs update-rtl.sh
#                                  in Terminal (so you see progress + approve prompts)
#
# Meant to be run by the LaunchAgent (see install-update-checker.sh), but you can
# run it by hand any time.
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ORIG="/Applications/Claude.app"
RTL="$HOME/Applications/Claude-RTL.app"

ver(){ /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$1/Contents/Info.plist" 2>/dev/null || echo "0"; }

[ -d "$ORIG" ] && [ -d "$RTL" ] || exit 0
O="$(ver "$ORIG")"; R="$(ver "$RTL")"
[ "$O" = "$R" ] && exit 0   # already up to date

MSG="Claude Desktop updated to $O — your RTL apps are still on $R. Update them now?"

if [ "${1:-}" = "--prompt" ]; then
    CHOICE="$(osascript -e "button returned of (display dialog \"$MSG\" buttons {\"Later\", \"Update now\"} default button \"Update now\" with title \"Claude RTL\" with icon note)" 2>/dev/null || echo "Later")"
    if [ "$CHOICE" = "Update now" ]; then
        osascript -e "tell application \"Terminal\" to do script \"'$SCRIPT_DIR/update-rtl.sh'\"" \
                  -e 'tell application "Terminal" to activate' >/dev/null 2>&1
    fi
else
    osascript -e "display notification \"$MSG\" with title \"Claude RTL\"" >/dev/null 2>&1 || true
fi
