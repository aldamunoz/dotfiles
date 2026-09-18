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
get_network_interface() {
  ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'
}

## -------------------------------------------------
## Apply values
## -------------------------------------------------
apply_values() {
  local iface

  iface="$(get_network_interface || true)"

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
