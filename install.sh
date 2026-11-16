#!/usr/bin/env bash
set -Eeuo pipefail

ACTION="${1:-install}"
if [[ "$ACTION" != install && "$ACTION" != --remove ]]; then
  echo "Usage: bash install.sh [--remove]" >&2
  exit 2
fi
command -v proot-distro >/dev/null 2>&1 || {
  echo "Run this from Termux with proot-distro installed." >&2
  exit 1
}

if [[ "$ACTION" == --remove ]]; then
  proot-distro login --isolated --user prime debian -- /bin/bash -lc '
    pkill -u "$(id -u)" -f "/modern-gaming-clock/main.qml" 2>/dev/null || true
    pkill -u "$(id -u)" -f "conky.*modern-gaming-clock.conf" 2>/dev/null || true
    pkill -u "$(id -u)" -f "conky.*primebook-modernclock.conf" 2>/dev/null || true
    rm -f "$HOME/.config/autostart/primebook-modernclock.desktop"
    rm -f "$HOME/.config/autostart/modern-gaming-clock.desktop"
    rm -f "$HOME/.config/conky/modern-gaming-clock.conf"
    rm -f "$HOME/.config/conky/primebook-modernclock.conf"
    rm -rf "$HOME/.local/share/modern-gaming-clock"
    echo "Modern Gaming Clock and the previous Conky approximation have been removed."
  '
  exit 0
fi

echo "== Installing Qt 6 QML runtime for Debian XFCE =="
proot-distro login --isolated debian -- /bin/bash -lc '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y qml-qt6 qml6-module-qtquick qml6-module-qtquick-window git
  command -v qml6
'

echo "== Fetching the original Modern Clock font assets =="
proot-distro login --isolated debian -- /bin/bash -lc '
  set -Eeuo pipefail
  work="$(mktemp -d)"
  trap "rm -rf \"$work\"" EXIT
  git clone --depth 1 --quiet https://github.com/Prayag2/kde_modernclock.git "$work/upstream"
  test -s "$work/upstream/package/contents/fonts/Anurati.otf"
  test -s "$work/upstream/package/contents/fonts/Poppins.ttf"
  install -d -m 0755 /home/prime/.local/share/modern-gaming-clock/fonts
  install -m 0644 "$work/upstream/package/contents/fonts/Anurati.otf" /home/prime/.local/share/modern-gaming-clock/fonts/Anurati.otf
  install -m 0644 "$work/upstream/package/contents/fonts/Poppins.ttf" /home/prime/.local/share/modern-gaming-clock/fonts/Poppins.ttf
  chown -R prime:prime /home/prime/.local/share/modern-gaming-clock
'

echo "== Installing the faithful Qt Quick port =="
proot-distro login --isolated --user prime debian -- /bin/bash -s <<'DEBIAN'
set -Eeuo pipefail
APP_DIR="$HOME/.local/share/modern-gaming-clock"
AUTOSTART="$HOME/.config/autostart"
mkdir -p "$APP_DIR" "$AUTOSTART"

# Remove only files/processes created by the earlier generic Conky version.
pkill -u "$(id -u)" -f "conky.*modern-gaming-clock.conf" 2>/dev/null || true
pkill -u "$(id -u)" -f "conky.*primebook-modernclock.conf" 2>/dev/null || true
rm -f "$HOME/.config/autostart/primebook-modernclock.desktop"
rm -f "$HOME/.config/conky/modern-gaming-clock.conf"
rm -f "$HOME/.config/conky/primebook-modernclock.conf"
pkill -u "$(id -u)" -f "$APP_DIR/main.qml" 2>/dev/null || true

cat > "$APP_DIR/main.qml" <<'QML'
import QtQuick 2.15
import QtQuick.Window 2.15
import "config.js" as Config

/*
 * XFCE host for Prayag2's KDE Modern Clock presentation.
 * The three text rows, fonts, default sizes, spacing, letter spacing,
 * date/time formats and style-character output mirror the upstream applet.
 */
