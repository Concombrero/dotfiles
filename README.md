# Workstation Dotfiles
GNU Stow-managed dotfiles for a full Ubuntu/Debian or Arch-based + i3 workstation, with X11 as the primary session model.

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
    - Lockscreen : `i3lock`
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

### Quick start

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install -y git
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Arch / CachyOS:**
```bash
sudo pacman -Syu --needed git
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Headless install:**
If you do not want the desktop profile (i3, polybar, fonts, wallpapers, Zen, etc.), run:

```bash
./install.sh --headless
```

> [!NOTE]
> The bootstrap installer supports **Ubuntu/Debian**, **Arch**, **CachyOS**, and other Arch-based distros that use `pacman`.

> [!NOTE]
> On a minimal Arch install, the desktop profile still expects an existing X11 login stack before first graphical login (for example `lightdm`, `lightdm-gtk-greeter`, and `mesa`).

What this does at a high level:

1. **Detects OS:** Verifies the distro family and uses `apt` or `pacman` as appropriate.
2. **Installs Packages:** Core CLI packages and desktop packages (if not headless), using Arch-specific package lists when running on `pacman`.
3. **Installs Binaries:** Prefers official Arch packages for tools like `neovim`, `fzf`, `starship`, `zoxide`, `yazi`, `lazygit`, `opencode`, `typst`, and falls back to upstream installers where needed on Debian/Ubuntu (`zen-browser`, etc.). The desktop profile also builds `xdg-desktop-portal-termfilechooser` from upstream source.
4. **Installs Python Tools:** Uses `pipx` to safely install `ipython`, `black`, `isort`, etc.
5. **Configures System:** Adds fonts (optional), sets wallpaper, and configures `xdg-open` defaults for PDFs/images/browser handlers.
6. **Stows Configs:** Enforces the tracked dotfiles into `$HOME`, backing up conflicting existing files to `~/dotfiles-stow-backup-...` when needed.

Installer log: `<repo>/install.log` (for the default clone path, `~/dotfiles/install.log`)

### First login checks

1. Log out and back in.
2. Open Neovim and run:
   - `:Lazy sync`
   - `:Mason`
   - `:checkhealth`

> [!NOTE]
> On fresh Arch installs, `nm-applet` expects `NetworkManager.service` to be enabled, and the volume bindings expect a PulseAudio-compatible service that provides `pactl` (PulseAudio itself or PipeWire with `pipewire-pulse`).

> [!IMPORTANT]
> The i3 config swaps `Caps Lock` and `Escape` (`setxkbmap -option caps:swapescape`). If you do not want this behavior, remove that line from `i3/.config/i3/config`.

> [!NOTE]
> The installer force-restows packages by default. If an existing file in `$HOME` conflicts with a tracked dotfile, it is moved to `~/dotfiles-stow-backup-...` and the repo version is stowed in its place.

## Installer Flags

| Flag | Meaning |
|---|---|
| `--headless`, `--no-gui` | Skip desktop/GUI packages (i3, polybar, fonts, wallpapers, Zen browser). |
| `--skip-packages` | Skip system package installation (`apt`/`pacman`). |
| `--skip-tools` | Skip external tool installation (binaries like `starship`, `yazi`, `typst`, etc.). |
| `--skip-fonts` | Skip Nerd Fonts installation. |
| `--skip-ppas` | Skip adding Ubuntu PPAs (Debian skips PPAs automatically). |
| `--stow-only` | Only run stow (skip all installations). |

Example:

```bash
./install.sh --headless
```

## What `install.sh` Provisions

### Packages (via System Package Manager)
Defined in distro-specific package lists:

- Debian/Ubuntu: `packages/common.txt` and `packages/desktop.txt`
- Arch-based: `packages/common.arch.txt` and `packages/desktop.arch.txt`

- **Core:** `git`, `stow`, `tmux`, `curl`, `wget`, `unzip`, `bc`, compiler/build tooling, `python`, `nodejs`, `npm`, `btop`
- **Desktop:** `i3-wm`, `polybar`, `picom`, `rofi`, `dunst`, `flameshot`, `alacritty`, `fastfetch`, `zathura`, `sxiv`, `qutebrowser`

### External Tools/Binaries
- `neovim` (official prebuilt archive on Debian/Ubuntu; official Arch package on `pacman` systems)
- `fzf` (git clone to `~/.fzf` on Debian/Ubuntu; official Arch package on `pacman` systems)
- `starship` (official installer on Debian/Ubuntu; official Arch package on `pacman` systems)
- `zoxide` (official installer on Debian/Ubuntu; official Arch package on `pacman` systems)
- `yazi` + `ya` (GitHub release binary on Debian/Ubuntu; official Arch package on `pacman` systems)
- `lazygit` (GitHub release binary on Debian/Ubuntu; official Arch package on `pacman` systems)
- `opencode` (official installer on Debian/Ubuntu; official Arch package on `pacman` systems)
- `typst` (official Typst release archive on Debian/Ubuntu; official Arch package on `pacman` systems)
- `zen-browser` (official installer)
- `xdg-desktop-portal-termfilechooser` (built from upstream source on desktop installs)

### Python Tools (via pipx)
Installed in isolated environments to avoid breaking system Python:
- `ipython`, `jupytext`, `black`, `isort`, `pylint`

### Default `xdg-open` handlers
- `zathura-tabbed.desktop` for PDF and common PDF-like MIME aliases
- `sxiv-tabbed.desktop` for common image MIME types
- `zen.desktop` for HTML/XML documents and `http`/`https`/`ftp` URL schemes
- `yazi.desktop` for directory opens (`inode/directory`)

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
| `x11` | `~/.xprofile` |
| `gtk` | `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/` |

> [!NOTE]
> Use `bash scripts/.local/bin/force-stow-dotfiles` any time you want to re-apply the repo aggressively after a distro installer or another tool has recreated config files under `$HOME`.

## Manual Setup Checklist

These items are still machine-specific or useful post-install checks.

### 1) Machine-specific monitor config

Create `~/.config/i3/local.conf` for monitor/layout overrides:

```bash
cat > ~/.config/i3/local.conf << 'EOF'
# Example
exec --no-startup-id xrandr --output eDP-1 --off --output HDMI-1 --auto
EOF
```

### 2) Polybar hardware names

`polybar/.config/polybar/config.ini` uses auto-detection by default:

- Wireless interface is auto-detected in `polybar/.config/polybar/launch_polybar.sh` and exported as `POLYBAR_WLAN_INTERFACE`.
- Battery/AC names are auto-detected in `polybar/.config/polybar/launch_polybar.sh` and exported as `POLYBAR_BATTERY`/`POLYBAR_ADAPTER`.

If needed, you can still override manually via environment variables before launching polybar.

### 3) Workspace-local PDF/image tabs.

`zathura-tabbed` and `sxiv-tabbed` use native i3 tabbed containers. 

Behavior per workspace:

- First opened PDF/image creates a dedicated tabbed container for PDFs/images in that workspace.
- Any subsequent PDF/image opened via `xdg-open` in that workspace is appended as a new tab in the matching container.
- Tab titles are normalized to basename-only (for example `paper.pdf`, `figure.png`).

### 4) CUDA (optional)

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
