# 🎨 Terminal Tones | Themes Manager for Ghostty

<div align="center">


*A beautiful theme manager for Ghostty terminal with 300+ curated color schemes*

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-4EAA25.svg)](https://www.gnu.org/software/bash/)

</div>

---

## ✨ Features

- **300+ Beautiful Themes**: Curated collection from the [Gogh Theme Project](https://github.com/Gogh-Co/Gogh)
- **Interactive Selection**: Easy-to-use numbered menu system
- **Smart Search**: Find themes by name with partial matching
- **Random Theme**: Discover new themes with random selection
- **Live Previews**: See color palettes before applying
- **Auto-Install**: Automatically downloads missing dependencies
- **Cross-Platform**: Works on Linux, macOS, and WSL

---

## 🎯 Quick Start

### Prerequisites
- [Ghostty Terminal](https://ghostty.org/) installed  
- Bash/Zsh/ shell (Not tried on other shell maybe works just fine)  
- Internet connection (for first-time setup)  

### Installation

```bash

git clone https://github.com/viraatmaurya/Terminal-Tones.git
cd Terminal-Tones


chmod +x themes.sh

# Run it!
./themes.sh

```

### Usage

```bash
# Interactive theme selection
./ghostty-themes.sh

# Search for themes
./ghostty-themes.sh -s "dark"

# Apply random theme
./ghostty-themes.sh -r

# List all available themes
./ghostty-themes.sh -l

# Show help
./ghostty-themes.sh -h
```



## 🎨 Available Themes

The script includes **300+ professionally designed themes**, including:  

- **Popular**: One Dark, Dracula, Solarized, Nord, Gruvbox  
- **Dark**: Ayu Dark, Catppuccin Dark, Cyberpunk Dark  
- **Light**: GitHub Light, PaperColor Light, Solarized Light  
- **Colorful**: Cobalt, Purple Rain, Blue Matrix  
- **Minimal**: Zenburn, Monokai, Tomorrow  

👉 View the complete list with:  
```bash
./ghostty-themes.sh -l
```

---

## 🔧 Technical Details

### Dependencies
The script will automatically install these if missing:
- `jq` → JSON processor for theme parsing  
- `sed` → Stream editor for config manipulation  
- `wget` → File downloader for theme updates  

### File Structure

```
~/.config/ghostty/
├── config              # Main Ghostty configuration
└── themes/             # Individual theme color files
    ├── Dracula         # Theme color definitions
    ├── OneDark         # Theme color definitions
    └── ...             # Other themes
```

### How It Works
1. **Theme Discovery**: Themes Stored in json file  
2. **Configuration**: Modifies Ghostty’s config file  
3. **Color Export**: Creates individual theme files  
4. **Application**: Applies selected theme immediately  

---

## 🤝 Contributing

We love contributions! Here’s how you can help:
- **Report Bugs**: Open an issue with detailed description  
- **Suggest Features**: Share your ideas for improvements  
- **Add Themes**: Contribute new theme configurations  
- **Improve Code**: Submit pull requests for enhancements  


---

## 📝 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Viraat Maurya**  
- 💼 Terminal Enthusiast  
- 🎨 Games, Programming, Video Creator  

**Connect with Me**  
- 📷 Instagram: [@viraat_maurya](https://instagram.com/viraat_maurya)  
- 🐦 Twitter: [@viraatmaurya](https://twitter.com/viraat_maurya)  

---

## 🙏 Acknowledgments

- Themes colors courtesy of the [Gogh Theme Project](https://github.com/Gogh-Co/Gogh)  
- Thanks to all contributors and users  

---

## ❓ Frequently Asked Questions

**Q: Will this work on Windows?**  
A: Yes, through **WSL (Windows Subsystem for Linux)**. Install Ghostty for Windows and run the script in WSL.  

**Q: How do I revert to my previous theme?**  
A: Your original config is backed up automatically. You can also manually edit \`~/.config/ghostty/config\`.  

**Q: Can I add custom themes?**  
A: Yes! Themes are stored in **JSON format**. Check the \`themes.json\` file for the format and submit a PR.  

**Q: Does this affect my other terminal configurations?**  
A: No, it only modifies **Ghostty-specific configuration files**.  

**Q: How often are themes updated?**  
A: The script can download the latest themes from GitHub. Run with \`--update\` *(coming soon)*.  

---

<div align="center">

⭐ **If you find this project useful, please give it a star on GitHub!**  

✨ Make your terminal beautiful today! 🎨

</div>