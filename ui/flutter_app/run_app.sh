#!/usr/bin/env bash
# Run SnatchMart Flutter app
# Usage:
#   ./run_app.sh                    # Android emulator (10.0.2.2:8081)
#   ./run_app.sh device             # Physical device: use Mac LAN IP (same WiFi)
#   ./run_app.sh --dart-define=BASE_URL=http://192.168.1.5:8081

set -e
cd "$(dirname "$0")"

echo "Getting dependencies..."
flutter pub get

BASE_URL_ARG=""
if [ "$1" = "device" ] || [ "$1" = "phone" ]; then
  # Physical device: use this machine's LAN IP so phone can reach backend
  LAN_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || true)
  if [ -z "$LAN_IP" ]; then
    LAN_IP=$(ifconfig 2>/dev/null | grep " inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
  fi
  if [ -n "$LAN_IP" ]; then
    BASE_URL_ARG="--dart-define=BASE_URL=http://${LAN_IP}:8081"
    echo "Using backend at http://${LAN_IP}:8081 (physical device)"
  else
    echo "Could not detect LAN IP. Run: flutter run --dart-define=BASE_URL=http://YOUR_IP:8081"
    exit 1
  fi
  shift
elif [ -z "$1" ] || [ "$1" = --* ]; then
  # Default: Android emulator
  BASE_URL_ARG="--dart-define=BASE_URL=http://10.0.2.2:8081"
fi

echo "Running app..."
if [ -n "$1" ]; then
  flutter run $BASE_URL_ARG "$@"
else
  flutter run $BASE_URL_ARG
fi
