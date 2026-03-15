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

ensure_system_service() {
    local service=$1
    local start_now=${2:-false}

    if ! has_cmd systemctl; then
        warn "systemctl not found; skipping system service setup for $service."
        return 1
    fi

    if ! sudo systemctl is-enabled --quiet "$service"; then
        info "Enabling system service: $service"
        if ! sudo systemctl enable "$service"; then
            warn "Failed to enable system service $service."
            return 1
        fi
    fi

    if [ "$start_now" = true ] && ! sudo systemctl is-active --quiet "$service"; then
        info "Starting system service: $service"
        if ! sudo systemctl start "$service"; then
            warn "Failed to start system service $service."
            return 1
        fi
    fi

    return 0
}

ensure_user_service() {
    local service=$1

    if ! has_cmd systemctl; then
        warn "systemctl not found; skipping user service setup for $service."
        return 1
    fi

    if ! systemctl --user is-enabled --quiet "$service" 2>/dev/null; then
        info "Enabling user service: $service"
        if ! systemctl --user enable "$service"; then
            warn "Failed to enable user service $service."
            return 1
        fi
    fi

    if ! systemctl --user is-active --quiet "$service" 2>/dev/null; then
        info "Starting user service: $service"
        if ! systemctl --user start "$service"; then
            warn "Failed to start user service $service."
            return 1
        fi
    fi

    return 0
}

configure_arch_desktop_services() {
    local had_failure=false
    local service

    [ "$DISTRO_FAMILY" = arch ] || return 0

    ensure_system_service NetworkManager.service true || had_failure=true
    ensure_system_service lightdm.service false || had_failure=true

    for service in pipewire.service pipewire-pulse.service wireplumber.service; do
        ensure_user_service "$service" || had_failure=true
    done

    [ "$had_failure" = false ]
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

set_default_mime_handler() {
    local desktop_entry=$1
    shift
    local mime_type
    local had_failure=false

    for mime_type in "$@"; do
        if ! xdg-mime default "$desktop_entry" "$mime_type"; then
            warn "Failed to set $desktop_entry as the default handler for $mime_type."
            had_failure=true
        fi
    done

    [ "$had_failure" = false ]
}

set_default_browser() {
    local had_failure=false
    local browser_mimes=(
        text/html
        text/xml
        application/xhtml+xml
        application/xml
        x-scheme-handler/http
        x-scheme-handler/https
        x-scheme-handler/ftp
    )

    if [ ! -x "$HOME/.local/bin/zen" ] && ! command -v zen &>/dev/null; then
        warn "Zen Browser is not installed; skipping default browser configuration."
        return 0
    fi

    if ! set_default_mime_handler zen.desktop "${browser_mimes[@]}"; then
        had_failure=true
    fi

    if command -v xdg-settings &>/dev/null; then
        if ! xdg-settings set default-web-browser zen.desktop; then
            warn "Failed to set Zen Browser as the desktop default web browser."
        fi
    fi

    [ "$had_failure" = false ]
}

set_default_file_manager() {
    if ! command -v yazi &>/dev/null; then
        warn "Yazi is not installed; skipping default file manager configuration."
        return 0
    fi

    set_default_mime_handler yazi.desktop inode/directory
}

configure_mime() {
    info "Configuring MIME types..."
    local had_failure=false
    local pdf_mimes=(
        application/pdf
        application/x-pdf
        application/acrobat
        applications/vnd.pdf
        text/pdf
        text/x-pdf
    )
    local image_mimes=(image/jpeg image/png image/gif image/bmp image/tiff image/webp)

    if ! command -v xdg-mime &>/dev/null; then
        warn "xdg-mime not found."
        return
    fi

    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi

    if ! set_default_mime_handler zathura-tabbed.desktop "${pdf_mimes[@]}"; then
        warn "Failed to fully configure Zathura as the default PDF handler."
        had_failure=true
    fi

    if ! set_default_mime_handler sxiv-tabbed.desktop "${image_mimes[@]}"; then
        warn "Failed to fully configure Sxiv as the default image handler."
        had_failure=true
    fi

    if ! set_default_browser; then
        warn "Failed to fully configure Zen Browser as the default browser."
        had_failure=true
    fi

    if ! set_default_file_manager; then
        warn "Failed to configure Yazi as the default file manager."
        had_failure=true
    fi

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
