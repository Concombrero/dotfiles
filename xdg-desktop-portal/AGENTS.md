# AGENTS.md

## Scope

This package owns the user portal routing config stowed under `~/.config/xdg-desktop-portal/`.

Tracked file:

- `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf`

## Purpose

This package decides which XDG desktop portal backend handles which portal interface for the whole session.
In this repo it has one especially important job: route `org.freedesktop.impl.portal.FileChooser` to `termfilechooser` while leaving the general default portal backend as `gtk`.

Current intent:

- `default=gtk`
- `org.freedesktop.impl.portal.FileChooser=termfilechooser`

That split is deliberate. It lets the workstation use the terminal-based Yazi chooser for file selection without forcing every other portal capability away from the normal GTK backend.

## Change Carefully

- Treat `portals.conf` as session-wide plumbing, not an app-specific tweak.
- Do not collapse everything onto a single backend unless you understand the impact on file pickers and other portal consumers.
- Keep routing machine-agnostic; do not add host-specific paths, usernames, or environment-dependent values here.
- Keep the `FileChooser` override aligned with the `xdg-desktop-portal-termfilechooser` package.
- Remember that changing this file can affect browsers, GTK apps, screenshots, screen sharing, and any app using XDG portals.

## Relevant Integrations

- `xdg-desktop-portal-termfilechooser/AGENTS.md`: documents the backend selected for `FileChooser`
- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/config`: backend command configuration
- `i3/.config/i3/config`: imports GUI/session variables and restarts portal services on login
- `fish/.config/fish/config.fish`: exports `GTK_USE_PORTAL=1` so GTK apps actually use portal file dialogs
- `x11/.xprofile`: also exports `GTK_USE_PORTAL=1`

## Validation

After edits, validate the routing end to end when possible:

- restart relevant user services with `systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-termfilechooser.service`
- verify the chooser still opens in `alacritty`/`yazi` for GTK apps such as Zen Browser
- verify non-file-chooser portal behavior still falls back to the expected GTK backend
- inspect logs with `journalctl --user -u xdg-desktop-portal.service -f` if routing behaves unexpectedly

## Practical Rule

If you are changing file chooser behavior, review both this package and `xdg-desktop-portal-termfilechooser/` together. They are two halves of the same integration.
