#!/usr/bin/env bash
set -Eeuo pipefail
CLOCK_DIR="/home/prime/.local/share/modern-gaming-clock"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"
"$CLOCK_DIR/detect-wallpaper-theme.sh" || true
exec qml6 "$CLOCK_DIR/main.qml"
