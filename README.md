# Mordern Gaming Clock

A lightweight digital desktop clock for XFCE, designed for dark gaming setups and WhiteSur Dark/Blue desktops.

This is an XFCE-native clock inspired by the visual idea of KDE Plasma clock widgets. It does not require KDE Plasma.

## Features
- Large 24-hour digital time
- Uppercase weekday and full date
- White typography with a cool blue accent
- Transparent desktop layer using Conky
- XFCE autostart for the unprivileged `prime` account
- No additional compositor or desktop environment

## Target environment
Termux + proot-distro + Debian + XFCE + Termux:X11. This installer is not a generic Linux installer.

## Install
Clone this repository in Termux and run:

```bash
bash install.sh
```

The installer adds Debian's `conky-all` and `fonts-noto-core`, writes the configuration to `/home/prime/.config/conky/`, adds XFCE autostart, and launches the clock.

## Uninstall
```bash
bash install.sh --remove
```
This removes the clock process, configuration and autostart entry. Conky remains installed in case another configuration uses it.

## Customize
Edit `~/.config/conky/modern-gaming-clock.conf` as the Debian `prime` user. Adjust `alignment`, `gap_x`, `gap_y`, font sizes and hex colours. Restart with:

```bash
pkill -u "$(id -u)" -x conky || true
conky --daemonize --config="$HOME/.config/conky/modern-gaming-clock.conf"
```

## Limitations
Transparency depends on X11 ARGB visual support. Without a compositor, true background blur and animated effects are unavailable; this project intentionally avoids installing one.

## License
GPL-3.0-or-later. See [LICENSE](LICENSE).
