# AGENTS.md

## Scope

This package owns the termfilechooser user config stowed under `~/.config/xdg-desktop-portal-termfilechooser/`.

Tracked files here:

- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/config`
- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh`
- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/agents.md` (implementation notes)

## Purpose

This package makes the terminal file chooser backend usable as the default GTK/XDG portal file picker on this workstation.
In practice, GTK apps such as Zen Browser request `org.freedesktop.impl.portal.FileChooser`, `xdg-desktop-portal` routes that request to `termfilechooser`, and the backend launches `yazi` inside `alacritty` through `yazi-wrapper.sh`.

The wrapper is not a cosmetic launcher. It is compatibility glue for:

- portal -> terminal process boundaries
- systemd user environment propagation
- X11/Wayland session variable recovery
- terminal capability detection for `yazi` and preview backends
- directory chooser fallback behavior via `--cwd-file`
- safe argument forwarding when paths contain spaces

## Architecture

High-level flow:

- GTK app uses portal because `GTK_USE_PORTAL=1`
- `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf` routes `FileChooser` to `termfilechooser`
- the installed portal backend reads this package's `config`
- `config` points `cmd=` at `yazi-wrapper.sh`
- `yazi-wrapper.sh` reconstructs a usable session environment if the service context is sparse
- `alacritty` launches `yazi` with `--chooser-file` and sometimes `--cwd-file`
- `yazi` writes the chosen path back to the chooser file for the portal response

## Critical Behaviors To Preserve

- Preserve full stdio redirection on the terminal launch: `</dev/null >/dev/null 2>&1` is deliberate.
- Preserve argument quoting and forwarding; portal-supplied paths may contain spaces.
- Preserve the systemd environment lookup and fallback chain for `DISPLAY`, `WAYLAND_DISPLAY`, `XDG_RUNTIME_DIR`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_SESSION_TYPE`, `XDG_CURRENT_DESKTOP`, and `XAUTHORITY`.
- Preserve PATH bootstrapping for common user/system binary locations without introducing machine-specific paths.
- Preserve the directory-mode fallback that copies `--cwd-file` into the chooser output when no file is selected.
- Preserve behavior when `yazi` is directly on PATH and when it is only available through a `fish -l` login shell.

These details exist because the portal service may run with stale or incomplete environment state, and because terminal graphics output from `yazi` preview tooling can confuse the portal process if stdio is inherited.

## Change Carefully

- Do not simplify the wrapper unless you have traced the portal invocation model end to end.
- Do not replace portable environment discovery with hardcoded usernames, displays, runtime dirs, or host-specific terminal commands.
- Keep the config machine-agnostic; terminal overrides should remain optional via `TERMCMD`, not committed as one-machine defaults.
- Treat both X11 and Wayland-related recovery logic as intentional, even though the main workstation target is X11.
- Do not remove the fish login-shell fallback casually; it helps load shell-configured environment such as PATH and optional CUDA libraries.
- Keep failure behavior conservative: this code runs inside a user-service-driven file chooser path, so noisy failures degrade UX across browsers and GTK apps.

## Relevant Integrations

- `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf`: selects this backend for `FileChooser`
- `i3/.config/i3/config`: imports GUI vars into systemd/D-Bus activation env and restarts portal services on login
- `fish/.config/fish/config.fish`: exports `GTK_USE_PORTAL=1` and defines shell environment used by the login-shell fallback
- `x11/.xprofile`: also exports `GTK_USE_PORTAL=1`
- `alacritty/.config/alacritty/alacritty.toml`: expected terminal emulator for chooser sessions
- `yazi/.config/yazi/`: expected file manager configuration used by the chooser

## System-Level Assumptions

This repo only manages the user-level config. The actual backend binary/service are system-level pieces installed separately.

Expected external pieces include:

- `/usr/local/libexec/xdg-desktop-portal-termfilechooser`
- `/usr/local/lib/systemd/user/xdg-desktop-portal-termfilechooser.service`
- `/usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service`
- `/usr/share/xdg-desktop-portal/portals/termfilechooser.portal`

Do not assume the repo alone provisions those binaries.

## Validation

After edits, test the real chooser path when possible:

- run `systemctl --user status xdg-desktop-portal-termfilechooser.service`
- inspect logs with `journalctl --user -u xdg-desktop-portal-termfilechooser.service -f`
- verify `systemctl --user show-environment` contains the expected GUI/session vars
- test the wrapper directly with `~/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh 0 0 0 "$HOME" /tmp/test-chooser-out`
- verify a GTK app such as Zen Browser opens `yazi` in `alacritty` and returns the selected path correctly

## Additional Reference

For the full debugging history and root-cause analysis, read:

- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/agents.md`
