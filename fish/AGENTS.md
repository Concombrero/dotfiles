# AGENTS.md

## Scope

This package owns the interactive shell environment under `~/.config/fish/`.
Primary entrypoint: `fish/.config/fish/config.fish`.

## Purpose

This is not just prompt customization. The fish config is part of the workstation session model.
It sets editor defaults, shell PATHs, CUDA detection, OpenCode path integration, GTK portal behavior, and imports GUI/session variables from `systemd --user` so long-lived terminals and tmux sessions stay aligned with the active X11 session.

## Change Carefully

- Preserve startup portability; guard optional tools and directories with `if test` or `type -q`.
- Keep machine-specific values out of tracked config; use `~/.config/fish/local.fish`.
- Do not hardcode usernames, hostnames, secrets, project IDs, or machine-local paths beyond well-known optional probes like `/usr/local/cuda`.
- Keep login/session environment propagation intact; changes here can break `i3-msg`, portals, clipboard behavior, and GUI launches from tmux.
- Prefer additive logic over replacing existing session import code.

## Local-Only Pattern

Tracked config must remain portable. Personal values belong in:

- `~/.config/fish/local.fish`

Typical examples:

- cloud credentials
- API keys
- per-machine PATH additions
- local aliases/functions that are not meant to be portable

When editing `config.fish`, preserve the final guarded `source` of `local.fish`.

## Relevant Integrations

- `i3/.config/i3/config`: seeds `systemd --user` and D-Bus activation environment at login
- `tmux/.config/tmux/tmux.conf`: mirrors GUI/session vars into tmux sessions
- `x11/.xprofile`: also exports `GTK_USE_PORTAL=1`
- `xdg-desktop-portal-termfilechooser`: depends on correct shell env when launched through `fish`
- `opencode/.config/opencode/README.md`: documents machine-local OpenCode credentials

## Validation

After edits, validate with a fresh shell when possible:

- run `fish -lic 'printf "%s\n" $EDITOR $VISUAL'`
- confirm expected PATH entries appear only when the directories/tools exist
- if session import logic changed, verify `DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, and `I3SOCK` inside a fresh shell and inside tmux
- if local override logic changed, verify missing `~/.config/fish/local.fish` does not cause errors
