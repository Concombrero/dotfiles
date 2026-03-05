# AGENTS.md

## Scope

This package owns the i3 window manager config at `i3/.config/i3/config`.

## Purpose

This file is the session orchestrator for the desktop. It does more than keybindings: it starts the compositor, wallpaper, polybar, tray applets, lock integration, portal environment propagation, and local monitor overrides.

## Change Carefully

- Preserve X11/i3 assumptions unless intentionally migrating the whole workstation model.
- Keep AZERTY-oriented keybind choices unless the change is explicitly about keyboard ergonomics.
- Do not hardcode monitor names or layouts in tracked config; machine-specific display commands belong in `~/.config/i3/local.conf`.
- Preserve the `systemctl --user import-environment` and `dbus-update-activation-environment` startup logic; it is critical for portals and GUI apps launched from user services.
- Keep startup commands idempotent where possible; `exec_always` usage is deliberate in several places.
- Be careful with `feh`, `polybar`, `xss-lock`, tray applets, and helper scripts; they are part of the expected desktop boot sequence.

## Local-Only Pattern

Tracked config should remain portable across Ubuntu/Debian machines.
Use this file for machine-local overrides:

- `~/.config/i3/local.conf`

Good uses for `local.conf`:

- `xrandr` monitor layout
- host-specific keyboard tweaks
- laptop/dock specific startup commands

Do not move those directly into the tracked `config` unless they are broadly portable.

## Relevant Integrations

- `polybar/.config/polybar/launch_polybar.sh`: hardware auto-detection for battery, AC, WLAN
- `fish/.config/fish/config.fish`: imports session variables back into interactive shells
- `tmux/.config/tmux/tmux.conf`: keeps reattached tmux sessions aligned with i3/X11 env
- `scripts/.local/bin/`: several helpers are launched directly from i3 binds/startup
- `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf`: portal routing depends on startup env propagation here

## Validation

After edits, validate on a real i3 session when possible:

- run `i3-msg reload` for syntax-safe changes
- verify keybindings you touched still work on AZERTY
- verify polybar, wallpaper, notifications, and tray applets still start correctly
- if startup env logic changed, verify file choosers and `i3-msg` from terminals/tmux still work
- if local override behavior changed, confirm missing `~/.config/i3/local.conf` remains non-fatal
