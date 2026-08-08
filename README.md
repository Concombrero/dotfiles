# Workstation Dotfiles
GNU Stow-managed dotfiles for a full Ubuntu/Debian, Fedora, or Arch-based workstation, with an experience mostly driven by the [i3](https://i3wm.org/) tiling window manager.

![Home screen](preview.png)
## System Overview

This repo is designed as one cohesive, keyboard-first environment you can apply on a fresh machine to immediately bootsrap a fully functional system.

The principles used for building this system are simple :

- Keyboard is King
- Distractions are evil
- Defaults are fine

This is all materialized through a set of tools that tries to stay minimal while providing a solid out of the box experience that can be easily extended and customized.
Visually, anything that can be uses the `JetBrainsMono` font and follows a [Solarized Light](https://ethanschoonover.com/solarized/) palette, with `SolArc` handling GTK theming.
The X11 session and SDDM greeter use the French AZERTY layout. Caps Lock acts as Escape without remapping the physical Escape key, and normal Kitty/Neovim text uses a black foreground.


- Desktop/Window management:
    - Tiling WM : `i3` 
    - Compositor : `picom`
    - Status bar : `polybar` 
    - App launcher / Menu : `rofi`
    - Notifications : `dunst`
    - Lockscreen : `i3lock-color`
    - File Manager : `yazi` 
    - Password Manager : `rofi-rbw` with Bitwarden via `rbw`
- Command Line Interface : 
  - Terminal emulator : `kitty`
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

**Fedora:**
```bash
sudo dnf install -y git
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

> [!WARNING]
> Do not run `./install.sh` with `sudo` or as `root`.
> The installer performs user-scoped setup under `$HOME` and runs commands that must execute in the real user session.
> Run it as your normal user account with sudo access; the script will call `sudo` itself only for the system-level steps that need it.

> [!NOTE]
> The installer force-restows packages by default. If an existing file in `$HOME` conflicts with a tracked dotfile, it is moved to `~/dotfiles-stow-backup-...` and the repo version is stowed in its place.

Installer log: `<repo>/install.log` (for the default clone path, `~/dotfiles/install.log`)

### First login checks

1. Open the keybindings cheatsheet with `Super + /`
2. Configure `rbw` for Bitwarden using the setup below.
3. Open Neovim and run `:checkhealth`
4. Launch Zen once so it creates `~/.zen/<profile>/`, then move `~/.config/zen/chrome/` into that profile directory.
5. If you use Julia in Neovim, bootstrap the local Julia LSP environment once:

```bash
# Stable Julia LSP bootstrap for the dedicated Neovim LanguageServer environment.
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add("LanguageServer"); Pkg.add("SymbolServer"); Pkg.add("StaticLint"); Pkg.instantiate()'

# Julia 1.12+ fallback: use newer upstream branches if released packages fail.
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add(PackageSpec(name="LanguageServer", rev="main")); Pkg.add(PackageSpec(name="SymbolServer", rev="master")); Pkg.add(PackageSpec(name="StaticLint", rev="master")); Pkg.instantiate(); Pkg.precompile()'
```

### Bitwarden and rofi-rbw setup

Account details and API credentials remain machine-local. Configure your Bitwarden email, register the device, and download the vault from a terminal:

```bash
rbw config set email "you@example.com"
rbw config set pinentry pinentry-gnome3
rbw register
rbw sync
```

For the official Bitwarden service, `rbw register` requests the personal API key available in the Bitwarden web vault under **Settings > Security > Keys**. For a self-hosted server, set its URL before registration:

```bash
rbw config set base_url "https://bitwarden.example.com"
```

Press `Super + b` from a login field to open the vault. `Enter` types the username, presses `Tab`, and types the password. The menu also provides `Alt + c` to copy only the password, `Alt + u` to copy the username, `Alt + t` to copy a TOTP, `Alt + m` to choose another field/action, and `Alt + s` to sync. Passwords copied through the launcher are cleared from the clipboard after 30 seconds.

## What `install.sh` Provisions

### Packages
Defined in distro-specific package lists:

- Debian/Ubuntu: `packages/common.txt` and `packages/desktop.txt`
- Fedora: `packages/common.fedora.txt` and `packages/desktop.fedora.txt`
- Arch-based: `packages/common.arch.txt` and `packages/desktop.arch.txt`
- Arch AUR: `packages/common.aur.arch.txt` and `packages/desktop.aur.arch.txt`

Package manager installs are preferred whenever they ship the latest version. Debian/Ubuntu and Fedora still rely on a few upstream binaries and source builds where repo packages lag or are missing. Arch remains the closest path to an all-package-managed install.

### Arch/Fedora login manager theme
- `tagarchy` SDDM theme installed to `/usr/share/sddm/themes/tagarchy`
- theme selection config installed to `/etc/sddm.conf.d/zz-tagarchy-theme.conf` 
- custom X11 display setup script installed to `/usr/local/share/sddm/scripts/tagarchy-xsetup` to seed `Xcursor.theme` and `Xcursor.size` before the Qt6 greeter starts
- blurred background generated from `~/Pictures/Wallpapers/wallpaper.jpg`

### Python Tools (via pipx)
Installed in isolated environments to avoid breaking system Python:
- `ipython`, `jupytext`, `black`, `isort`, `pylint`
- `rofi-rbw` on desktop installs

### Source-built CLI tools
- TUXEDO Tailor CLI (`tailor`) from [`AaronErhardt/tuxedo-rs`](https://github.com/AaronErhardt/tuxedo-rs)
- `rbw` on Debian/Ubuntu and Fedora, where distro versions may be unavailable or older than `rofi-rbw` requires

### Default `xdg-open` handlers
- `zathura-tabbed.desktop` for PDF and common PDF-like MIME aliases
- `sxiv-tabbed.desktop` for common image MIME types
- `zen.desktop` for HTML/XML documents and `http`/`https`/`ftp` URL schemes
- `yazi.desktop` for directory opens (`inode/directory`)

### Fonts
All fonts are installed under `/usr/local/share/fonts/`
- `JetBrainsMono Nerd Font`
- `RobotoMono Nerd Font`
- `NerdFontsSymbolsOnly`
- `Font Awesome`

### GTK / GNOME  apps appearance
All GNOME and GTK apps are themed using SolArc plus Solarized Light overrides. This includes GTK2/GTK3/GTK4/libadwaita apps and a workaround for sandboxed apps (flatpaks)

### Zen Browser CSS
- source of truth: `zen/.config/zen/chrome/`
- stowed to `~/.config/zen/chrome/`
- includes Solarized Light Zen Browser assets
- after Zen creates a profile, move that `chrome/` directory into `~/.zen/<profile>/`

## Stow 
The installer stows config files for every package included in the repo.

Use `bash scripts/.local/bin/force-stow-dotfiles` any time you want to re-apply the repo aggressively after a distro installer or another tool has recreated config files under `$HOME`.

## Installer Flags

| Flag | Meaning |
|---|---|
| `--headless`, `--no-gui` | Skip desktop/GUI packages (i3, polybar, fonts, wallpapers, Zen browser). |
| `--skip-packages` | Skip system package installation (`apt`/`dnf`/`pacman`). |
| `--skip-tools` | Skip external tool installation (binaries like `starship`, `yazi`, `typst`, etc.). |
| `--skip-fonts` | Skip Nerd Fonts installation. |
| `--skip-ppas` | Skip adding Ubuntu PPAs and Debian/Ubuntu external apt repos. |
| `--stow-only` | Only run stow (skip all installations). |

## Machine-Local Overrides

Keep personal and machine-specific values in local files, not in the tracked files of this repo:

- Git identity/settings: `~/.gitconfig.local` 
- Fish local env vars/secrets: `~/.config/fish/local.fish`
- Local i3 config (monitor setup, power management...) : `.config/i3/local.conf` 

These files are automatically included in the main configs if present.
