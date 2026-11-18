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
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$ACTION" == --remove ]]; then
  proot-distro login --isolated --user prime debian -- /bin/bash -lc '
    pkill -u "$(id -u)" -f "/modern-gaming-clock/main.qml" 2>/dev/null || true
    rm -f "$HOME/.config/autostart/modern-gaming-clock.desktop"
    rm -rf "$HOME/.local/share/modern-gaming-clock"
    echo "Modern Gaming Clock removed. Qt user settings are retained unless manually deleted."
  '
  exit 0
fi

echo "== Installing Qt Quick runtime and wallpaper sampling support =="
proot-distro login --isolated debian -- /bin/bash -lc '
  set -Eeuo pipefail
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y qml-qt6 qml6-module-qtquick qml6-module-qtquick-window \
    qml6-module-qtquick-controls qml6-module-qt-labs-settings \
    python3-pil xfconf git
  command -v qml6
'

echo "== Fetching original Modern Clock font assets =="
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

echo "== Deploying the configurable clock =="
proot-distro login --isolated --user prime debian -- /bin/bash -s <<'DEBIAN'
set -Eeuo pipefail
APP_DIR="$HOME/.local/share/modern-gaming-clock"
AUTOSTART="$HOME/.config/autostart"
mkdir -p "$APP_DIR" "$AUTOSTART" "$HOME/.config"

RAW="https://raw.githubusercontent.com/bhuvan0x/Mordern_Gaming_Clock/main"
mkdir -p "$APP_DIR" "$AUTOSTART" "$HOME/.config"
for file in main.qml config.js wallpaper-theme.js start.sh detect-wallpaper-theme.sh; do
  curl -fsSL "$RAW/clock/$file" -o "$APP_DIR/$file"
done
chmod 0755 "$APP_DIR/start.sh" "$APP_DIR/detect-wallpaper-theme.sh"
chmod 0644 "$APP_DIR/main.qml" "$APP_DIR/config.js" "$APP_DIR/wallpaper-theme.js"

cat > "$AUTOSTART/modern-gaming-clock.desktop" <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Modern Gaming Clock
Comment=Persistent customizable wallpaper-aware desktop clock
Exec=/home/prime/.local/share/modern-gaming-clock/start.sh
OnlyShowIn=XFCE;
Terminal=false
StartupNotify=false
X-GNOME-Autostart-enabled=true
AUTOSTART
chmod 0644 "$AUTOSTART/modern-gaming-clock.desktop"

pkill -u "$(id -u)" -f "$APP_DIR/main.qml" 2>/dev/null || true
nohup "$APP_DIR/start.sh" > "$HOME/.cache/modern-gaming-clock.log" 2>&1 &
echo "Installed Modern Gaming Clock and XFCE autostart entry."
echo "Right-click the clock to open its Control Centre."
DEBIAN

echo
echo "Preferences and clock position are saved in Qt's per-user settings."
echo "The clock is restored automatically on every XFCE login / Start All."
echo "Remove: bash install.sh --remove"
