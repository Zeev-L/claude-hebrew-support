#!/bin/bash
# ============================================================================
# Update ALL patched Claude apps after Claude Desktop itself updated.
#
# Claude Desktop (the original in /Applications) auto-updates. The patched copies
# (Claude-RTL, Claude-RTL-2, ...) do NOT — they must be rebuilt from the updated
# original. This does that in one shot:
#   1. Re-patches Claude-RTL from the current /Applications/Claude.app
#   2. Rebuilds every extra instance (Claude-RTL-2, -3, ...) from it
#
# Your login, chats and projects are preserved (they live in the shared data dir).
#
# Usage:  ./update-rtl.sh
# ============================================================================
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "► Rebuilding Claude-RTL from the updated Claude.app..."
"$SCRIPT_DIR/patch.sh" --install

echo "► Rebuilding extra parallel instances (if any)..."
shopt -s nullglob
found=0
for app in "$HOME/Applications/"Claude-RTL-*.app; do
    base="$(basename "$app" .app)"   # e.g. Claude-RTL-2
    n="${base##*-}"                   # e.g. 2
    if [ -n "$n" ]; then
        echo "  - $base"
        "$SCRIPT_DIR/make-instance.sh" "$n"
        found=1
    fi
done
[ "$found" -eq 0 ] && echo "  (none)"

echo ""
echo "✅ All RTL apps updated to match Claude Desktop."
echo "   macOS may ask once more for Desktop/Keychain access (re-signing resets that) — click Allow."
