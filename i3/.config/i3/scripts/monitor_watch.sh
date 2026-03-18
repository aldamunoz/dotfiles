#!/usr/bin/env bash

# Hot-plug monitor daemon: re-runs monitor.sh when displays are connected/disconnected.

PIDFILE="/tmp/monitor_watch.pid"

# Kill previous instance
if [[ -f "$PIDFILE" ]]; then
  OLD_PID=$(cat "$PIDFILE")
  if kill -0 "$OLD_PID" 2>/dev/null; then
    kill "$OLD_PID"
  fi
  rm -f "$PIDFILE"
fi

echo $$ >"$PIDFILE"
trap 'rm -f "$PIDFILE"' EXIT

MONITOR_SCRIPT="$HOME/.config/i3/scripts/monitor.sh"
POLYBAR_LAUNCH="$HOME/.config/i3/theme/polybar/launch.sh"

get_displays() {
  xrandr --query | awk '/ connected/{print $1}' | sort | paste -sd','
}

PREV="$(get_displays)"

while true; do
  sleep 2
  CURR="$(get_displays)"
  if [[ "$CURR" != "$PREV" ]]; then
    PREV="$CURR"
    sleep 1  # Let the display finish initializing
    "$MONITOR_SCRIPT"
    bash "$POLYBAR_LAUNCH"
  fi
done
