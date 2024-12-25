#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# Launch the bar
launch_bar() {
  # Terminate already running bar instances
  killall -q polybar

  # Wait until the processes have been shut down
  while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
  # Get the primary monitor
  PRIMARY_MONITOR=$(xrandr --listmonitors | awk '$2 == "+*"{print $4}')
  # Launch Polybar only on the primary monitor
  MONITOR=$PRIMARY_MONITOR polybar -q main -c "$DIR"/config.ini &
}

launch_bar
