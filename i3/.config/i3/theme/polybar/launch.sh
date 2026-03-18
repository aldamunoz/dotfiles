#!/usr/bin/env bash

set -u

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

detect_network_module() {
  local iface
  iface="$(ip route get 1.1.1.1 2>/dev/null | awk '/dev /{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"

  if [[ -z "${iface}" ]]; then
    iface="$(ip -o link show up 2>/dev/null | awk -F': ' '!/ lo: /{print $2; exit}')"
  fi

  if [[ -z "${iface}" ]]; then
    iface="$(ip -o link show 2>/dev/null | awk -F': ' '!/ lo: /{print $2; exit}')"
  fi

  if [[ -z "${iface}" ]]; then
    for candidate in /sys/class/net/*; do
      candidate="${candidate##*/}"
      [[ "${candidate}" == "lo" ]] && continue
      iface="${candidate}"
      break
    done
  fi

  POLYBAR_NET_IFACE="${iface:-}"

  if [[ -n "${iface}" && -d "/sys/class/net/${iface}/wireless" ]]; then
    echo "network"
  else
    echo "ethernet"
  fi
}

detect_primary_monitor() {
  xrandr --query | awk '/ connected primary /{print $1; exit}'
}

launch_bar() {
  export POLYBAR_NETWORK_MODULE
  export POLYBAR_NET_IFACE
  POLYBAR_NETWORK_MODULE="$(detect_network_module)"

  killall -q polybar
  while pgrep -u "$UID" -x polybar >/dev/null; do sleep 1; done

  local primary_monitor
  primary_monitor="$(detect_primary_monitor)"

  if [[ -n "${primary_monitor}" ]]; then
    MONITOR="${primary_monitor}" polybar -q main -c "$DIR"/config.ini &
  else
    polybar -q main -c "$DIR"/config.ini &
  fi
}

launch_bar
