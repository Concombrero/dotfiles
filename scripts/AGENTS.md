# AGENTS.md

## Scope

This package owns user scripts and desktop entries stowed under:

- `~/.local/bin/`
- `~/.local/share/applications/`

Treat this package with extra caution. These scripts glue together i3, tmux, portals, screenshots, browser launchers, tab behavior, and document workflows.

## General Rules

- Keep scripts portable across Ubuntu/Debian, Fedora, and Arch-based machines.
- Do not hardcode usernames, hostnames, monitor outputs, or secret values.
- Prefer POSIX `sh` when possible; use `bash` only when arrays, `mapfile`, `[[ ... ]]`, or other bash-specific features materially help.
- Quote all arguments and paths carefully, especially anything forwarded to terminals, `i3-msg`, `tmux`, `rofi`, or desktop files.
- Guard optional dependencies with `command -v` when failure is acceptable.
- Fail safely: avoid destructive behavior, and preserve current tolerant patterns such as `|| true` where the script intentionally degrades gracefully.

## Why This Package Is Sensitive

Many scripts here are session glue, not isolated utilities.
Examples include:

- i3 helpers like `i3-tab-title-fix`
- tmux launch/menu helpers like `rofi-tmux-sessions`
- focus restoration helpers like `flameshot-gui-focus-fix`
- browser/document launch wrappers under `~/.local/bin/`

Small quoting or environment mistakes can break launcher behavior, focus management, file opening, or workspace/tab logic.

## Desktop Entries

Files under `scripts/.local/share/applications/` affect launcher and MIME behavior.

- keep `Exec=` commands compatible with the installed script paths under `~/.local/bin/`
- avoid machine-local absolute paths unless unavoidable
- preserve interoperability with `xdg-open`, i3, and the existing document/tab workflow

## Relevant Integrations

- `i3/.config/i3/config`: launches several scripts directly
- `tmux/.config/tmux/tmux.conf`: scripts may expect tmux session behavior
- `fish/.config/fish/config.fish`: shell environment influences script execution
- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/`: file chooser flow depends on wrapper behavior and environment

## Validation

After edits, validate the exact script path you changed:

- run the script directly with representative arguments when safe
- if launched by i3, test it from an actual i3 session
- if it shells out to `tmux`, `rofi`, `i3-msg`, `xdotool`, or `flameshot`, verify the interaction end-to-end
- if you changed a desktop entry, verify it still works via `xdg-open` or the launcher path it serves
