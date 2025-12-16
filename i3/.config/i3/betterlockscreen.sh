#!/bin/bash
set -e

LOCKSCREEN_IMAGE="$HOME/.config/i3/wallpapers/room.png"

[ -f "$LOCKSCREEN_IMAGE" ] || {
  echo "Lockscreen image not found: $LOCKSCREEN_IMAGE" >&2
  exit 1
}

betterlockscreen -u "$LOCKSCREEN_IMAGE" --blur 0.7
