#!/usr/bin/env bash
set -Eeuo pipefail

ACTION="${1:-install}"
if [[ "$ACTION" == "--remove" ]]; then
  if ! command -v proot-distro >/dev/null 2>&1; then
    echo "Run this from Termux with proot-distro installed." >&2
    exit 1
  fi
  proot-distro login --isolated --user prime debian -- /bin/bash -lc '
    pkill -u "$(id -u)" -x conky 2>/dev/null || true
    rm -f "$HOME/.config/autostart/primebook-modernclock.desktop"
    rm -f "$HOME/.config/conky/primebook-modernclock.conf"
    echo "Modern Gaming Clock profile removed."
  '
  exit 0
fi
if [[ "$ACTION" != install ]]; then
  echo "Usage: bash install.sh [--remove]" >&2
  exit 2
fi
command -v proot-distro >/dev/null 2>&1 || {
  echo "This installer targets Termux + proot-distro + Debian XFCE." >&2
  exit 1
}

echo "Installing Conky and Noto Sans inside Debian..."
proot-distro login --isolated debian -- /bin/bash -lc '
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y conky-all fonts-noto-core
'

echo "Configuring Modern Gaming Clock for the prime XFCE session..."
proot-distro login --isolated --user prime debian -- /bin/bash -s <<'DEBIAN'
set -Eeuo pipefail
mkdir -p "$HOME/.config/conky" "$HOME/.config/autostart"
cat > "$HOME/.config/conky/modern-gaming-clock.conf" <<'CONF'
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 0,
    default_color = 'F3F6FF',
    draw_borders = false,
    draw_graph_borders = false,
    draw_outline = false,
    draw_shades = false,
    double_buffer = true,
    gap_x = 64,
    gap_y = 104,
    maximum_width = 560,
    minimum_width = 340,
    own_window = true,
    own_window_class = 'ModernGamingClock',
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    update_interval = 1,
    use_xft = true,
    xftalpha = 1,
};
conky.text = [[
${font Noto Sans:style=Bold:size=13}${color #8FB7FF}${execi 60 date +%A | tr '[:lower:]' '[:upper:]'}${color}
${voffset 5}${font Noto Sans:style=Regular:size=15}${color #C9D8F5}${time %d %B %Y}${color}
${voffset 1}${font Noto Sans:style=Bold:size=56}${color #F3F6FF}${time %H:%M}${color}
]];
CONF
cat > "$HOME/.config/autostart/primebook-modernclock.desktop" <<'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Modern Gaming Clock
Comment=Minimal gaming-inspired desktop clock
Exec=conky --daemonize --config=/home/prime/.config/conky/modern-gaming-clock.conf
OnlyShowIn=XFCE;
Terminal=false
StartupNotify=false
AUTOSTART
chmod 0644 "$HOME/.config/conky/modern-gaming-clock.conf" "$HOME/.config/autostart/primebook-modernclock.desktop"
pkill -u "$(id -u)" -x conky 2>/dev/null || true
sleep 1
DISPLAY="${DISPLAY:-:0}" conky --daemonize --config="$HOME/.config/conky/modern-gaming-clock.conf"
echo "Modern Gaming Clock installed for XFCE."
DEBIAN
echo "Done. To uninstall: bash install.sh --remove"
