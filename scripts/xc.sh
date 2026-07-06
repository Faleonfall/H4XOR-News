#!/usr/bin/env bash
#
# Deterministic command-line build for H4XOR News.
#
# Removes the three sources of drift between CLI and the open Xcode session:
#   1. Simulator builds need no real signing -> signing disabled entirely.
#   2. One pinned simulator (by name) -> same destination every run.
#   3. Isolated DerivedData (./.build-cli) -> never fights the Xcode session.
#
# Usage:
#   scripts/xc.sh build   # build the app for the pinned simulator
#   scripts/xc.sh boot    # boot the pinned simulator
#   scripts/xc.sh clean   # remove the isolated DerivedData
#   scripts/xc.sh which   # print the resolved simulator + paths
#
set -euo pipefail

PROJECT="H4XOR News.xcodeproj"
SCHEME="H4XOR News"

# Pinned simulator. Repin via H4XOR_SIM; resolution is by name so it stays
# stable across machines even when the runtime gets a patch update.
DEVICE_NAME="${H4XOR_SIM:-iPhone 17}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED="$ROOT/.build-cli/DerivedData"
LOG_DIR="$ROOT/.build-cli/logs"

# Destination is appended per-command using the resolved UDID (name matching is
# ambiguous when the runtime exposes arm64 and x86_64 entries for one device).
COMMON_ARGS=(
  -project "$PROJECT"
  -derivedDataPath "$DERIVED"
  CODE_SIGNING_ALLOWED=NO
  CODE_SIGNING_REQUIRED=NO
  CODE_SIGN_IDENTITY=""
  CODE_SIGN_STYLE=Manual
)

resolve_udid() {
  xcrun simctl list devices available \
    | grep -F "$DEVICE_NAME (" \
    | head -1 \
    | grep -oE '[0-9A-F-]{36}'
}

ensure_booted() {
  local udid; udid="$(resolve_udid)"
  if [ -z "$udid" ]; then
    echo "error: simulator '$DEVICE_NAME' not found. Set H4XOR_SIM or create it." >&2
    exit 1
  fi
  if ! xcrun simctl list devices | grep "$udid" | grep -q "(Booted)"; then
    xcrun simctl boot "$udid" 2>/dev/null || true
  fi
  echo "$udid"
}

run_xcodebuild() {
  local label="$1"; shift
  mkdir -p "$LOG_DIR"
  local log="$LOG_DIR/$label.log"

  local start=$SECONDS
  set +e
  xcodebuild "$@" > "$log" 2>&1
  local rc=$?
  set -e
  local elapsed=$((SECONDS - start))

  grep -iE "(error:|BUILD FAILED)" "$log" | sed 's/^/  /' || true

  echo "------------------------------------------------------------"
  if [ "$rc" -eq 0 ]; then
    printf "RESULT  ok\n"
  else
    printf "RESULT  FAIL  (exit %s)\n" "$rc"
  fi
  printf "TIME    %dm%02ds wall\n" $((elapsed / 60)) $((elapsed % 60))
  echo "log     $log"
  return $rc
}

cmd="${1:-build}"
case "$cmd" in
  build)
    udid="$(ensure_booted)"
    echo ">> build $SCHEME on $DEVICE_NAME ($udid)"
    run_xcodebuild build "${COMMON_ARGS[@]}" -destination "platform=iOS Simulator,id=$udid" -scheme "$SCHEME" build
    ;;
  boot)
    udid="$(ensure_booted)"
    echo "booted: $DEVICE_NAME ($udid)"
    ;;
  clean)
    rm -rf "$ROOT/.build-cli"
    echo "removed .build-cli"
    ;;
  which)
    echo "device:  $DEVICE_NAME ($(resolve_udid))"
    echo "derived: $DERIVED"
    echo "project: $ROOT/$PROJECT"
    ;;
  *)
    echo "usage: scripts/xc.sh {build|boot|clean|which}" >&2
    exit 2
    ;;
esac
