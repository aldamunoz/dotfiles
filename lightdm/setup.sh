#!/usr/bin/env bash
#
# One-time setup for LightDM: ACL access + avatar + login background.
#
# The lightdm-gtk-greeter GUI runs as its own restricted system user
# (lightdm), separate from accounts-daemon (runs as root). A 700 home
# directory blocks that user from reading stow's symlink target inside
# ~/dotfiles/lightdm/, even though the file itself is world-readable -
# accounts-daemon (root) doesn't hit this, which is why the avatar can
# work while the greeter config silently falls back to defaults. Grant
# the lightdm user narrow ACL access to just that one package instead
# of loosening the home directory itself.
#
# The avatar/background are binary files copied into system paths
# (LightDM/AccountsService can't read into the home dir at all, ACL or
# not, for files outside the lightdm/ package) - not tracked as
# duplicate blobs in this repo, sourced from files already here
# (~/.face and an i3 wallpaper).
#
# Run after stowing the lightdm package:
#   sudo stow -t / -d ~/dotfiles lightdm
#   sudo ~/dotfiles/lightdm/setup.sh

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WALLPAPER="$DIR/i3/.config/i3/wallpapers/wk5pvtr.png"
TARGET_USER="${SUDO_USER:-$USER}"
HOME_DIR="/home/$TARGET_USER"
FACE="$HOME_DIR/.face"

if [[ $EUID -ne 0 ]]; then
  echo "Run this with sudo." >&2
  exit 1
fi

setfacl -m u:lightdm:x "$HOME_DIR"
setfacl -m u:lightdm:x "$DIR"
setfacl -R -m u:lightdm:rX "$DIR/lightdm"
echo "Granted lightdm user ACL access to $DIR/lightdm"

if [[ -f "$FACE" ]]; then
  install -m 644 "$FACE" /var/lib/AccountsService/icons/patricio.jpg
  echo "Installed avatar -> /var/lib/AccountsService/icons/patricio.jpg"
else
  echo "No ~/.face found, skipping avatar." >&2
fi

if [[ -f "$WALLPAPER" ]]; then
  install -m 644 "$WALLPAPER" /usr/share/backgrounds/lightdm-patricio.png
  echo "Installed background -> /usr/share/backgrounds/lightdm-patricio.png"
else
  echo "Wallpaper not found at $WALLPAPER, skipping." >&2
fi
