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

detect_network_interfaces() {
  local iface state default_iface

  default_iface=""
  if command -v ip >/dev/null 2>&1; then
    default_iface="$(ip route show default 2>/dev/null | awk '{print $5; exit}')"
  fi

  if [ -n "${default_iface:-}" ] && [ -d "/sys/class/net/$default_iface/wireless" ]; then
    POLYBAR_WLAN_INTERFACE="$default_iface"
  fi

  if [ -z "${POLYBAR_WLAN_INTERFACE:-}" ]; then
    for iface in /sys/class/net/*; do
      iface="$(basename "$iface")"
      [ "$iface" = "lo" ] && continue
      [ -d "/sys/class/net/$iface/wireless" ] || continue
      state="$(cat "/sys/class/net/$iface/operstate" 2>/dev/null || true)"
      if [ "$state" = "up" ]; then
        POLYBAR_WLAN_INTERFACE="$iface"
        break
      fi
    done
  fi

  if [ -z "${POLYBAR_WLAN_INTERFACE:-}" ]; then
    for iface in /sys/class/net/*; do
      iface="$(basename "$iface")"
      [ "$iface" = "lo" ] && continue
      [ -d "/sys/class/net/$iface/wireless" ] || continue
      POLYBAR_WLAN_INTERFACE="$iface"
      break
    done
  fi

  if [ -n "${default_iface:-}" ] && [ ! -d "/sys/class/net/$default_iface/wireless" ]; then
    POLYBAR_ETH_INTERFACE="$default_iface"
  fi

  if [ -z "${POLYBAR_ETH_INTERFACE:-}" ]; then
    for iface in /sys/class/net/*; do
      iface="$(basename "$iface")"
      [ "$iface" = "lo" ] && continue
      [ -d "/sys/class/net/$iface/wireless" ] && continue
      state="$(cat "/sys/class/net/$iface/operstate" 2>/dev/null || true)"
      if [ "$state" = "up" ]; then
        POLYBAR_ETH_INTERFACE="$iface"
        break
      fi
    done
  fi

  if [ -z "${POLYBAR_ETH_INTERFACE:-}" ]; then
    for iface in /sys/class/net/*; do
      iface="$(basename "$iface")"
      [ "$iface" = "lo" ] && continue
      [ -d "/sys/class/net/$iface/wireless" ] && continue
      POLYBAR_ETH_INTERFACE="$iface"
      break
    done
  fi

  export POLYBAR_WLAN_INTERFACE POLYBAR_ETH_INTERFACE
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
detect_network_interfaces

if command -v xrandr >/dev/null 2>&1; then
  while IFS= read -r monitor; do
    MONITOR="$monitor" polybar --reload --config="$DIR/config.ini" toph &
  done < <(xrandr --query | awk '/ connected/{print $1}')
else
  polybar --reload --config="$DIR/config.ini" toph &
fi
