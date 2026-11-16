# Mordern Gaming Clock

<p align="center">
  <img src="https://raw.githubusercontent.com/Prayag2/kde_modernclock/main/assets/ss.png" alt="Original Prayag2 Modern Clock appearance" width="760">
</p>

A faithful XFCE/Termux:X11 port of [Prayag2's KDE Modern Clock](https://github.com/Prayag2/kde_modernclock).

This is **not a generic lookalike clock**. The rendered three-row layout, bundled typefaces, default typography, letter spacing, date/time formatting, colours, and style-character output follow the upstream applet. The Plasma-only shell is replaced with a transparent, frameless Qt Quick window so the same design can run on XFCE without installing KDE Plasma.

## What matches the original

| Element | Upstream default |
|---|---|
| Day | Anurati, 72 px, 17 px letter spacing, uppercase |
| Date | Poppins, 19 px, 3 px letter spacing, `dd MMM yyyy`, uppercase |
| Time | Poppins, 19 px, 3 px letter spacing |
| Time format | 12-hour with AM/PM |
| Style character | `-` on both sides of the time |
| Text colour | White |
| Column spacing | 5 px |

The original Anurati and Poppins font files are fetched directly from Prayag2's upstream repository during installation. The original upstream QML is Plasma-specific; this port preserves its presentation and defaults while replacing only the Plasma data source and applet container with standard Qt Quick.

## Install

Designed for Termux + `proot-distro` + Debian 13 + XFCE + Termux:X11.

Clone this repository in Termux, then run:

```bash
bash install.sh
```

The installer installs Debian's Qt 6 QML runtime, fetches the original fonts, installs the Qt Quick clock, creates an XFCE autostart entry, and launches it in the current session.

## Position and customization

- Drag the clock with the mouse to reposition it.
- Edit `~/.local/share/modern-gaming-clock/config.js` as the Debian `prime` user to change visibility, font sizes, letter spacing, colours, date format, 12/24-hour mode, and style character.
- The default desktop placement is near the upper-right corner. Change `window_margin_right` and `window_margin_top` in `config.js` to adjust its initial position.

## Uninstall

```bash
bash install.sh --remove
```

This removes the QML clock, its autostart entry, and the previous Conky approximation's files. It does not remove shared Qt packages.

## Attribution and licensing

The design, original QML structure, and font assets originate from [Prayag2/kde_modernclock](https://github.com/Prayag2/kde_modernclock) by Prayag Jain. See [NOTICE.md](NOTICE.md) for attribution and upstream licensing notes. The project follows GPLv3; see [LICENSE](LICENSE).

## Platform limitations

This port uses the same typography and content layout, but it is not the Plasma applet itself. KDE's applet shadow/background frame and Plasma configuration UI are replaced by a frameless XFCE desktop window and an editable config file. Transparency and desktop stacking depend on Termux:X11/XFWM support. No compositor or KDE Plasma session is installed.
