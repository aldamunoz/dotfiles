#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

echo "==> Dotfiles installer"

# -----------------------------
# Check dependencies
# -----------------------------
for cmd in git sudo pacman; do
  command -v "$cmd" >/dev/null || {
    echo "Missing dependency: $cmd"
    exit 1
  }
done

# -----------------------------
# Package groups
# -----------------------------
BASE_PKGS=(
  i3-wm i3lock xorg-server xorg-xinit
  stow
  dunst picom
  polybar rofi kitty
  betterlockscreen xss-lock
  xorg-xset xsettingsd
  polkit-gnome
  lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings accountsservice
  xorg-xrandr xorg-xsetroot xorg-xprop xorg-xinput
  xdotool xclip maim slop
  xwallpaper feh
  fastfetch
  mpd ncmpcpp
  pipewire pipewire-pulse wireplumber
  networkmanager network-manager-applet python-gobject
  bluez bluez-utils
  pulsemixer
  jq curl wget bc
)

DEV_PKGS=(
  git
  neovim
  tmux
)

# -----------------------------
# Install function
# -----------------------------
install_pkgs() {
  echo "Installing: $*"
  sudo pacman -S --needed --noconfirm "$@"
}

# -----------------------------
# Base install
# -----------------------------
install_pkgs "${BASE_PKGS[@]}"
install_pkgs "${DEV_PKGS[@]}"

# -----------------------------
# Enable services
# -----------------------------
systemctl --user enable mpd.service
systemctl --user enable pipewire.service
systemctl --user enable wireplumber.service
sudo systemctl enable lightdm.service

echo "==> Done."
echo "Next steps:"
echo "  stow dunst fastfetch gtk i3 kitty mpd ncmpcpp nvim"
echo "  sudo stow -t / -d ~/dotfiles lightdm && sudo ~/dotfiles/lightdm/setup.sh"