Window {
    id: root
    title: "Modern Gaming Clock"
    visible: true
    color: "transparent"
    flags: Qt.Window | Qt.FramelessWindowHint | Qt.Tool | Qt.WindowStaysOnBottomHint

    property date currentDate: new Date()

    width: clockColumn.implicitWidth + 2
    height: clockColumn.implicitHeight + 2
    x: Screen.width - width - Config.window_margin_right
    y: Config.window_margin_top

    FontLoader {
        id: fontAnurati
        source: Qt.resolvedUrl("fonts/Anurati.otf")
    }
    FontLoader {
        id: fontPoppins
        source: Qt.resolvedUrl("fonts/Poppins.ttf")
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.currentDate = new Date()
    }

    Column {
        id: clockColumn
        anchors.centerIn: parent
        spacing: 5

        Text {
            id: displayDay
            visible: Config.show_day
            text: Qt.formatDate(root.currentDate, "dddd").toUpperCase()
            font.family: fontAnurati.name
            font.pixelSize: Config.day_font_size
            font.letterSpacing: Config.day_letter_spacing
            color: Config.day_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: displayDate
            visible: Config.show_date
            text: Qt.formatDate(root.currentDate, Config.date_format).toUpperCase()
            font.family: fontPoppins.name
            font.pixelSize: Config.date_font_size
            font.letterSpacing: Config.date_letter_spacing
            color: Config.date_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: displayTime
            visible: Config.show_time
            text: Config.time_character + " " +
                  Qt.formatTime(root.currentDate, Config.use_24_hour_format ? "hh:mm" : "hh:mm AP") +
                  " " + Config.time_character
            font.family: fontPoppins.name
            font.pixelSize: Config.time_font_size
            font.letterSpacing: Config.time_letter_spacing
            color: Config.time_font_color
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Drag the transparent clock window to reposition it on the desktop.
    MouseArea {
        anchors.fill: parent
        z: 10
        property point pressPosition
        onPressed: function(mouse) {
            pressPosition = Qt.point(mouse.x, mouse.y)
        }
        onPositionChanged: function(mouse) {
            if (pressed) {
                root.x += mouse.x - pressPosition.x
                root.y += mouse.y - pressPosition.y
            }
        }
    }
}
QML

cat > "$APP_DIR/config.js" <<'CONFIG'
.pragma library

// These defaults match package/contents/config/main.xml in Prayag2/kde_modernclock.
var show_day = true
var day_font_size = 72
var day_letter_spacing = 17
var day_font_color = "#FFFFFF"

var show_date = true
var date_font_size = 19
var date_letter_spacing = 3
var date_font_color = "#FFFFFF"
var date_format = "dd MMM yyyy"

var show_time = true
var time_font_size = 19
var time_letter_spacing = 3
var time_font_color = "#FFFFFF"
var use_24_hour_format = false
var time_character = "-"

// XFCE desktop placement (not part of the original Plasma applet's typography).
var window_margin_right = 64
var window_margin_top = 104
CONFIG

cat > "$APP_DIR/start.sh" <<'START'
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
START

chmod 0755 "$APP_DIR/start.sh"
chmod 0644 "$APP_DIR/main.qml" "$APP_DIR/config.js"
cat > "$AUTOSTART/modern-gaming-clock.desktop" <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Modern Gaming Clock
Comment=Prayag2 Modern Clock faithful XFCE port
Exec=/home/prime/.local/share/modern-gaming-clock/start.sh
OnlyShowIn=XFCE;
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
AUTOSTART
chmod 0644 "$AUTOSTART/modern-gaming-clock.desktop"

# Launch in the current X11 session without restarting XFCE.
nohup "$APP_DIR/start.sh" > "$HOME/.cache/modern-gaming-clock.log" 2>&1 &
echo "Installed original-style Modern Clock with Anurati and Poppins."
DEBIAN

echo
echo "Installed. The visual defaults mirror the upstream KDE widget."
echo "Customize: proot-distro login --user prime debian"
echo "Then edit ~/.local/share/modern-gaming-clock/config.js"
echo "Remove: bash install.sh --remove"
