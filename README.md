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

```bash
sudo apt update
sudo apt install -y git curl software-properties-common
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
> [!NOTE]
> The bootstrap script is Ubuntu-first (uses `apt` + PPAs). On other Debian-based systems, run with `--skip-packages` and install equivalent packages manually.


What this does at a high level:

1. Installs system dependencies and PPAs.
2. Installs non-APT tools (`fzf`, `starship`, `zoxide`, `yazi`, `lazygit`, `opencode`, `zen-browser`, `betterlockscreen`).
3. Installs Python tooling and fonts.
4. Stows all configured packages into `$HOME`.
5. Configures default MIME handlers for PDFs/images (`zathura-tabbed.desktop`, `sxiv-tabbed.desktop`).
6. Applies the default wallpaper with `feh` when a graphical session is available.

Installer log:

- `~/dotfiles/install.log`

### 4) First login checks

1. Log out and back in (fish becomes default shell).
2. Open Neovim and run:
   - `:Lazy sync`
   - `:Mason`
   - `:checkhealth`

> [!IMPORTANT]
> The i3 config swaps `Caps Lock` and `Escape` (`setxkbmap -option caps:swapescape`). If you do not want this behavior, remove that line from `i3/.config/i3/config`.

> [!NOTE]
> If installer runs outside a GUI (`DISPLAY` not set), wallpaper application is skipped during install. i3 still sets the same wallpaper on session start.

## Installer Flags

| Flag | Meaning |
|---|---|
| `--skip-packages` | Skip all apt/PPA package installation |
| `--skip-tools` | Skip non-APT tools (`fzf`, `starship`, `zoxide`, `yazi`, `lazygit`, `opencode`, `zen-browser`, `betterlockscreen`) and Python tools |
| `--skip-fonts` | Skip Nerd Fonts + Font Awesome install |
| `--stow-only` | Only apply Stow packages |

Example:

```bash
./install.sh --skip-tools
```

## What `install.sh` Provisions

### Repositories added

- `ppa:neovim-ppa/unstable`
- `ppa:fish-shell/release-4`
- `ppa:aslatter/ppa`
- NodeSource LTS repo (if `node` is missing)

### APT packages (from `packages.txt`)

- Core: `git`, `stow`, `curl`, `wget`, `unzip`, `bc`, `build-essential`, `cmake`, `pkg-config`, `xdg-utils`
- Desktop: `i3-wm`, `i3lock`, `i3status`, `polybar`, `picom`, `rofi`, `dunst`, `flameshot`, `xdotool`, `x11-xserver-utils`, `x11-utils`, `dex`, `xss-lock`, `network-manager-gnome`, `pulseaudio-utils`, `imagemagick`
- CLI: `htop`, `neofetch`, `ripgrep`, `fd-find`, `bat`, `feh`, `jq`
- Docs/academic: `zathura`, `zathura-pdf-poppler`, `texlive-full`, `latexmk`
- Media/viewer: `sxiv`, `vlc`
- Python base: `python3`, `python3-pip`, `python3-venv`

Script-installed packages:

- `neovim`, `fish`, `alacritty`, `nodejs`, `qutebrowser`

### Non-APT installs

- `fzf` (git clone to `~/.fzf`)
- `starship` (official installer)
- `zoxide` (official installer)
- `yazi` + `ya` (GitHub release binary)
- `lazygit` (GitHub release binary)
- `opencode` (official installer from opencode.ai)
- `zen-browser` (official Linux tarball installer via curl script)
- `betterlockscreen` (official upstream installer)
- Yazi plugin sync via `ya pack -i`
- Python user tools: `ipython`, `jupytext`, `black`, `isort`, `pylint`
- MIME defaults via `xdg-mime`: `application/pdf` -> `zathura-tabbed.desktop`, images -> `sxiv-tabbed.desktop`
- Fonts: `JetBrainsMono`, `RobotoMono`, `NerdFontsSymbolsOnly`, `Font Awesome`

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
| `qutebrowser` | `~/.config/qutebrowser/` |
| `xdg-desktop-portal` | `~/.config/xdg-desktop-portal/portals.conf` |
| `xdg-desktop-portal-termfilechooser` | `~/.config/xdg-desktop-portal-termfilechooser/` |
| `latex` | `~/texmf/` (custom `.bst` files) |
| `scripts` | `~/.local/bin/rofi-power`, `~/.local/bin/zathura-tabbed`, `~/.local/bin/sxiv-tabbed`, `~/.local/bin/i3-tab-title-fix`, `~/.local/share/applications/{zathura-tabbed.desktop,sxiv-tabbed.desktop}` |
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

Debug notes:

- `xdg-desktop-portal-termfilechooser/.config/xdg-desktop-portal-termfilechooser/agents.md`

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

Quick checks:

```bash
xdg-mime query default application/pdf
xdg-mime query default image/png
```

Expected:

- `zathura-tabbed.desktop`
- `sxiv-tabbed.desktop`

### 6) Zen Browser

Zen is installed automatically by `install.sh` using the official Linux command from the [Zen docs](https://docs.zen-browser.app/guides/install-linux):

```bash
curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | $SHELL
```

Expected install locations:

- `~/.tarball-installations/zen`
- `~/.local/bin/zen`

Quick check:

```bash
command -v zen
```

### 7) CUDA (optional)

Shell configs auto-detect `/usr/local/cuda-12.8` or `/usr/local/cuda` and update `PATH` / `LD_LIBRARY_PATH`.

### 8) Firecrawl API key for OpenCode MCP (optional)

OpenCode is installed automatically and `opencode.json` is stowed from `opencode/`.
Runtime files (`package.json`, `bun.lock`, `node_modules/`) are intentionally machine-local and not stowed.

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

## Neovim External Tooling Notes

On first run, Mason auto-installs configured LSP/formatter/linter tools (for example: `pyright`, `texlab`, `tinymist`, `lua-language-server`, `stylua`, `prettier`, `shellcheck`, `markdownlint`).

System tools expected by the config include:

- `node/npm` (Markdown preview and JS tooling)
- `python3/pip` (`ipython`, notebook flow)
- `git`, `make`, C toolchain
- `lazygit`, `yazi`, `zathura`, `latexmk`, `qutebrowser`

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
