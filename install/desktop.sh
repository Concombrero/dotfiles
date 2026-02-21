#!/usr/bin/env bash

install_fonts() {
    info "Installing Fonts..."
    local FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    local fonts=("JetBrainsMono" "RobotoMono" "NerdFontsSymbolsOnly")
    local NERD_FONT_VERSION="v3.3.0"

    for font in "${fonts[@]}"; do
        if ls "$FONT_DIR"/*"${font}"* &>/dev/null 2>&1; then
            warn "Font $font already present, skipping."
            continue
        fi
        info "Downloading Nerd Font: $font..."
        local TMP_DIR=$(mktemp -d)
        curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${font}.zip" -o "$TMP_DIR/$font.zip"
        unzip -qo "$TMP_DIR/$font.zip" -d "$FONT_DIR" -x "LICENSE*" "README*"
        rm -rf "$TMP_DIR"
        log "Font $font installed."
    done

    # Update cache
    if command -v fc-cache &>/dev/null; then
        fc-cache -fv
        log "Font cache rebuilt."
    fi
}

install_alacritty_terminfo() {
    if infocmp alacritty >/dev/null 2>&1 && infocmp alacritty-direct >/dev/null 2>&1; then
        info "Alacritty terminfo already installed."
        return
    fi

    if ! command -v tic >/dev/null 2>&1; then
        warn "'tic' not found; skipping Alacritty terminfo installation."
        return
    fi

    info "Installing Alacritty terminfo entries..."

    local tmp_dir
    local terminfo_src
    tmp_dir=$(mktemp -d)
    terminfo_src="$tmp_dir/alacritty.info"

    if ! curl -fsSL "https://raw.githubusercontent.com/alacritty/alacritty/master/extra/alacritty.info" -o "$terminfo_src"; then
        warn "Failed to download alacritty.info; leaving TERM unchanged for now."
        rm -rf "$tmp_dir"
        return
    fi

    mkdir -p "$HOME/.terminfo"
    if tic -x -o "$HOME/.terminfo" -e alacritty,alacritty-direct "$terminfo_src"; then
        log "Installed Alacritty terminfo entries into ~/.terminfo"
    else
        warn "Failed to compile Alacritty terminfo entries."
    fi

    rm -rf "$tmp_dir"
}

set_wallpaper() {
    local wallpaper="$HOME/Pictures/Wallpapers/catppuccin_gyro.jpg"

    if [ ! -f "$wallpaper" ]; then
        warn "Wallpaper not found at $wallpaper"
        return
    fi

    if [ -z "${DISPLAY:-}" ]; then
        warn "No DISPLAY detected, skipping wallpaper application."
        return
    fi

    if command -v feh &>/dev/null; then
        feh --bg-fill "$wallpaper"
        log "Wallpaper set."
    fi
}

configure_mime() {
    info "Configuring MIME types..."
    if ! command -v xdg-mime &>/dev/null; then
        warn "xdg-mime not found."
        return
    fi

    xdg-mime default zathura-tabbed.desktop application/pdf
    
    local image_mimes=(image/jpeg image/png image/gif image/bmp image/tiff image/webp)
    for mime in "${image_mimes[@]}"; do
        xdg-mime default sxiv-tabbed.desktop "$mime"
    done

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi
    log "MIME types configured."
}

install_desktop_extras() {
    install_alacritty_terminfo
    install_fonts
    configure_mime
    set_wallpaper
}
