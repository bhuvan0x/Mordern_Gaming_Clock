#!/bin/sh
set -eu

CLOCK_DIR="/home/prime/.local/share/modern-gaming-clock"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"

exec qml "$CLOCK_DIR/main.qml"
