#!/bin/sh
set -eu

CLOCK_DIR="/home/prime/.local/share/modern-gaming-clock"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"
export QT_QUICK_BACKEND="${QT_QUICK_BACKEND:-software}"

qml "$CLOCK_DIR/main.qml" &
clock_pid=$!

# Make the borderless QML window behave like a desktop widget under XFWM.
sleep 2
xprop -name "Modern Gaming Clock" \
  -f _NET_WM_WINDOW_TYPE 32a \
  -set _NET_WM_WINDOW_TYPE _NET_WM_WINDOW_TYPE_DESKTOP 2>/dev/null || true

wait "$clock_pid"
