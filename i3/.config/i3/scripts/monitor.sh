#!/usr/bin/env bash

set -u

LOG_FILE="/tmp/monitor_setup.log"
exec >"$LOG_FILE" 2>&1

echo "Monitor setup initiated at $(date)"

if ! command -v xrandr >/dev/null 2>&1; then
  echo "xrandr not found; skipping monitor setup."
  exit 0
fi

mapfile -t CONNECTED_OUTPUTS < <(xrandr --query | awk '/ connected/{print $1}')

LAPTOP_SCREEN=""
EXTERNAL_MONITORS=()

for output in "${CONNECTED_OUTPUTS[@]}"; do
  if [[ "$output" == eDP* || "$output" == LVDS* || "$output" == DSI* ]]; then
    LAPTOP_SCREEN="$output"
  else
    EXTERNAL_MONITORS+=("$output")
  fi
done

echo "Detected laptop screen: ${LAPTOP_SCREEN:-none}"
echo "Detected external monitors: ${EXTERNAL_MONITORS[*]:-none}"

if [[ "${#EXTERNAL_MONITORS[@]}" -gt 0 ]]; then
  PRIMARY_MONITOR="${EXTERNAL_MONITORS[0]}"
  echo "Configuring external monitors; primary: $PRIMARY_MONITOR"

  for monitor in "${EXTERNAL_MONITORS[@]}"; do
    xrandr --output "$monitor" --auto
  done
  xrandr --output "$PRIMARY_MONITOR" --primary

  if [[ -n "$LAPTOP_SCREEN" ]]; then
    xrandr --output "$LAPTOP_SCREEN" --off
  fi
else
  echo "No external monitor detected."
  if [[ -n "$LAPTOP_SCREEN" ]]; then
    xrandr --output "$LAPTOP_SCREEN" --auto --primary
  else
    echo "No laptop panel detected either; nothing to configure."
  fi
fi

echo "Monitor setup completed at $(date)"
