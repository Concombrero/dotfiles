# Workstation Dotfiles
GNU Stow-managed dotfiles for a full Ubuntu/Debian or Arch-based + i3 workstation, with an experience mostly driven by the [i3](https://i3wm.org/) tiling window manager.

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
- Editing: `neovim` (see the [Neovim config README](nvim/.config/nvim/README.md) for details).
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
git clone https://github.com/Malik-Hacini/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Arch Linux:**

```bash
sudo pacman -Syu --needed git 
git clone https://github.com/Malik-Hacini/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

**Headless install:**
If you do not want the desktop profile (i3, polybar, fonts, wallpapers, Zen, etc.), run:

```bash
./install.sh --headless
```

> [!NOTE]
> The bootstrap installer supports **Ubuntu/Debian**, **Arch** and other Arch-based distros that use `pacman`.

> [!NOTE]
> On Arch/CachyOS desktop installs, the installer also provisions the SDDM login stack (`sddm`). VM guest helpers and any optional Archinstall-managed desktop services remain manual.

What this does at a high level:

1. **Detects OS:** Verifies the distro family and uses `apt` or `pacman` as appropriate.
2. **Installs Packages:** Core CLI packages and desktop packages (if not headless), using Arch-specific package lists when running on `pacman`.
3. **Installs Binaries:** Prefers official Arch packages for tools like `neovim`, `fzf`, `starship`, `zoxide`, `yazi`, `lazygit`, `opencode`, `typst`, and falls back to upstream installers where needed on Debian/Ubuntu (`zen-browser`, etc.). The desktop profile also builds `xdg-desktop-portal-termfilechooser` from upstream source.
4. **Installs Python Tools:** Uses `pipx` to safely install `ipython`, `black`, `isort`, etc.
5. **Configures System:** Adds fonts (optional), writes a persistent `feh` wallpaper launcher, sets the wallpaper when a graphical session is available, configures `xdg-open` defaults for PDFs/images/browser handlers, and on Arch enables `sddm.service` plus installs the Tagarchy SDDM theme.
6. **Stows Configs:** Enforces the tracked dotfiles into `$HOME`, backing up conflicting existing files to `~/dotfiles-stow-backup-...` when needed.

Installer log: `<repo>/install.log` (for the default clone path, `~/dotfiles/install.log`)

### First login checks

1. Log out and back in.
2. Open Neovim and run:
   - `:Mason`
   - `:checkhealth`

> [!NOTE]
> `install.sh` now runs a headless `:Lazy sync` automatically after stowing the Neovim config, so plugins like `nvim-treesitter` are present on first launch.

> [!NOTE]
> On Arch/CachyOS, the desktop install enables `sddm.service` automatically, replacing an existing `display-manager.service` symlink when a distro default like LightDM is already enabled, and installs a system-level `tagarchy` SDDM theme based on Omarchy's SDDM theme. NetworkManager, PipeWire, Bluetooth, and similar base services are left to the base install (for example via `archinstall`).

> [!NOTE]
> The desktop install writes `~/.fehbg` and uses it from i3 so the wallpaper persists across logins. The SDDM theme also generates a blurred background from `~/Pictures/Wallpapers/catppuccin_gyro.jpg` when ImageMagick is available.

> [!NOTE]
> On Debian/Ubuntu, `ueberzugpp` is installed from the upstream openSUSE Build Service apt repository recommended by the project README.

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
| `--skip-ppas` | Skip adding Ubuntu PPAs and Debian/Ubuntu external apt repos. |
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
- **Arch desktop extras:** `sddm`
- **Image helpers:** `imagemagick`, `ueberzugpp`

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

### Arch login manager theme
- `tagarchy` SDDM theme installed to `/usr/share/sddm/themes/tagarchy`
- theme selection config installed to `/etc/sddm.conf.d/zz-tagarchy-theme.conf`
- visual layout copied from Omarchy's SDDM theme, with the logo removed and renamed to Tagarchy
- blurred background generated from `~/Pictures/Wallpapers/catppuccin_gyro.jpg` when possible

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
