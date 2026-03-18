#!/usr/bin/env bash

## Copyright (C) 2020-2025 Aditya Shakya <adi1090x@gmail.com>

# Colors
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
CDIR=$(cd "$DIR" && cd .. && pwd)
POWER_ON=$(grep 'GREEN' <"$CDIR"/colors.ini | head -n1 | cut -d '=' -f2 | tr -d ' ')
POWER_OFF=$(grep 'ALTFOREGROUND' <"$CDIR"/colors.ini | head -n1 | cut -d '=' -f2 | tr -d ' ')

# Checks if bluetooth controller is powered on
power_on() {
  local state_file

  # Default-controller check first.
  if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    return 0
  fi

  # If no controller exists, bluetooth is effectively off.
  if ! compgen -G "/sys/class/bluetooth/hci*" >/dev/null; then
    return 1
  fi

  # Fallback: if any controller rfkill state is 1, treat as powered on.
  for state_file in /sys/class/bluetooth/hci*/rfkill*/state; do
    [[ -r "$state_file" ]] || continue
    if [[ "$(cat "$state_file" 2>/dev/null)" == "1" ]]; then
      return 0
    fi
  done

  # Last fallback: controller exists but bluetoothctl/rfkill info is unavailable.
  return 0
}

# Checks if a device is connected
device_connected() {
  device_info=$(bluetoothctl info "$1")
  if echo "$device_info" | grep -q "Connected: yes"; then
    return 0
  else
    return 1
  fi
}

connected_devices() {
  local paired_devices_cmd
  local device
  local seen=""
  local known_path
  local mac

  add_unique_device() {
    local addr="$1"
    [[ -n "$addr" ]] || return 0
    case " $seen " in
    *" $addr "*) ;;
    *)
      devices+=("$addr")
      seen="$seen $addr"
      ;;
    esac
  }

  while read -r device; do
    add_unique_device "$device"
  done < <(bluetoothctl devices Connected 2>/dev/null | awk '/^Device /{print $2}')

  paired_devices_cmd="devices Paired"
  if ! bluetoothctl "$paired_devices_cmd" >/dev/null 2>&1; then
    paired_devices_cmd="paired-devices"
  fi

  while read -r device; do
    [[ -n "$device" ]] || continue
    if device_connected "$device"; then
      add_unique_device "$device"
    fi
  done < <(bluetoothctl "$paired_devices_cmd" 2>/dev/null | awk '/^Device /{print $2}')

  # Fallback for environments where bluetoothctl listing is flaky after updates.
  if [[ ${#devices[@]} -eq 0 ]]; then
    while read -r known_path; do
      mac="$(basename "$known_path")"
      if [[ "$mac" =~ ^([0-9A-F]{2}:){5}[0-9A-F]{2}$ ]] && device_connected "$mac"; then
        add_unique_device "$mac"
      fi
    done < <(find /var/lib/bluetooth -mindepth 2 -maxdepth 2 -type d 2>/dev/null)
  fi
}

# Prints a short string with the current bluetooth status
# Useful for status bars like polybar, etc.
print_status() {
  if power_on; then
    local -a devices=()
    connected_devices
    counter=0
    icons=""

    for device in "${devices[@]}"; do
      if device_connected "$device"; then
        device_alias=$(bluetoothctl info "$device" | grep "Alias" | cut -d ' ' -f 2-)
        device_type=$(bluetoothctl info "$device" | grep "Icon" | cut -d ' ' -f 2-)

        case $device_type in
        "input-mouse")
          icons="$icons | 󰍽"
          ;;
        "audio-headset")
          icons="$icons | 󰋎"
          ;;
        "audio-headphones")
          icons="$icons | "
          ;;
        "audio-card" | "audio-speaker")
          icons="$icons | 󰓃"
          ;;
        "input-keyboard")
          icons="$icons | 󰌌"
          ;;
        "input-gaming")
          icons="$icons | 󰖺"
          ;;
        "phone")
          icons="$icons | "
          ;;
        *)
          icons="$icons | $device_type"
          ;;
        esac
        ((counter++))
      fi
    done
    icons=$(echo "$icons" | cut -c3-)

    if [[ $counter -gt 1 ]]; then
      echo "%{F$POWER_ON}%{T2}%{T-} %{F-}$icons"
    elif [[ $counter -gt 0 ]]; then
      echo "%{F$POWER_ON}%{T2}%{T-} %{F-}$icons | $device_alias"
    else
      echo "%{F$POWER_ON}%{T2}%{T-} %{F-}On"
    fi
  else
    echo "%{F$POWER_OFF}%{T2}%{T-} Off%{F-}"
  fi
}

# Print Status
print_status
