#!/usr/bin/env bash
set -euo pipefail

## -------------------------------------------------
## Paths
## -------------------------------------------------
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SFILE="$DIR/system.ini"
RFILE="$DIR/.system"

## -------------------------------------------------
## Helpers
## -------------------------------------------------
command_exists() {
  command -v "$1" &>/dev/null
}

set_ini_value() {
  local key="$1"
  local value="$2"

  if grep -q "^$key =" "$SFILE"; then
    sed -i "s|^$key = .*|$key = $value|" "$SFILE"
  else
    echo "$key = $value" >>"$SFILE"
  fi
}

## -------------------------------------------------
## Detect system values
## -------------------------------------------------
get_backlight() {
  if command_exists light; then
    light -L | awk -F/ '/backlight/ {print $NF; exit}'
  elif [[ -d /sys/class/backlight ]]; then
    ls /sys/class/backlight | head -n1
  fi
}

get_battery() {
  upower -e 2>/dev/null | grep -E 'BAT|battery' | head -n1 | xargs -r upower -i |
    awk -F: '/native-path/ {gsub(/ /,"",$2); print $2}'
}

get_adapter() {
  upower -e 2>/dev/null | grep -E 'AC|line_power' | head -n1 | xargs -r upower -i |
    awk -F: '/native-path/ {gsub(/ /,"",$2); print $2}'
}

get_network_interface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'
}

## -------------------------------------------------
## Apply values
## -------------------------------------------------
apply_values() {
  local card battery adapter iface

  card="$(get_backlight || true)"
  battery="$(get_battery || true)"
  adapter="$(get_adapter || true)"
  iface="$(get_network_interface || true)"

  [[ -n "$adapter" ]] && set_ini_value sys_adapter "$adapter"
  [[ -n "$battery" ]] && set_ini_value sys_battery "$battery"
  [[ -n "$card" ]] && set_ini_value sys_graphics_card "$card"
  [[ -n "$iface" ]] && set_ini_value sys_network_interface "$iface"
}

## -------------------------------------------------
## Launch Polybar
## -------------------------------------------------
launch_bar() {
  bash "$DIR/polybar/launch.sh"
}

## -------------------------------------------------
## Main
## -------------------------------------------------
if [[ ! -f "$RFILE" || "${1:-}" == "--refresh" ]]; then
  apply_values
  touch "$RFILE"
fi

launch_bar
