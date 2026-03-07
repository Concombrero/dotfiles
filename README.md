# Workstation Dotfiles
GNU Stow-managed dotfiles for a full Ubuntu/Debian + i3 (X11) workstation.

![Home screen](preview.png)
## System Overview

This repo is designed as one cohesive, keyboard-first environment rather than a loose set of config files.

The principles used for building this system are simple :

- Keyboard is King
- Distractions are evil
- Defaults are fine

This is all materialized through a set of tools that tries to stay minimal while providing a solid out of the box experience that can be easily extended and customized.
Visually, anything that can be is themed with [Catppuccin](https://github.com/catppuccin), using the Mocha flavor.


- Desktop/Window management:
    - Tiling WM : `i3` 
    - Compositor : `picom`
    - Status bar : `polybar` 
    - App launcher / Menu : `rofi`
    - Notifications : `dunst`
    - Lockscreen : `betterlockscreen`
    - File Manager : `yazi` (via CLI)
- Command Line Interface : 
  - Terminal emulator : `alacritty`
  - Shell : `fish`
  - Prompt : `starship`
  - Enhancements : `tmux`, `lazygit`, `zoxide`, `fzf` and more
- Editing: `neovim` (see [NeoTex README](nvim/.config/nvim/README.md) for details).
- Web : Zen Browser
- AI workflow : OpenCode agent, with integration in Neovim. 
- Workspace-local document/media tabs: PDFs/images are grouped into dedicated i3 tabbed containers per workspace.

The repository includes wallpaper assets under `wallpapers/Pictures/Wallpapers/`.


## Installation Guide

### 1) Prerequisites

You only need `git` to start.

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git
```

### 2) Clone this repo

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
```

### 3) Run bootstrap installer

```bash
./install.sh
```

**For Servers or Headless Systems:**
If you don't want the desktop environment (i3, polybar, fonts, etc.), run:

```bash
./install.sh --headless
```

> [!NOTE]
> The bootstrap installer currently supports **Ubuntu and Debian only**.

What this does at a high level:

1. **Detects OS:** Verifies Ubuntu/Debian and uses `apt`.
2. **Installs Packages:** Core CLI packages and desktop packages (if not headless).
3. **Installs Binaries:** `neovim` (official release archive), `starship`, `zoxide`, `yazi`, `lazygit`, `fzf` (via git clone to `~/.fzf`), `opencode`, `zen-browser`.
4. **Installs Python Tools:** Uses `pipx` to safely install `ipython`, `black`, `isort`, etc.
5. **Configures System:** Adds fonts (optional), sets wallpaper, configures MIME handlers.
6. **Stows Configs:** Symlinks all dotfiles into `$HOME`.

Installer log: `~/dotfiles/install.log`

### 4) First login checks

1. Log out and back in.
2. Open Neovim and run:
   - `:Lazy sync`
   - `:Mason`
   - `:checkhealth`

> [!IMPORTANT]
> The i3 config swaps `Caps Lock` and `Escape` (`setxkbmap -option caps:swapescape`). If you do not want this behavior, remove that line from `i3/.config/i3/config`.

## Installer Flags

| Flag | Meaning |
|---|---|
| `--headless`, `--no-gui` | Skip desktop/GUI packages (i3, polybar, fonts, wallpapers, Zen browser). |
| `--skip-packages` | Skip system package installation (`apt`). |
| `--skip-tools` | Skip external tool installation (binaries like `starship`, `yazi`, etc.). |
| `--skip-fonts` | Skip Nerd Fonts installation. |
| `--skip-ppas` | Skip adding Ubuntu PPAs (Debian skips PPAs automatically). |
| `--stow-only` | Only run stow (skip all installations). |

Example:

```bash
./install.sh --headless
```

## What `install.sh` Provisions

### Packages (via System Package Manager)
Defined in `packages/common.txt` and `packages/desktop.txt`.

- **Core:** `git`, `stow`, `tmux`, `curl`, `wget`, `unzip`, `bc`, `build-essential`, `cmake`, `python3`, `nodejs`, `npm`, `btop`
- **Desktop:** `i3-wm`, `polybar`, `picom`, `rofi`, `dunst`, `flameshot`, `alacritty`, `fastfetch`, `zathura`, `sxiv`, `qutebrowser`

### External Tools/Binaries
- `neovim` (official prebuilt archive from GitHub releases)
- `fzf` (git clone to `~/.fzf`)
- `starship` (official installer)
- `zoxide` (official installer)
- `yazi` + `ya` (GitHub release binary)
- `lazygit` (GitHub release binary)
- `opencode` (official installer)
- `zen-browser` (official installer)
- `betterlockscreen` (official installer)

### Python Tools (via pipx)
Installed in isolated environments to avoid breaking system Python:
- `ipython`, `jupytext`, `black`, `isort`, `pylint`

### Fonts
- `JetBrainsMono Nerd Font`
- `RobotoMono Nerd Font`
- `NerdFontsSymbolsOnly`
- `Font Awesome`

## Stow Packages Applied by Installer

| Package | Target |
|---|---|
| `bash` | `~/.bashrc`, `~/.profile`, `~/.fzf.bash` |
| `fish` | `~/.config/fish/` |
| `starship` | `~/.config/starship.toml` |
| `git` | `~/.gitconfig` |
| `i3` | `~/.config/i3/config` |
| `polybar` | `~/.config/polybar/` |
| `picom` | `~/.config/picom/picom.conf` |
| `rofi` | `~/.config/rofi/` |
| `dunst` | `~/.config/dunst/dunstrc` |
| `alacritty` | `~/.config/alacritty/alacritty.toml` |
| `nvim` | `~/.config/nvim/` |
| `yazi` | `~/.config/yazi/` |
| `zathura` | `~/.config/zathura/` |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `fontconfig` | `~/.config/fontconfig/fonts.conf` |
| `fastfetch` | `~/.config/fastfetch/config.jsonc` |
| `btop` | `~/.config/btop/btop.conf` |
| `tmux` | `~/.config/tmux/tmux.conf` |
| `systemd` | `~/.config/systemd/user/tmux.service` |
| `qutebrowser` | `~/.config/qutebrowser/` |
| `xdg-desktop-portal` | `~/.config/xdg-desktop-portal/portals.conf` |
| `xdg-desktop-portal-termfilechooser` | `~/.config/xdg-desktop-portal-termfilechooser/` |
| `latex` | `~/texmf/` (custom `.bst` files) |
| `scripts` | `~/.local/bin/` and `~/.local/share/applications/` |
| `wallpapers` | `~/Pictures/Wallpapers/` |
| `opencode` | `~/.config/opencode/opencode.json` |

> [!NOTE]
> tmux-continuum may have already generated `~/.config/systemd/user/tmux.service`.
> If stowing `systemd` reports a conflict, move that file aside once and restow.

## Manual Setup Checklist

These items are either manual setup or useful post-install checks.

### 1) `xdg-desktop-portal-termfilechooser` backend (for Yazi file picker)

The config is stowed, and `install.sh` now installs the Ubuntu/Debian runtime + build dependencies for this backend as part of the normal desktop package set.

The backend binary itself still needs a one-time manual source install because there is no standard Ubuntu/Debian package for `xdg-desktop-portal-termfilechooser`:

```bash
git clone https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser.git /tmp/xdptf
cd /tmp/xdptf
meson setup build
ninja -C build
sudo ninja -C build install
```

If `meson setup` complains about manpage tooling, retry with:

```bash
meson setup build -Dman-pages=disabled
```

Then relogin, or run:

```bash
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS I3SOCK PATH
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS I3SOCK PATH
systemctl --user restart xdg-desktop-portal-termfilechooser.service
```

### 2) Machine-specific monitor config

Create `~/.config/i3/local.conf` for monitor/layout overrides:

```bash
cat > ~/.config/i3/local.conf << 'EOF'
# Example
exec --no-startup-id xrandr --output eDP-1 --off --output HDMI-1 --auto
EOF
```

### 3) Polybar hardware names

`polybar/.config/polybar/config.ini` uses auto-detection by default:

- Wireless interface is auto-detected in `polybar/.config/polybar/launch_polybar.sh` and exported as `POLYBAR_WLAN_INTERFACE`.
- Battery/AC names are auto-detected in `polybar/.config/polybar/launch_polybar.sh` and exported as `POLYBAR_BATTERY`/`POLYBAR_ADAPTER`.

If needed, you can still override manually via environment variables before launching polybar.

### 4) Betterlockscreen cache (recommended)

Initialize lockscreen cache from your wallpaper directory:

```bash
betterlockscreen -u ~/Pictures/Wallpapers
betterlockscreen --lock dim
```

### 5) Workspace-local PDF/image tabs.

`zathura-tabbed` and `sxiv-tabbed` use native i3 tabbed containers. 

Behavior per workspace:

- First opened PDF/image creates a dedicated tabbed container for PDFs/images in that workspace.
- Any subsequent PDF/image opened via `xdg-open` in that workspace is appended as a new tab in the matching container.
- Tab titles are normalized to basename-only (for example `paper.pdf`, `figure.png`).

### 6) Zen Browser

Zen is installed automatically by `install.sh` when using the desktop profile.
Expected install locations:
- `~/.tarball-installations/zen`
- `~/.local/bin/zen`

### 7) CUDA (optional)

Shell configs auto-detect `/usr/local/cuda-12.8` or `/usr/local/cuda` and update `PATH` / `LD_LIBRARY_PATH`.

## Machine-Local Overrides (Recommended)

Keep personal and machine-specific values in local files, not in this public repo:

- Git identity/settings: `~/.gitconfig.local` (included by `~/.gitconfig`)
- Fish local env vars/secrets: `~/.config/fish/local.fish` (sourced from `config.fish` if present)

Example for `~/.config/fish/local.fish`:

```fish
set -gx GOOGLE_VERTEX_PROJECT your-project-id
set -gx GOOGLE_VERTEX_LOCATION global
set -gx GOOGLE_APPLICATION_CREDENTIALS $HOME/.config/gcloud/application_default_credentials.json
```

`~/.config/fish/local.fish` is machine-local and intentionally not tracked in git.
