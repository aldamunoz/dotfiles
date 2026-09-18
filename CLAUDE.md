# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Arch Linux desktop dotfiles for an i3 + X11 setup, managed with GNU Stow. Each top-level directory is a stow "package" whose internal path mirrors its destination under `$HOME` (e.g. `i3/.config/i3/...` → `~/.config/i3/...`).

## Common commands

Install/stow packages (run from repo root):
```bash
stow -t ~ dunst gtk i3 kitty mpd ncmpcpp nvim
```
Restow after editing a package (safe to re-run):
```bash
stow -R -t ~ i3
```

Full machine bootstrap (installs pacman packages, enables services): `./install.sh`

Validate i3/shell changes before reloading i3 (`Mod+Shift+c`) or restarting it (`Ctrl+Shift+r`):
```bash
i3 -C -c ~/.config/i3/config                       # validate i3 config syntax
bash -n ~/.config/i3/scripts/i3_autostart           # syntax-check a script
bash -n ~/.config/i3/scripts/i3_screenshot
bash -n ~/.config/i3/theme/polybar/launch.sh
```
Run this same `bash -n <script>` check after editing any script under `i3/.config/i3/scripts/`.

Polybar debugging:
```bash
pkill polybar && ~/.config/i3/theme/polybar/launch.sh
polybar -q main -c ~/.config/i3/theme/polybar/config.ini -l trace 2>&1 | tee /tmp/polybar.log
```

## Architecture

### i3 config composition
`i3/.config/i3/config` is the entry point and only does two things: `include ~/.config/i3/config.d/*.conf` and define autostart `exec_always` lines. All actual configuration lives in numbered files under `config.d/`, loaded in lexical order:
- `01_theme.conf` — fonts, borders, gaps, color variables (`$i3_*`) referenced elsewhere
- `02_keybindings.conf` — keybindings
- `03_mousebindings.conf` — mouse bindings
- `04_modes.conf` — i3 modes (e.g. Resize)
- `05_rules.conf` — workspace/window assignment rules

When adding config, put it in the matching numbered file rather than the root `config`, and preserve load order if a new file is needed (theme vars must load before anything referencing `$i3_*`).

### Startup flow
`exec_always` in `config` triggers, in order: `monitor.sh` (xrandr layout), `monitor_watch.sh` (hotplug daemon that restarts polybar on display change), and `i3_autostart` (the main session bootstrap — kills stale daemons from a prior i3 reload, starts gnome-keyring, xsettingsd, polkit agent, ksuperkey, wallpaper, dunst, `i3_bar`/`i3_comp`, idle inhibitor, and the idle/lock/suspend chain). Because these run with `exec_always`, they must be idempotent across i3 config reloads — hence the `kill_safe`/`start_once` helper pattern in `i3_autostart`.

### Idle/lock/suspend chain
`i3_autostart` sets X11 screensaver timers (`xset s`) and starts `xss-lock --transfer-sleep-lock -- lock_and_suspend`. Flow: idle timeout or lid-close/manual suspend → xss-lock invokes `lock_and_suspend` → it backgrounds `betterlockscreen -l`, waits for i3lock to actually grab the screen before releasing xss-lock's sleep inhibitor fd (avoids a brief unlocked window on sleep events), then polls until unlocked or `SUSPEND_DELAY` elapses, at which point it calls `systemctl suspend`. When changing timing, keep the comment above `xset s` in `i3_autostart` and `SUSPEND_DELAY` in `lock_and_suspend` in sync — they describe the same flow from two files.

### Scripts (`i3/.config/i3/scripts/`)
Flat directory of standalone bash scripts: polybar module data sources (`cpu_usage`, `disk`, `memory`, `temperature`, `bandwidth2`, `openweather*`), rofi-driven menus (`rofi_*` scripts paired with `.rasi` themes in `theme/rofi/`), and window-manager helpers (`i3_kitty`, `i3_term`, `i3_screenshot`, `i3_colorpicker`, `i3_music`, `i3_volume`, `i3_mouse`). Each script is self-contained and invoked directly from keybindings or polybar module definitions — there's no shared lib, so keep helpers duplicated per-script rather than introducing cross-script imports.

### Theming (`i3/.config/i3/theme/`)
- `polybar/` — bar config split into `config.ini` (bar geometry), `colors.ini`, `decor.ini` (separators/borders), `modules.ini` (module definitions), launched via `launch.sh`
- `rofi/` — one `.rasi` per menu (launcher, powermenu, bluetooth, screenshot, networkmenu, windows, music, askpass, asroot, confirm), sharing `shared/colors.rasi` and `shared/fonts.rasi`
- `system.ini` — machine-specific network interface name; regenerate using the command documented inside the file, not by guessing values
- Wallpapers live in `i3/.config/i3/wallpapers/`; the active one is set by `xwallpaper --zoom` in `i3_autostart`

### Neovim
LazyVim-based config under `nvim/.config/nvim/`: `init.lua` bootstraps `lua/config/lazy.lua`, which loads `lua/config/{options,keymaps,autocmds}.lua` and any `lua/plugins/*.lua` spec files. `lazy-lock.json` pins plugin commits — don't hand-edit it, let `:Lazy` update it.
