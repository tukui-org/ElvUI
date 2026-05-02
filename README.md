# ElvUI

**A comprehensive User Interface replacement AddOn for World of Warcraft.**

ElvUI is a complete UI redesign for World of Warcraft, featuring customizable unit frames, action bars, bags, chat, and much more. This repository contains the source code for the ElvUI add-on.

[![Support](https://img.shields.io/badge/Support-❤️-FF96D7?style=flat-square)](https://tukui.org/support)
[![Download](https://img.shields.io/badge/Download-📁-1784d1?style=flat-square)](https://tukui.org/elvui)
[![Changelog](https://img.shields.io/badge/Changelog-📃-1784d1?style=flat-square)](https://github.com/tukui-org/ElvUI/blob/main/CHANGELOG.md)
[![Discord](https://img.shields.io/discord/209244641537556480?style=flat-square&color=5865F2&label=Discord)](https://discord.tukui.org)

---

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Development Setup](#development-setup)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [Support & Community](#support--community)

---

## Features

- **Customizable Unit Frames** - Highly configurable raid, party, and player frames
- **Action Bars** - Multiple action bars with full customization
- **Bag Organization** - Improved bag UI with sorting and searching
- **Chat Enhancement** - Customizable chat panels and filters
- **Data Bars** - Experience, reputation, and other important bars
- **Minimap Replacement** - Fully customizable minimap
- **Raid Tools** - Tools for raid groups and mythic+ dungeons
- **Multi-Game Support** - Compatible with Vanilla, TBC, Wrath, Mists, and Mainline WoW

---

## New to Open Source?
This guide is an excellent introduction and explains all the jargon we may use: https://medium.com/clarifai-champions/99-pr-oblems-a-beginners-guide-to-open-source-abc1b867385a
If you ever get stuck or want to have a chat, join us on our [Discord](https://discord.tukui.org) server. We love to hear what you're (going to be) working on!

## Prerequisites

Before you begin, ensure you have the following installed:

### Required
- **Git** - Download from [git-scm.com](https://git-scm.com/download/win)
- **World of Warcraft** - The game client ([Battle.net](https://www.battle.net/))
- **Text Editor or IDE** - [VS Code](https://code.visualstudio.com/) (recommended), Notepad++, or similar

### Optional but Recommended
- **Lua Language Server** - For code completion and linting
- **Git GUI** - [GitHub Desktop](https://desktop.github.com/) or [GitKraken](https://www.gitkraken.com/) for easier version control

---

## Installation

### For Users (Playing the Game)

1. Download the latest release from [tukui.org/elvui](https://tukui.org/elvui)
2. Extract the files to your World of Warcraft AddOns folder:
   ```
   C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Restart World of Warcraft
4. Enable the add-on in the Add-ons menu

### For Developers (Working with Source Code)

1. **Clone the repository** to your WoW AddOns folder:
   ```bash
   cd "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\"
   git clone https://github.com/tukui-org/ElvUI.git
   git clone https://github.com/tukui-org/ElvUI_Libraries.git
   git clone https://github.com/tukui-org/ElvUI_Options.git
   ```

2. **Alternative: Clone to a custom directory and link**
   ```bash
   cd C:\Users\YourUsername\Desktop
   git clone https://github.com/tukui-org/ElvUI.git
   # Then create symbolic links in your AddOns folder (requires admin)
   ```

3. **Install dependencies** (ElvUI libraries):
   - ElvUI requires `ElvUI_Libraries` and `ElvUI_Options` to function
   - Both must be in the same AddOns folder

---

## Development Setup

### 1. Fork the Repository

1. Go to [github.com/tukui-org/ElvUI](https://github.com/tukui-org/ElvUI)
2. Click the **Fork** button (top-right corner)
3. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/ElvUI.git
   cd ElvUI
   git remote add upstream https://github.com/tukui-org/ElvUI.git
   ```

### 2. Project Structure

```
ElvUI/
├── ElvUI/                    # Main add-on folder
│   ├── Game/                 # Game version-specific code
│   │   ├── Classic/          # Vanilla WoW
│   │   ├── Mainline/         # Current retail WoW
│   │   ├── Mists/            # Mists of Pandaria
│   │   ├── TBC/              # The Burning Crusade
│   │   ├── Wrath/            # Wrath of the Lich King
│   │   └── Shared/           # Shared code across versions
│   └── Locales/              # Translations (enUS, deDE, etc.)
├── ElvUI_Libraries/          # Required library dependencies
├── ElvUI_Options/            # Configuration UI
└── README.md                 # This file
```

### 3. Set Up Your Development Environment

1. **Open VS Code** in the ElvUI directory:
   ```bash
   code .
   ```

2. **Install Lua extensions** (optional but recommended):
   - Lua Language Server
   - Lua by Sumneko
   - Better Comments

3. **Configure your workspace** for WoW Lua API knowledge (optional)

---

## Testing

### Running ElvUI Locally

1. **Place the add-on in your AddOns folder** (as described above)

2. **Launch World of Warcraft** and test:
   - Log in with your character
   - Type `/elvui` in chat to open the configuration panel
   - Test UI elements (unit frames, action bars, bags, etc.)
   - Check the chat logs for any errors

3. **Check the Error Log** (if something breaks):
   ```
   In-game chat: /console scriptErrors 1
   Then check: World of Warcraft\_retail_\Errors.txt
   ```

4. **Test Different Game Versions** (if applicable):
   - Vanilla: `World of Warcraft\_classic_\`
   - TBC: `World of Warcraft\_classic_era_\`
   - Wrath: `World of Warcraft\_classic_wrath_\`
   - Mists: `World of Warcraft\_mists_\`
   - Mainline (Retail): `World of Warcraft\_retail_\`

### Making Changes

1. **Create a new branch** for your changes:
   ```bash
   git checkout -b fix/your-issue-name
   ```

2. **Edit the Lua files** in your favorite editor

3. **Reload UI in-game** to test changes:
   - Type `/reload` or `/rl` in chat
   - Or restart the game client

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "fix: brief description of what you fixed"
   ```

5. **Push to your fork**:
   ```bash
   git push origin fix/your-issue-name
   ```

6. **Create a Pull Request** on GitHub

---

## Contributing

We welcome contributions! Here's how to help:

### Before You Start
- Check [open issues](https://github.com/tukui-org/ElvUI/issues) to avoid duplicates
- Join our [Discord](https://discord.tukui.org) to discuss major changes first

### Guidelines
- **Keep changes focused** - One fix or feature per pull request
- **Test thoroughly** - Ensure your changes work in-game
- **Write clear commit messages** - Use conventional commits (fix:, feat:, docs:)
- **Follow code style** - Match the existing code format
- **Comment complex code** - Explain non-obvious logic
- **Test multiple WoW versions** if the code affects multiple versions

### Commit Message Format
```
fix: brief description of the fix
feat: brief description of the feature
docs: update documentation
refactor: code restructuring
perf: performance improvements
```

---

## Support & Community

### Questions & Help
- **Discord Server**: [discord.tukui.org](https://discord.tukui.org)


### Useful Links
- **Website**: [tukui.org](https://tukui.org)
- **Download**: [tukui.org/elvui](https://tukui.org/elvui)
- **Issues**: [GitHub Issues](https://github.com/tukui-org/ElvUI/issues)
- **Pull Requests**: [GitHub PRs](https://github.com/tukui-org/ElvUI/pulls)
- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)

### Reporting Bugs

When reporting a bug, please include:
1. **WoW Version** (Retail, Classic, TBC, Wrath, etc.)
2. **ElvUI Version**
3. **Detailed description** of the issue
4. **Steps to reproduce** the problem
5. **Error messages** or screenshots if applicable
6. **List of other add-ons** you have installed

---

## License

ElvUI is licensed under the GNU General Public License v3.0. See [LICENSE.md](./LICENSE.md) for details.

---

**Happy customizing! If you have any questions, join our Discord community.**
