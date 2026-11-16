# Upstream attribution

This project is a desktop-environment port of **Modern Clock for KDE** by **Prayag Jain**.

- Upstream: https://github.com/Prayag2/kde_modernclock
- Upstream files used as references: `package/contents/ui/main.qml`, `package/contents/config/main.xml`
- Font assets are downloaded from upstream at install time:
  - `Anurati.otf`
  - `Poppins.ttf`

The original project declares GPLv3 in its Plasma applet metadata. The upstream font files are retained as distributed by their author; their respective font licensing/redistribution terms remain applicable. This repository does not claim ownership of those typefaces.

The XFCE host window and integration scripts are a separate adaptation. The Plasma-specific APIs are replaced with standard Qt Quick APIs; the original text layout and default appearance values are preserved.
