#!/usr/bin/env bash
# One-time (or once-per-emulator-reboot) App Check debug setup for Bookish DEV.
# Fixes: "App attestation failed" / 403 when using AndroidProvider.debug.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TOKEN_FILE="$ROOT/.appcheck_debug_token"

echo "=== Bookish App Check debug setup ==="
echo "Firebase project: bookish-debug-58f4c"
echo "Android package:  com.newaura.bookish.dev"
echo

if [[ ! -f "$TOKEN_FILE" ]]; then
  NEW_TOKEN="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  printf '%s\n' "$NEW_TOKEN" >"$TOKEN_FILE"
  echo "Created $TOKEN_FILE"
  echo
  echo "Do this ONCE in Firebase Console:"
  echo "  1. Open https://console.firebase.google.com/project/bookish-debug-58f4c/appcheck"
  echo "  2. Select Android app com.newaura.bookish.dev"
  echo "  3. ⋮ Manage debug tokens → Add debug token"
  echo "  4. Paste: $NEW_TOKEN"
  echo
  echo "Also ensure Phone Auth App Check is Monitor (not Enforce) until the token works,"
  echo "or Enforce only after the debug token is registered."
  echo
else
  NEW_TOKEN="$(tr -d '[:space:]' <"$TOKEN_FILE")"
  echo "Using existing token from $TOKEN_FILE"
  echo "Token: $NEW_TOKEN"
  echo
fi

if ! command -v adb >/dev/null 2>&1; then
  echo "adb not found. Install Android platform-tools, then re-run this script."
  exit 1
fi

DEVICE_COUNT="$(adb devices | awk 'NR>1 && $2=="device" {count++} END {print count+0}')"
if [[ "$DEVICE_COUNT" -lt 1 ]]; then
  echo "No device/emulator connected. Start one, then re-run:"
  echo "  ./scripts/setup_app_check_debug.sh"
  exit 1
fi

adb shell setprop debug.firebase.appcheck.app_check_debug_token "$NEW_TOKEN"
echo "Set debug.firebase.appcheck.app_check_debug_token on the device."
echo
echo "Then run (debug + dev flavor):"
echo "  fvm flutter run --flavor dev -t lib/main.dart"
echo
echo "If the property was cleared (emulator reboot), just re-run this script."
echo "You do NOT need to re-add the token in Firebase Console."
