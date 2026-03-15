# AGENTS.md

## Overview

This repository is a GNU Stow-managed dotfiles setup for a keyboard-first Ubuntu/Debian or Arch-based workstation.
It is organized as package directories that mirror the final paths under `$HOME`.

- Primary platform: Ubuntu/Debian and Arch-based distros on X11
- Window manager: `i3`
- Compositor: `picom`
- Status bar: `polybar`
- Launcher: `rofi`
- Notifications: `dunst`
- Terminal: `alacritty`
- Shell: `fish`
- Prompt: `starship`
- Editor: `neovim` (`NeoTex` config)
- Terminal multiplexer: `tmux`
- File manager: `yazi`
- Browser stack: `Zen Browser` for daily use, `qutebrowser` config also present
- AI tooling: `OpenCode`, including Neovim integration

Treat this repo as one integrated workstation, not a bag of unrelated configs: shell, tmux, i3, portals, scripts, and editor behavior are intentionally coupled.

## Stow Model

Every top-level package directory is stowed into `$HOME`, so repo paths are source-of-truth mirrors of their installed locations.

- `fish/.config/fish/config.fish` -> `~/.config/fish/config.fish`
- `nvim/.config/nvim/init.lua` -> `~/.config/nvim/init.lua`
- `scripts/.local/bin/...` -> `~/.local/bin/...`
- `latex/.config/latex/...` -> `~/texmf/...` for TeX assets

Rules for changes:

- Always edit the file inside this repo, not the live symlink under `$HOME`.
- Preserve the package-to-target path mapping when adding files.
- After adding, removing, renaming, or moving files inside a stow package, rerun Stow for that package so `$HOME` matches the repo source-of-truth (for example: `stow -R -t "$HOME" opencode` from the repo root).
- New files created in the repo do not appear under `$HOME` until the affected package is re-stowed.
- If the target path in `$HOME` already exists as a real file or directory instead of a symlink, inspect it first, merge or back it up if needed, and then re-stow rather than editing the live copy and leaving the repo out of sync.
- If you add a new stowable package, update `packages/stow_list.txt`.
- Keep root-only repo files out of Stow unless they are meant to land in `$HOME`.
- Respect `.stow-local-ignore`; it intentionally excludes root repo metadata and some machine-local runtime files.

GNU Stow reference: https://www.gnu.org/software/stow/manual/stow.html

Current Stow exclusions in `.stow-local-ignore` include:

- repo metadata like `.git`, `README.md`, `install.sh`
- `opencode/.config/opencode/package.json`
- `opencode/.config/opencode/bun.lock`
- `nvim/.config/nvim/lazy-lock.json`

Those runtime/lock files are intentionally machine-local and should not be treated as portable config by default.

## Machine-Agnostic First

Prefer portable, machine-agnostic code and config.

- Do not hardcode usernames, hostnames, monitor identifiers, absolute machine-specific paths, GPU assumptions, or secrets.
- Prefer discovery, environment variables, conditional checks, and safe fallbacks.
- Keep hardware- or host-specific overrides in local files outside git whenever possible.
- If a config must reference a local path, make it optional and guarded with existence checks.
- Preserve cross-machine behavior for Ubuntu/Debian and Arch-based systems; do not silently narrow support to one exact machine.

Good patterns already used in this repo:

- `fish` checks whether tools/directories exist before adding them to `PATH`.
- CUDA setup is conditional.
- `polybar` hardware names are auto-detected.
- `i3` includes a machine-local `~/.config/i3/local.conf`.
- Git identity is delegated to `~/.gitconfig.local`.
- secrets/env vars live in `~/.config/fish/local.fish`.

## Local-Only Files And Secrets

Never commit personal, secret, or host-specific values into tracked dotfiles.

- Git identity belongs in `~/.gitconfig.local`
- shell secrets and cloud/project vars belong in `~/.config/fish/local.fish`
- OpenCode secrets such as Firecrawl keys belong in `~/.config/opencode/firecrawl_api_key`
- monitor/layout overrides belong in `~/.config/i3/local.conf`

When editing configs, preserve the pattern where tracked files source or include local overrides if present.

## System Integration Notes

Many configs depend on session environment propagation across X11, systemd user services, tmux, and portal processes.

