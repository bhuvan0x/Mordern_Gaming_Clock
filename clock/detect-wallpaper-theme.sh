#!/usr/bin/env bash
set -Eeuo pipefail
APP_DIR="/home/prime/.local/share/modern-gaming-clock"
THEME_FILE="$APP_DIR/wallpaper-theme.js"
wallpaper=""
if command -v xfconf-query >/dev/null 2>&1; then
  wallpaper="$(xfconf-query -c xfce4-desktop -lv 2>/dev/null | awk '$1 ~ /(last-image|image-path)$/ { $1=""; sub(/^[[:space:]]+/, ""); print; exit }' || true)"
fi
color="#FFFFFF"
if [[ -n "$wallpaper" && -f "$wallpaper" ]] && /usr/bin/python3 - "$wallpaper" <<'PY' >/tmp/modern-clock-color.$$
from PIL import Image, ImageStat
import sys
try:
    im = Image.open(sys.argv[1]).convert("RGB")
    im.thumbnail((48, 48))
    pixels = list(im.getdata())
    if pixels:
        # Perceived sRGB luminance; average over a small thumbnail.
        lum = sum((0.2126*r + 0.7152*g + 0.0722*b) for r,g,b in pixels) / (len(pixels)*255)
        print("#111827" if lum > 0.52 else "#FFFFFF")
    else:
        print("#FFFFFF")
except Exception:
    print("#FFFFFF")
PY
then
  color="$(cat /tmp/modern-clock-color.$$)"
fi
rm -f /tmp/modern-clock-color.$$
printf '.pragma library\nvar textColor = "%s"\n' "$color" > "$THEME_FILE.tmp"
mv "$THEME_FILE.tmp" "$THEME_FILE"
