# Workstation Dotfiles
GNU Stow-managed dotfiles for a full Ubuntu (Gnome) + i3 (X11) workstation.

![Home screen](preview.png)
## System Overview

This repo is designed as one cohesive, keyboard-first environment rather than a loose set of config files.

The principles used for building this system are simple :

- Keyboard is King
- Distractions are evil
- Defaults are fine

This is all materialized through a set of tools that tries to stay minimal while providing a solid out of the box experience that can be easily extended and customized.


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
  - Enhancements : `lazygit`, `zoxide`, `fzf` and more
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

**Fedora:**
```bash
sudo dnf install -y git
```

**Arch:**
```bash
sudo pacman -S git
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
> The bootstrap script automatically detects your OS (Ubuntu, Debian, Fedora, Arch) and uses the appropriate package manager.

What this does at a high level:

1. **Detects OS:** Adapts to `apt`, `dnf`, or `pacman`.
2. **Installs Packages:** Core tools (`git`, `curl`, `stow`, `nvim`) and Desktop tools (if not headless).
3. **Installs Binaries:** `starship`, `zoxide`, `yazi`, `lazygit`, `fzf`, `opencode`, `zen-browser`.
4. **Installs Python Tools:** Uses `pipx` to safely install `ipython`, `black`, `isort`, etc.
5. **Configures System:** Sets `fish` as shell, adds fonts, sets wallpaper.
6. **Stows Configs:** Symlinks all dotfiles into `$HOME`.

Installer log: `~/dotfiles/install.log`

### 4) First login checks

1. Log out and back in (fish becomes default shell).
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
| `--skip-packages` | Skip system package installation (apt/dnf/pacman). |
| `--skip-tools` | Skip external tool installation (binaries like `starship`, `yazi`, etc.). |
| `--skip-fonts` | Skip Nerd Fonts installation. |
| `--skip-ppas` | Skip adding Ubuntu PPAs (useful for Debian Stable or non-Ubuntu based systems). |
| `--stow-only` | Only run stow (skip all installations). |

Example:

```bash
./install.sh --headless
```

## What `install.sh` Provisions

### Packages (via System Package Manager)
Defined in `packages/common.txt` and `packages/desktop.txt`.

- **Core:** `git`, `stow`, `curl`, `wget`, `unzip`, `bc`, `build-essential`, `cmake`, `python3`, `pipx`, `btop`
- **Desktop:** `i3-wm`, `polybar`, `picom`, `rofi`, `dunst`, `flameshot`, `alacritty`, `neofetch`, `zathura`, `sxiv`

### External Binaries (Architecture Independent)
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
| `neofetch` | `~/.config/neofetch/config.conf` |
| `htop` | `~/.config/htop/htoprc` |
| `btop` | `~/.config/btop/btop.conf` |
| `qutebrowser` | `~/.config/qutebrowser/` |
| `xdg-desktop-portal` | `~/.config/xdg-desktop-portal/portals.conf` |
| `xdg-desktop-portal-termfilechooser` | `~/.config/xdg-desktop-portal-termfilechooser/` |
| `latex` | `~/texmf/` (custom `.bst` files) |
| `scripts` | `~/.local/bin/` and `~/.local/share/applications/` |
| `wallpapers` | `~/Pictures/Wallpapers/` |
| `opencode` | `~/.config/opencode/opencode.json` |

## Manual Setup Checklist

These items are either manual setup or useful post-install checks.

### 1) `xdg-desktop-portal-termfilechooser` backend (for Yazi file picker)

The config is stowed, but backend binary install is manual:

```bash
sudo apt install -y meson ninja-build xdg-desktop-portal xdg-desktop-portal-gtk

git clone https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser.git /tmp/xdptf
cd /tmp/xdptf
meson setup build
ninja -C build
sudo ninja -C build install
```

Then relogin, or run:

```bash
systemctl --user import-environment
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

`polybar/.config/polybar/config.ini` currently assumes:

- Wi-Fi interface: `wlo1`
- Battery: `BAT0`
- AC adapter: `ADP1`

Adjust if your system uses different names.

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

### 8) Firecrawl API key for OpenCode MCP (optional)

OpenCode is installed automatically and `opencode.json` is stowed from `opencode/`.
If you use Firecrawl MCP:

```bash
mkdir -p ~/.config/opencode
printf '%s' 'fc-your-key-here' > ~/.config/opencode/firecrawl_api_key
chmod 600 ~/.config/opencode/firecrawl_api_key
```

### 9) Vertex AI environment for OpenCode (optional)

`fish/.config/fish/config.fish` exports:

- `GOOGLE_CLOUD_PROJECT`
- `GOOGLE_APPLICATION_CREDENTIALS`
- `VERTEX_LOCATION`

Set values for your own project, or remove/comment if unused.

### 10) Zotero bibliography (optional)

Neovim bibliography tooling expects:
- `~/texmf/bibtex/bib/Zotero.bib`

## Day-2 Operations

```bash
cd ~/dotfiles
stow -D <package>   # remove symlinks for one package
stow -R <package>   # restow one package
```

Add a new Stow package:

```bash
mkdir -p ~/dotfiles/newpkg/.config/newpkg
cp ~/.config/newpkg/config.toml ~/dotfiles/newpkg/.config/newpkg/
cd ~/dotfiles
stow newpkg
```

The folder structure inside each package must match paths relative to `$HOME`.
