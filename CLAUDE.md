# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ElvUI is a World of Warcraft user interface replacement addon written in Lua. It supports multiple WoW versions:
- **Mainline (Retail)**: Current retail version
- **Mists**: Mists of Pandaria Classic
- **Vanilla/Classic**: Classic WoW (TBC/Wrath/Cata supported via version detection)

## Architecture

### Core Structure

The addon follows a modular architecture built on the Ace3 framework:

- **ElvUI/Core/init.lua**: Main engine initialization. Sets up the global `ElvUI` engine table with structure `{E, L, V, P, G}` (Engine, Locales, PrivateDB, ProfileDB, GlobalDB). All modules import this via `local E, L, V, P, G = unpack(ElvUI)`.

- **Module System**: Each major feature is an AceAddon module (e.g., `E.ActionBars`, `E.UnitFrames`, `E.Bags`). Modules are initialized in init.lua and loaded via XML manifests.

- **Version-Specific Code**:
  - `ElvUI/Core/`: Shared code across all versions
  - `ElvUI/Mainline/`, `ElvUI/Mists/`, `ElvUI/Classic/`: Version-specific modules/filters
  - Version detection: `E.Retail`, `E.Mists`, `E.Classic`, `E.Cata`, `E.Wrath` booleans
  - Special cases: `E.ClassicSOD`, `E.ClassicHC`, `E.ClassicAnniv` for seasons

### Module Organization

**Core Modules** (ElvUI/Core/Modules/):
- ActionBars, Auras, Bags, Chat, DataBars, DataTexts, Maps (Minimap/WorldMap), Nameplates, Skins, Tooltip, UnitFrames
- Each module has its own subdirectory with Elements, Units, or Groups for complex modules like UnitFrames

**Version-Specific Modules**: Mirror the core structure but contain version-exclusive features

**Libraries** (ElvUI_Libraries/): External dependencies managed via .pkgmeta
- Core: Ace3, LibSharedMedia, oUF (unit frame framework), LibCustomGlow, etc.
- Version-specific: LibClassicSpecs (Classic), LibQuestXP (Classic)

**Options** (ElvUI_Options/): Configuration UI using AceConfig, separate addon that loads after ElvUI

### Key Systems

**Database Structure**:
- Profile DB (`E.db`): Per-profile settings, module configs at `E.db.modulename` (e.g., `E.db.unitframe`, `E.db.bags`)
- Global DB (`E.global`): Account-wide settings
- Private DB (`E.private`): Installation/setup flags, stored separately
- Saved variables: `ElvDB`, `ElvPrivateDB`, `ElvCharacterDB`

**Tags System** (ElvUI/Core/General/Tags.lua): Custom text formatting tags for UnitFrames/NamePlates (e.g., `[name]`, `[health:current]`)

**oUF Integration**: Uses oUF (oUF_Elvui fork) as the underlying unit frame framework. UnitFrames module extends oUF elements.

**Media System**: Uses LibSharedMedia for fonts/textures/sounds. `E:UpdateMedia()` refreshes all media references.

**Filters**: Aura filters, style filters for UnitFrames/NamePlates stored in ElvUI/*/Filters/

## Development Commands

### Building and Packaging

```bash
# Update external libraries from repositories
make libs

# The .pkgmeta file defines external dependencies and packaging rules
# BigWigsMods packager is used for releases (see .pkgmeta)
```

### Testing

There is no automated test suite. Testing is done in-game:
- Load the addon in WoW with Interface/AddOns/ElvUI structure
- Use `/elvui` command for config, `/estatus` for status report
- Check for Lua errors via in-game Lua error display addons

### Version Manifests

- TOC files define addon metadata and load order:
  - `ElvUI/ElvUI_Mainline.toc`, `ElvUI_Mists.toc`, `ElvUI_Vanilla.toc`
  - `ElvUI_Libraries/ElvUI_Libraries_*.toc`
  - `ElvUI_Options/ElvUI_Options_*.toc`
- XML files (`Load*.xml`) define Lua file load order for modules

## Code Patterns

### Module Definition

```lua
local E, L, V, P, G = unpack(ElvUI)
local Module = E:GetModule('ModuleName')

function Module:Initialize()
    -- Module setup
end
```

### Adding Defaults

Defaults are defined in ElvUI/Core/Defaults/Profile.lua (P defaults) or Global.lua (G defaults)

### Update Functions

Most modules follow `Module:Update()` pattern for configuration changes. Called from options or profile changes.

### Event Handling

Use Ace3 event system: `Module:RegisterEvent('EVENT_NAME', 'MethodName')` or `Module:RegisterEvent('EVENT_NAME')`

### Hooks

Use AceHook for secure/insecure hooks: `Module:SecureHook()`, `Module:SecureHookScript()`, `Module:RawHook()`

## Version Detection

Always check version flags before using version-specific APIs:

```lua
if E.Retail then
    -- Use retail-only API
elseif E.Mists then
    -- Mists-specific code
elseif E.Classic then
    -- Classic-specific code
end
```

## Important Notes

- **TOC Files**: Each version requires its own .toc file with correct Interface version
- **Load Order**: Core loads first (via Core/Load.xml), then version-specific (Mainline/Load.xml), Options loads last
- **Profile System**: Uses AceDB-3.0. `E.db` is current profile, changes trigger `E:StaggeredUpdateAll()` for full refresh
- **Pixel Perfect**: `E.PixelMode` flag affects border/spacing calculations (`E.Border`, `E.Spacing`)
- **Always disable incompatible addons**: See `E:DisableAddons()` in init.lua for automatically disabled addon list
