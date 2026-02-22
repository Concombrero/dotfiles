DIR="$HOME/.config/polybar"

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

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload --config="$DIR/config.ini" toph &
  done
else
  polybar --reload toph &
fi 