- `fish/.config/fish/config.fish` imports `systemd --user` environment into interactive shells and refreshes tmux env.
- `i3/.config/i3/config` imports GUI vars into systemd/dbus activation env on login, then restarts portal services.
- `tmux/.config/tmux/tmux.conf` updates/propagates GUI/session env so reattached sessions still work with `i3`, clipboard, and portals.
- `x11/.xprofile` and `fish` both set `GTK_USE_PORTAL=1`.
- `xdg-desktop-portal/.config/xdg-desktop-portal/portals.conf` routes file chooser requests to `termfilechooser`.
- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/yazi-wrapper.sh` launches `yazi` in `alacritty` via `fish`.

Be careful when changing shell startup, portal, tmux, i3 startup, or PATH logic: small changes can break file pickers, clipboard behavior, image previews, or GUI app launches from reused sessions.

## Repo Layout

- `install.sh`: bootstrap entrypoint for supported Debian/Ubuntu and Arch-based installs
- `install/`: modular installer logic for packages, tools, desktop setup, and Stow
- `packages/`: distro-specific package lists and Stow package list
- `fish/`, `bash/`, `starship/`, `git/`: shell and CLI environment
- `i3/`, `picom/`, `polybar/`, `rofi/`, `dunst/`, `x11/`, `gtk/`: desktop/X11 stack
- `alacritty/`, `tmux/`, `lazygit/`, `fastfetch/`, `btop/`: terminal tooling
- `nvim/`: NeoTex Neovim config
- `yazi/`, `zathura/`, `qutebrowser/`: application configs
- `xdg-desktop-portal/`, `xdg-desktop-portal-termfilechooser/`: portal routing and terminal file chooser integration
- `scripts/`: local executables and desktop entries
- `wallpapers/`: wallpaper assets
- `opencode/`: OpenCode config

## Editing Guidelines

- Follow the style already used by the file you are touching.
- Make minimal, targeted changes; these configs are interdependent.
- Prefer additive overrides and guarded conditionals over brittle rewrites.
- Do not replace portable logic with one-machine shortcuts.
- Preserve comments that explain non-obvious integration behavior.
- Avoid renaming files/paths that are part of Stow mappings unless the target path change is intentional.

Extra caution areas:

- `nvim/.config/nvim/`: follow local Lua conventions and the nested project guidance in `nvim/.config/nvim/AGENTS.md`
- `scripts/.local/bin/`: keep scripts POSIX-safe or clearly shell-specific; ensure executable behavior remains portable
- `tmux/.config/tmux/tmux.conf`: session env, OSC52 clipboard, and plugin boot behavior are deliberate
- `i3/.config/i3/config`: preserve AZERTY-oriented keybind choices unless intentionally changing the ergonomics
- vendored third-party directories such as `tmux/.config/tmux/plugins/catppuccin/tmux/` and `yazi/.config/yazi/plugins/` should not be casually edited

## Validation

Validate the smallest relevant surface after edits.

- Stow/layout changes: review `packages/stow_list.txt`, `.stow-local-ignore`, and any new package path mapping
- Shell changes: start a fresh `fish` session and verify `PATH`, env vars, and local override loading
- i3/desktop changes: reload i3 and confirm startup commands, portals, wallpaper, and bar behavior
- tmux changes: reload tmux config and verify env propagation, clipboard, and session restore behavior
- Neovim changes: use the workflow in `nvim/.config/nvim/AGENTS.md` and `nvim/.config/nvim/README.md`
- installer changes: verify `install.sh --help` and the touched installer path logic

If you cannot run a full end-to-end check, say what should be manually verified on a real desktop session.

## Documentation Index

Start here, then follow the package-specific docs.

- Root overview and install guide: `README.md`
- Fish package guidance: `fish/AGENTS.md`
- i3 package guidance: `i3/AGENTS.md`
- tmux package guidance: `tmux/AGENTS.md`
- Scripts package guidance: `scripts/AGENTS.md`
- XDG desktop portal routing guidance: `xdg-desktop-portal/AGENTS.md`
- OpenCode config notes: `opencode/.config/opencode/README.md`
- NeoTex overview: `nvim/.config/nvim/README.md`
- NeoTex agent conventions: `nvim/.config/nvim/AGENTS.md`
- NeoTex plugin layout: `nvim/.config/nvim/lua/neotex/plugins/README.md`
- NeoTex config modules: `nvim/.config/nvim/lua/neotex/config/README.md`
- NeoTex utility modules: `nvim/.config/nvim/lua/neotex/util/README.md`
- NeoTex editor plugins: `nvim/.config/nvim/lua/neotex/plugins/editor/README.md`
- NeoTex text plugins: `nvim/.config/nvim/lua/neotex/plugins/text/README.md`
- NeoTex tools/plugins: `nvim/.config/nvim/lua/neotex/plugins/tools/README.md`
- NeoTex tools/snacks notes: `nvim/.config/nvim/lua/neotex/plugins/tools/snacks/README.md`
- NeoTex UI plugins: `nvim/.config/nvim/lua/neotex/plugins/ui/README.md`
- Terminal file chooser package guidance: `xdg-desktop-portal-termfilechooser/AGENTS.md`
- Terminal file chooser implementation notes: `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/agents.md`

Some subdirectories also contain upstream/vendor READMEs. Treat those as third-party reference docs, not authoritative repo conventions, unless this repo clearly overrides them.

## Practical Defaults For Agents

- Assume Ubuntu/Debian, X11, `i3`, `fish`, `alacritty`, and GNU Stow unless a file clearly targets something else.
- Prefer repo-relative config edits over changing live state in `$HOME`.
- Prefer machine-local override files for identity, secrets, and hardware-specific behavior.
- When adding automation, keep it idempotent and safe for repeated bootstrap/stow runs.
- When uncertain about a package's intent, check `README.md`, `packages/stow_list.txt`, and any nearest package README/AGENTS file before changing behavior.
