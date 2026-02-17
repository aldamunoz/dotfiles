# Dotfiles (i3 + X11 + Stow)

Personal desktop setup for Arch Linux based on i3, polybar, rofi, kitty, mpd, and helper scripts.

## What Is Included

- `i3` modular config (`config` + `config.d/*`)
- polybar theme and launcher under `~/.config/i3/theme/polybar`
- rofi launchers, power menus, screenshot menu, bluetooth menu
- screenshot workflow (keybindings + rofi integration)
- mpd/ncmpcpp setup
- kitty, dunst, nvim configs
- laptop/desktop-aware monitor and autostart scripts

## Repository Layout

```text
.
├── dunst/
├── i3/
├── kitty/
├── mpd/
├── ncmpcpp/
├── nvim/
├── packages/
├── aliases
├── install.sh
└── README.md
```

## Required Base Packages

These are required for the current configs/scripts to work as expected.

```bash
sudo pacman -S --needed \
  i3-wm i3lock xorg-server xorg-xinit \
  stow dunst picom polybar rofi kitty \
  betterlockscreen xss-lock polkit-gnome \
  mpd ncmpcpp pipewire pipewire-pulse wireplumber \
  xorg-xrandr xorg-xsetroot xorg-xprop xorg-xinput \
  xdotool xclip maim slop \
  light xorg-xbacklight pulsemixer \
  networkmanager network-manager-applet python-gobject \
  bluez bluez-utils \
  xwallpaper feh acpi upower \
  jq curl wget bc
```

## Optional Packages

Install as needed depending on your workflow.

```bash
sudo pacman -S --needed \
  loupe viewnior audacious bluetui \
  kvantum-qt5 qt5ct pavucontrol
```

## Install and Stow

1. Clone:

```bash
git clone https://github.com/aldamunoz/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

2. Stow packages:

```bash
stow -t ~ dunst i3 kitty mpd ncmpcpp nvim
```

3. Enable user services:

```bash
systemctl --user enable --now mpd pipewire wireplumber
```

4. Enable system services:

```bash
sudo systemctl enable --now NetworkManager bluetooth
```

## Daily Usage

- Reload i3 config: `Mod+Shift+c`
- Restart i3 inplace: `Ctrl+Shift+r`
- Screenshot menu: `Mod+s`
- Screenshot keys:
  - `Print` full
  - `Mod+Print` area
  - `Ctrl+Shift+Print` window
  - `Ctrl+Print` delayed 5s
  - `Shift+Print` delayed 10s

## Verification Commands

Use these after changes:

```bash
i3 -C -c ~/.config/i3/config
bash -n ~/.config/i3/scripts/i3_autostart
bash -n ~/.config/i3/scripts/i3_screenshot
bash -n ~/.config/i3/theme/polybar/launch.sh
```

## Notes

- Polybar config lives under i3: `~/.config/i3/theme/polybar/`
- TUI apps can be launched in floating kitty via `~/.config/i3/scripts/i3_kitty --float -e <app>`
- Screenshot script now treats cancel (`Esc`) as cancel and does not save/open a file
- If `bluetoothctl` is flaky after system updates, polybar bluetooth output may degrade to simple `On/Off` until BlueZ/kernel side is stable

## Troubleshooting

### Polybar modules missing

```bash
pkill polybar
~/.config/i3/theme/polybar/launch.sh
polybar -q main -c ~/.config/i3/theme/polybar/config.ini -l trace 2>&1 | tee /tmp/polybar.log
```

### Screenshot issues

```bash
~/.config/i3/scripts/i3_screenshot --area
```

### Bluetooth status issues

```bash
systemctl status bluetooth --no-pager
rfkill list bluetooth
bluetoothctl show
bluetoothctl devices Connected
```
