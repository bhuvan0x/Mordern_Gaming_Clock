# Mordern Gaming Clock

A customizable, wallpaper-aware XFCE desktop clock for Debian under Termux:X11 / PRoot. It is a faithful port of the visual presentation of [Prayag2's KDE Modern Clock](https://github.com/Prayag2/kde_modernclock), with a native Qt Quick host and an XFCE control centre.

## Features

- Original Anurati weekday and Poppins date/time typography.
- Transparent, frameless clock window.
- **Right-click the clock** to open the Control Centre.
- Region-aware time: choose an IANA time zone (for example `Asia/Kolkata`, `Asia/Tokyo`, `Europe/London`, or `America/New_York`).
- Regional date formatting / locale and 12-hour or 24-hour time.
- Toggle weekday, date and time independently.
- Adjust weekday, date and time font sizes.
- Wallpaper-adaptive text colour: samples the current XFCE wallpaper and chooses a contrasting light or dark text colour. White and dark overrides are also available.
- Drag the clock with the left mouse button. Its exact screen position is saved automatically.
- Settings and position persist across XFCE logouts, `stop-all` / `start-all`, and Debian restarts.

## Install

Designed for Termux + `proot-distro` + Debian 13 ARM64 + XFCE + Termux:X11.

Clone this repository in Termux and run:

```bash
bash install.sh
```

The installer adds the Qt Quick Controls and Qt Settings QML modules, Pillow for wallpaper sampling, XFCE's `xfconf` utility, and the original fonts. It then installs the clock under the Debian user's home directory and creates an XFCE autostart entry.

The Termux-Debian-X11 integration calls this same installer through `scripts/install-modernclock.sh`; it does not maintain a second copy of the clock implementation.

## Control Centre

Right-click anywhere on the clock to open the Control Centre.

| Section | Settings |
|---|---|
| Region & time | Time zone, locale, 12/24-hour clock, date format |
| Display | Weekday/date/time visibility, font sizes, wallpaper adaptive / white / dark text |
| Position | Drag to move; recenter button |
| Reset | Restore default clock preferences |

The clock displays the current real-world time in the selected time zone. It does not change Debian's system clock or Android's clock.

## Persistence

Qt stores the user's preferences in its per-user configuration store under `/home/prime/.config`. The saved window coordinates are part of the same persistent settings. The clock application and autostart entry live under:

- `~/.local/share/modern-gaming-clock/`
- `~/.config/autostart/modern-gaming-clock.desktop`

These paths are in Debian's persistent PRoot rootfs, not in `/tmp`, Termux's temporary session, or XFCE's disposable application-session cache. The existing `start-all` / `stop-all` scripts stop and start XFCE but do not remove the clock configuration.

## Wallpaper adaptation

At clock startup, `detect-wallpaper-theme.sh` reads the selected XFCE wallpaper path from `xfconf`, samples a small image thumbnail using Pillow, and selects white or dark text based on average perceived luminance. The wallpaper-adaptive choice is the default. If the wallpaper is changed while the clock is already running, restart the clock or restart the desktop for a fresh sample.

## Uninstall

```bash
bash install.sh --remove
```

This removes the clock files and its autostart entry. It retains shared Qt packages and the user's saved Qt settings.

## Attribution and licensing

The original clock design references [Prayag2/kde_modernclock](https://github.com/Prayag2/kde_modernclock) by Prayag Jain. The Anurati and Poppins font files are fetched from upstream at installation time; see [NOTICE.md](NOTICE.md) for attribution and font licensing notes. This project is GPLv3; see [LICENSE](LICENSE).
