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

echo "Detected monitors: ${CONNECTED_OUTPUTS[*]:-none}"

if [[ "${#CONNECTED_OUTPUTS[@]}" -gt 0 ]]; then
  PRIMARY_MONITOR="${CONNECTED_OUTPUTS[0]}"
  echo "Configuring monitors; primary: $PRIMARY_MONITOR"

  for monitor in "${CONNECTED_OUTPUTS[@]}"; do
    xrandr --output "$monitor" --auto
  done
  xrandr --output "$PRIMARY_MONITOR" --primary
else
  echo "No monitor detected; nothing to configure."
fi

echo "Monitor setup completed at $(date)"
