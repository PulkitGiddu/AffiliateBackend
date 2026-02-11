#!/usr/bin/env bash
# Run SnatchMart Flutter app
# Usage: ./run_app.sh [device_id]
# For Android emulator to hit host backend: ./run_app.sh --dart-define=BASE_URL=http://10.0.2.2:8081

set -e
cd "$(dirname "$0")"

echo "Getting dependencies..."
flutter pub get

echo "Running app..."
if [ -n "$1" ]; then
  flutter run "$@"
else
  # Default: run with backend URL for Android emulator (use 127.0.0.1:8081 for iOS sim)
  flutter run --dart-define=BASE_URL=http://10.0.2.2:8081
fi
