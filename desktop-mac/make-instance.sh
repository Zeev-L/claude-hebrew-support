#!/bin/bash
# ============================================================================
# Create an ADDITIONAL parallel Claude-RTL instance (Claude-RTL-2, -3, ...).
#
# Why: you may want two (or more) Claude Desktop windows open side by side, each
# on a different conversation, all with the Hebrew/Arabic RTL fix. Each instance
# is a separate app you can launch independently.
#
# What it does:
#   1. Duplicates the already-patched ~/Applications/Claude-RTL.app
#   2. Gives the copy a UNIQUE bundle id (com.anthropic.claudefordesktop.rtlN)
#      so macOS remembers its folder permissions separately (no repeated
#      "would like to access your Desktop" prompts when you switch apps)
#   3. Re-signs ad-hoc (preserving entitlements so Cowork keeps working)
#
# Shared by design: history, projects and LOGIN are SHARED across all instances,
# because Claude derives its data folder + keychain key from the app NAME
# ("Claude"), not the bundle id. So a new instance opens already logged in with
# all your chats. (Just don't edit the SAME conversation in two windows at once.)
#
# Usage:
#   ./make-instance.sh [N] [--name "Display Name"]      # create instance N (default 2)
#   ./make-instance.sh --uninstall N                    # remove instance N
#
# Requires: Claude-RTL.app must already exist (run ./patch.sh --install first),
# plus codesign (Xcode CLI tools).
# ============================================================================
set -euo pipefail

BASE_APP="$HOME/Applications/Claude-RTL.app"
ORIG_APP="/Applications/Claude.app"

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
log(){ echo -e "  ${CYAN}[*]${NC} $1"; }
ok(){ echo -e "  ${GREEN}[+]${NC} $1"; }
die(){ echo -e "  ${RED}[X]${NC} $1"; exit 1; }
step(){ echo -e "\n${BOLD}${CYAN}► $1${NC}"; }

# --- parse args ---
ACTION="create"; N="2"; DISPLAY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --uninstall) ACTION="uninstall"; shift; [ $# -gt 0 ] && { N="$1"; shift; } ;;
    --name) shift; DISPLAY="${1:-}"; shift ;;
    *[0-9]*) N="$1"; shift ;;
    *) die "Unknown argument: $1" ;;
  esac
done
[ -n "$DISPLAY" ] || DISPLAY="Claude-RTL-$N"
DST="$HOME/Applications/Claude-RTL-$N.app"
BID="com.anthropic.claudefordesktop.rtl$N"

if [ "$ACTION" = "uninstall" ]; then
  step "Removing Claude-RTL-$N"
  pkill -f "Claude-RTL-$N.app/Contents/MacOS" 2>/dev/null || true
  [ -d "$DST" ] && { rm -rf "$DST"; ok "Removed $DST"; } || log "Nothing to remove at $DST"
  exit 0
fi

# --- create ---
[ -d "$BASE_APP" ] || die "Base app not found: $BASE_APP — run ./patch.sh --install first."
command -v codesign >/dev/null || die "codesign not found — install Xcode CLI tools: xcode-select --install"

step "Duplicating Claude-RTL → Claude-RTL-$N"
pkill -f "Claude-RTL-$N.app/Contents/MacOS" 2>/dev/null || true
rm -rf "$DST"
cp -R "$BASE_APP" "$DST"
ok "Created $DST"

step "Setting unique identity"
PLIST="$DST/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BID" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $DISPLAY" "$PLIST" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string $DISPLAY" "$PLIST"
ok "id: $BID  |  name: $DISPLAY"

step "Re-signing ad-hoc (preserve entitlements for Cowork)"
ENT="$(mktemp)"
if codesign -d --entitlements :- "$ORIG_APP" > "$ENT" 2>/dev/null && [ -s "$ENT" ]; then
  /usr/libexec/PlistBuddy -c "Delete :com.apple.application-identifier" "$ENT" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Delete :com.apple.developer.team-identifier" "$ENT" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Delete :keychain-access-groups" "$ENT" 2>/dev/null || true
  codesign --force --deep --sign - --entitlements "$ENT" "$DST" >/dev/null 2>&1
else
  codesign --force --deep --sign - "$DST" >/dev/null 2>&1
fi
rm -f "$ENT"
ok "Signed."

step "Registering with LaunchServices & launching"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$DST" >/dev/null 2>&1 || true
open -n "$DST"

echo -e "\n${BOLD}${GREEN}Done — $DISPLAY is open.${NC}"
echo "  • It shares your login + all chats with the other Claude apps."
echo "  • First launch may ask once to access Desktop / a Keychain key — click Allow / Always Allow."
echo "  • Remove later with: ./make-instance.sh --uninstall $N"
