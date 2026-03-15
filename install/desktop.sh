#!/usr/bin/env bash

install_fonts() {
    info "Installing Fonts..."
    local FONT_DIR="$HOME/.local/share/fonts"
    local had_failure=false

    if ! mkdir -p "$FONT_DIR"; then
        error "Failed to create font directory at $FONT_DIR"
        return 1
    fi

    local fonts=("JetBrainsMono" "RobotoMono" "NerdFontsSymbolsOnly")
    local NERD_FONT_VERSION="v3.3.0"

    for font in "${fonts[@]}"; do
        if ls "$FONT_DIR"/*"${font}"* &>/dev/null 2>&1; then
            warn "Font $font already present, skipping."
            continue
        fi
        info "Downloading Nerd Font: $font..."
        local TMP_DIR
        TMP_DIR=$(mktemp -d)

        if ! curl -sL "https://github.com/ryanoasis/nerd-fonts/releases/download/${NERD_FONT_VERSION}/${font}.zip" -o "$TMP_DIR/$font.zip"; then
            warn "Failed to download font $font."
            had_failure=true
            rm -rf "$TMP_DIR"
            continue
        fi

        if ! unzip -qo "$TMP_DIR/$font.zip" -d "$FONT_DIR" -x "LICENSE*" "README*"; then
            warn "Failed to extract font $font."
            had_failure=true
            rm -rf "$TMP_DIR"
            continue
        fi

        rm -rf "$TMP_DIR"
        log "Font $font installed."
    done

    # Update cache
    if command -v fc-cache &>/dev/null; then
        if fc-cache -fv; then
            log "Font cache rebuilt."
        else
            warn "Failed to rebuild font cache."
            had_failure=true
        fi
    fi

    if [ "$had_failure" = true ]; then
        return 1
    fi
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
        if feh --bg-fill "$wallpaper"; then
            log "Wallpaper set."
        else
            warn "Failed to set wallpaper."
            return 1
        fi
    fi
}

configure_mime() {
    info "Configuring MIME types..."
    local had_failure=false

    if ! command -v xdg-mime &>/dev/null; then
        warn "xdg-mime not found."
        return
    fi

    if ! xdg-mime default zathura-tabbed.desktop application/pdf; then
        warn "Failed to set the default PDF handler."
        had_failure=true
    fi
    
    local image_mimes=(image/jpeg image/png image/gif image/bmp image/tiff image/webp)
    for mime in "${image_mimes[@]}"; do
        if ! xdg-mime default sxiv-tabbed.desktop "$mime"; then
            warn "Failed to set the default handler for $mime."
            had_failure=true
        fi
    done

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi
    log "MIME types configured."

    if [ "$had_failure" = true ]; then
        return 1
    fi
}

install_desktop_extras() {
    local fonts_enabled=$1

    [ "$fonts_enabled" = true ] && run_step "font installation" install_fonts
    run_step "wallpaper setup" set_wallpaper
    run_step "MIME configuration" configure_mime
}
