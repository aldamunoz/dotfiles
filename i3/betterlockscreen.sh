#!/bin/bash

# Path to the lockscreen image using $HOME
LOCKSCREEN_IMAGE="$HOME/.config/i3/wallpapers/room.png"

# Check if the file exists
if [ -f "$LOCKSCREEN_IMAGE" ]; then
  # Update betterlockscreen cache
  betterlockscreen -u "$LOCKSCREEN_IMAGE" --blur 0.7
else
  echo "Lockscreen image not found: $LOCKSCREEN_IMAGE"
  exit 1
fi
