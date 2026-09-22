# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal Arch Linux desktop dotfiles for an i3 + X11 setup, managed with GNU Stow. Each top-level directory is a stow "package" whose internal path mirrors its destination under `$HOME` (e.g. `i3/.config/i3/...` → `~/.config/i3/...`) - except `lightdm/`, which is rooted at `/` (system paths under `/etc` and `/var/lib`, not `$HOME`) since it configures the LightDM greeter rather than the user session.

## Common commands

Install/stow user packages (run from repo root):
```bash
stow -t ~ dunst fastfetch gtk i3 kitty mpd ncmpcpp nvim
```
Restow after editing a package (safe to re-run):
```bash
stow -R -t ~ i3
```
Install/restow the LightDM package (needs sudo, different target root):
```bash
sudo stow -t / -d ~/dotfiles lightdm
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
- `02_keybindings.conf` — keybindings. A `bindsym` line followed by `  # hint: <description>` shows up in the `rofi_keyhint` cheatsheet (`Mod+k`) - tag new bindings this way if they're worth surfacing there; it's a curated list, not every binding needs one
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
- `rofi/` — one `.rasi` per menu (launcher, powermenu, bluetooth, screenshot, networkmenu, windows, music, askpass, asroot, confirm, keyhint), sharing `shared/colors.rasi` and `shared/fonts.rasi`
- `system.ini` — machine-specific network interface name; regenerate using the command documented inside the file, not by guessing values
- Wallpapers live in `i3/.config/i3/wallpapers/`; the active one is set by `xwallpaper --zoom` in `i3_autostart`. `rofi_wallpaper` (`Mod+Shift+p`) shows them as a thumbnail grid via rofi's icon protocol, applies the pick immediately, and remembers it in `~/.cache/i3/wallpaper` (runtime state, deliberately not tracked in git) - `i3_autostart` reads that file on startup, falling back to the hardcoded default if it doesn't exist yet

### LightDM (`lightdm/`)
Rooted at `/`, not `$HOME` (see Overview). `etc/lightdm/lightdm-gtk-greeter.conf` sets theme/icon-theme to match the desktop's `gtk-application-prefer-dark-theme` (see `gtk/`), plus the login background. `var/lib/AccountsService/users/patricio` points AccountsService at the avatar. The avatar image and background image themselves aren't stowed - they're binary files copied into system paths at setup time by `lightdm/setup.sh` (source: `~/.face` and an existing wallpaper from `i3/.config/i3/wallpapers/`), since duplicating them into git would bloat the repo.

The greeter GUI runs as an unprivileged `lightdm` system user (not root, unlike `accounts-daemon`), so it can't read the stowed config through a 700 home directory on its own - `lightdm/setup.sh` also grants that user narrow ACL access (`setfacl`) to just `~/dotfiles/lightdm/`, rather than loosening the home directory itself. Run `sudo ~/dotfiles/lightdm/setup.sh` after stowing (and again any time the ACLs need reapplying, e.g. a fresh home directory).

### fastfetch (`fastfetch/`)
`.config/fastfetch/config.jsonc` - grouped sections (Hardware/Software/Uptime) with icon-prefixed labels, colored to match the rofi/i3 accent (`#da6e89`). Note the inline color syntax: `{#da6e89}` is for named/ANSI colors, true hex RGB needs a doubled hash - `{##da6e89}` - a single `#` here silently becomes "invalid color code" at runtime, not a config-parse error.

### Neovim
LazyVim-based config under `nvim/.config/nvim/`: `init.lua` bootstraps `lua/config/lazy.lua`, which loads `lua/config/{options,keymaps,autocmds}.lua` and any `lua/plugins/*.lua` spec files. `lazy-lock.json` pins plugin commits — don't hand-edit it, let `:Lazy` update it.
