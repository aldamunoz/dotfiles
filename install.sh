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
  dunst picom feh
  polkit-gnome
  stow
  iwd
  polybar
  rofi
  kitty
  betterlockscreen
  xss-lock
  mpd
  ncmpcpp
  pipewire
  pipewire-pulse
  wireplumber
)

LAPTOP_PKGS=(
  upower
  light
  iwd
  xfce4-power-manager
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
install_pkgs "${DESKTOP_PKGS[@]}"
install_pkgs "${AUDIO_PKGS[@]}"
install_pkgs "${DEV_PKGS[@]}"

# -----------------------------
# Laptop detection
# -----------------------------
if [[ -d /sys/class/power_supply/BAT0 ]]; then
  echo "Laptop detected"
  install_pkgs "${LAPTOP_PKGS[@]}"
fi

# -----------------------------
# Enable services
# -----------------------------
systemctl --user enable mpd.service
systemctl --user enable pipewire.service
systemctl --user enable wireplumber.service

echo "==> Done."
echo "Next steps:"
echo "  stow i3 polybar mpd ncmpcpp kitty"
