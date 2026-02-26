#!/bin/sh
# Wrapper script for xdg-desktop-portal-termfilechooser -> yazi (in alacritty)

set -eu

multiple="$1"
directory="$2"
save="$3"
path="$4"
out="$5"
verbosity="${6:-0}"

if [ "$verbosity" -ge 4 ] 2>/dev/null; then
    set -x
fi

# Keep positional arguments explicit for readability.
_unused_flags="${multiple}:${save}"

uid="$(id -u)"

# HOME fallback (defensive)
if [ -z "${HOME:-}" ]; then
    HOME="$(eval echo ~"$(id -un)")"
    export HOME
fi

# Runtime/session variables expected by portal-launched GUI clients.
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$uid}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=${XDG_RUNTIME_DIR}/bus}"
export TERM="${TERM:-xterm-256color}"
export COLORTERM="${COLORTERM:-truecolor}"

# If DISPLAY/XAUTHORITY are missing, try systemd activation environment first.
if command -v systemctl >/dev/null 2>&1; then
    while IFS='=' read -r key value; do
        case "$key" in
            DISPLAY)
                [ -n "${DISPLAY:-}" ] || DISPLAY="$value"
                ;;
            XAUTHORITY)
                [ -n "${XAUTHORITY:-}" ] || XAUTHORITY="$value"
                ;;
            XDG_SESSION_TYPE)
                [ -n "${XDG_SESSION_TYPE:-}" ] || XDG_SESSION_TYPE="$value"
                ;;
        esac
    done <<EOF
$(systemctl --user show-environment 2>/dev/null || true)
EOF
fi

[ -n "${DISPLAY:-}" ] && export DISPLAY
if [ -z "${XAUTHORITY:-}" ] && [ -f "$HOME/.Xauthority" ]; then
    XAUTHORITY="$HOME/.Xauthority"
fi
[ -n "${XAUTHORITY:-}" ] && export XAUTHORITY
export XDG_SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"

# Ensure common user/system binary paths are available.
for p in \
    "$HOME/.local/bin" \
    "$HOME/.fzf/bin" \
    "/usr/local/bin" \
    "/usr/local/sbin" \
    "/usr/bin" \
    "/usr/sbin"
do
    case ":${PATH:-}:" in
        *":$p:"*) ;;
        *) PATH="$p:${PATH:-}" ;;
    esac
done
export PATH

# Build yazi arguments without string interpolation/quoting pitfalls.
cwd_out=""
set -- --chooser-file "$out"
if [ "$directory" = "1" ]; then
    cwd_out="${out}.1"
    set -- "$@" --cwd-file "$cwd_out"
fi
set -- "$@" "$path"

# Block until alacritty exits; portal waits for chooser file output.
alacritty \
    --title "File Chooser" \
    -e fish -l -c 'yazi $argv' "$@" \
    </dev/null >/dev/null 2>&1

# Directory mode fallback to cwd-file when chooser output is empty.
if [ "$directory" = "1" ]; then
    if [ ! -s "$out" ] && [ -s "$cwd_out" ]; then
        cp "$cwd_out" "$out"
    fi
    rm -f "$cwd_out"
fi
