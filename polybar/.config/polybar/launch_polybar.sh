#!/usr/bin/env bash

set -euo pipefail

DIR="${XDG_CONFIG_HOME:-$HOME/.config}/polybar"

detect_power_supply_names() {
  local supply type name

  for supply in /sys/class/power_supply/*; do
    [ -e "$supply/type" ] || continue
    type="$(tr '[:upper:]' '[:lower:]' < "$supply/type")"
    name="$(basename "$supply")"

    case "$type" in
      battery)
        : "${POLYBAR_BATTERY:=$name}"
        ;;
      mains|ac)
        : "${POLYBAR_ADAPTER:=$name}"
        ;;
    esac
  done

  export POLYBAR_BATTERY POLYBAR_ADAPTER
}

# Wait until PulseAudio-compatible socket is ready (PipeWire-Pulse on modern setups)
if command -v pactl >/dev/null 2>&1; then
  attempts=30
  while [ "$attempts" -gt 0 ]; do
    if pactl info >/dev/null 2>&1; then
      break
    fi
    attempts=$((attempts - 1))
    sleep 0.2
  done
fi

detect_power_supply_names

if command -v xrandr >/dev/null 2>&1; then
  while IFS= read -r monitor; do
    MONITOR="$monitor" polybar --reload --config="$DIR/config.ini" toph &
  done < <(xrandr --query | awk '/ connected/{print $1}')
else
  polybar --reload --config="$DIR/config.ini" toph &
fi
