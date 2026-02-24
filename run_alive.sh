#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-both}"

if command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN="flutter"
elif [ -x "$HOME/development/flutter/bin/flutter" ]; then
  FLUTTER_BIN="$HOME/development/flutter/bin/flutter"
else
  echo "未找到 flutter，请先安装或配置 PATH。"
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

has_connected_device() {
  local platform="$1"
  while IFS= read -r line; do
    local device_platform
    device_platform="$(printf "%s" "$line" | awk -F'•' 'NF>=3 {gsub(/^[ \t]+|[ \t]+$/, "", $3); print $3}')"
    if [ "$platform" = "ios" ] && [[ "$device_platform" == ios* ]]; then
      return 0
    fi
    if [ "$platform" = "android" ] && [[ "$device_platform" == android* ]]; then
      return 0
    fi
  done < <("$FLUTTER_BIN" devices)
  return 1
}

find_emulator_id() {
  local platform="$1"
  local target_platform
  if [ "$platform" = "ios" ]; then
    target_platform="ios"
  else
    target_platform="android"
  fi

  "$FLUTTER_BIN" emulators | awk -F'•' -v target="$target_platform" '
    NF >= 4 {
      id = $1
      platform = $4
      gsub(/^[ \t]+|[ \t]+$/, "", id)
      gsub(/^[ \t]+|[ \t]+$/, "", platform)
      if (platform == target) {
        print id
        exit
      }
    }
  '
}

ensure_device_ready() {
  local platform="$1"
  if has_connected_device "$platform"; then
    return 0
  fi

  local emulator_id
  emulator_id="$(find_emulator_id "$platform")"
  if [ -z "$emulator_id" ]; then
    echo "未找到可用的 ${platform} 模拟器，请先创建模拟器。"
    return 1
  fi

  echo "正在启动 ${platform} 模拟器：$emulator_id"
  "$FLUTTER_BIN" emulators --launch "$emulator_id" >/dev/null 2>&1 || true

  local retries=25
  while [ "$retries" -gt 0 ]; do
    if has_connected_device "$platform"; then
      return 0
    fi
    retries=$((retries - 1))
    sleep 2
  done

  echo "${platform} 设备未就绪，请检查模拟器状态。"
  return 1
}

run_ios() {
  ensure_device_ready "ios"
  echo "启动 iOS..."
  "$FLUTTER_BIN" run -d ios
}

run_android() {
  ensure_device_ready "android"
  echo "启动 Android..."
  "$FLUTTER_BIN" run -d android
}

cd "$ROOT_DIR"
"$FLUTTER_BIN" pub get

case "$MODE" in
  ios)
    run_ios
    ;;
  android)
    run_android
    ;;
  both)
    run_ios &
    IOS_PID=$!
    run_android &
    ANDROID_PID=$!
    trap 'kill $IOS_PID $ANDROID_PID >/dev/null 2>&1 || true' INT TERM EXIT
    wait $IOS_PID $ANDROID_PID
    ;;
  *)
    echo "用法: ./run_alive.sh [ios|android|both]"
    exit 1
    ;;
esac
