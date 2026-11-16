# Mordern Gaming Clock

<p align="center">
  <img src="https://raw.githubusercontent.com/Prayag2/kde_modernclock/main/assets/ss.png" alt="Original Prayag2 Modern Clock appearance" width="760">
</p>

A faithful XFCE/Termux:X11 port of [Prayag2's KDE Modern Clock](https://github.com/Prayag2/kde_modernclock).

This is **not a generic lookalike clock**. The rendered three-row layout, bundled typefaces, default typography, letter spacing, date/time formatting, colours, and style-character output follow the upstream applet. The Plasma-only shell is replaced with a frameless transparent Qt Quick window so the same design can run on XFCE without installing KDE Plasma.

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

The original Anurati and Poppins font files are fetched directly from Prayag2's upstream repository during installation.

## Install

Designed for Termux + `proot-distro` + Debian 13 + XFCE + Termux:X11.

```bash
bash install.sh
```

The installer installs Debian's Qt 6 QML runtime, fetches the original fonts, installs the clock, creates an XFCE autostart entry, and launches it in the current session.

## Position and transparency

- The clock opens horizontally and vertically centered on the screen.
- The QML window background is transparent; only the clock text is drawn.
- Drag the clock to reposition it.
- Edit `~/.local/share/modern-gaming-clock/config.js` as Debian user `prime`. Set `center_offset_x` or `center_offset_y` to adjust the initial centered position.

Transparency is rendered through Qt's transparent X11 window. The final compositing behavior depends on Termux:X11/XFWM and the active desktop configuration; no compositor is installed by this project.

## Uninstall

```bash
bash install.sh --remove
```

This removes the QML clock, its autostart entry, and the previous Conky approximation's files. It does not remove shared Qt packages.

## Attribution and licensing

The design and font assets originate from [Prayag2/kde_modernclock](https://github.com/Prayag2/kde_modernclock) by Prayag Jain. See [NOTICE.md](NOTICE.md) for attribution and upstream licensing notes. The project follows GPLv3; see [LICENSE](LICENSE).

## Platform boundary

The typography, content layout and default output follow the upstream applet. The Plasma applet frame/shadow and Plasma settings dialog are replaced by a transparent frameless XFCE window and editable config file.
