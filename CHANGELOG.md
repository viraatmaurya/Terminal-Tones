# Changelog
All notable changes to **Terminal Tones** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project follows [Semantic Versioning](https://semver.org/).

---

## [1.0.0] - 2025-10-15
### 🎉 First Stable Release
- Interactive theme selection for terminal tones.
- Command-line options:
  - `-v, --version` : Show program version.
  - `-h, --help`    : Show help message.
  - `-s, --search TERM` : Search for themes containing a specific term.
  - `-r, --random`  : Apply a random theme.
  - `-l, --list`    : List all available themes.
  - `-u, --update`  : Update themes from GitHub.
  - `-q, --quit`    : Run without displaying a banner.
- Examples included in help output for ease of use:
  - Search for dark themes: `terminal-tones.sh -s "dark"`
  - Apply a random theme: `terminal-tones.sh -r`
  - List all themes without selection: `terminal-tones.sh -l`
- Fully tested on supported terminal environments.
- Clean and user-friendly CLI interface.

---


