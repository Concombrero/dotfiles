#!/usr/bin/env bash

GTK_THEME_NAME="catppuccin-mocha-mauve-standard+default"
GTK_THEME_CURSOR_NAME="DMZ-White"
GTK_THEME_CURSOR_SIZE=16
GTK_THEME_FONT_NAME="JetBrainsMono Nerd Font 10"

cursor_theme_is_installed() {
    local theme_name=$1
    local candidate

    for candidate in \
        "$HOME/.icons/$theme_name" \
        "$HOME/.local/share/icons/$theme_name" \
        "$HOME/.local/share/themes/$theme_name" \
        "/usr/local/share/icons/$theme_name" \
        "/usr/share/icons/$theme_name"
    do
        [ -d "$candidate" ] && return 0
    done

    return 1
}

ensure_dmz_cursor_theme_name() {
    local alias_path fallback_name fallback_path
    local fallbacks=(Vanilla-DMZ Vanilla-DMZ-AA)

    if cursor_theme_is_installed "$GTK_THEME_CURSOR_NAME"; then
        return 0
    fi

    for fallback_name in "${fallbacks[@]}"; do
        for fallback_path in \
            "$HOME/.icons/$fallback_name" \
            "$HOME/.local/share/icons/$fallback_name" \
            "/usr/local/share/icons/$fallback_name" \
            "/usr/share/icons/$fallback_name"
        do
            [ -d "$fallback_path" ] || continue

            alias_path="$HOME/.icons/$GTK_THEME_CURSOR_NAME"
            if [ -e "$alias_path" ] && [ ! -L "$alias_path" ]; then
                error "Cannot create cursor alias at $alias_path because a non-symlink path already exists."
                return 1
            fi

            if ! mkdir -p "$HOME/.icons"; then
                error "Failed to prepare ~/.icons for the cursor alias."
                return 1
            fi

            ln -sfn "$fallback_path" "$alias_path" || {
                error "Failed to alias $GTK_THEME_CURSOR_NAME to $fallback_name."
                return 1
            }

            log "Aliased $GTK_THEME_CURSOR_NAME to $fallback_name for GTK cursor compatibility."
            return 0
        done
    done

    error "Cursor theme $GTK_THEME_CURSOR_NAME was not found after package installation."
    return 1
}

gtk_theme_is_installed() {
    local candidate

    for candidate in \
        "$HOME/.local/share/themes/$GTK_THEME_NAME" \
        "$HOME/.themes/$GTK_THEME_NAME" \
        "/usr/local/share/themes/$GTK_THEME_NAME" \
        "/usr/share/themes/$GTK_THEME_NAME"
    do
        [ -d "$candidate" ] && return 0
    done

    return 1
}

install_catppuccin_gtk_theme() {
    local latest_tag tmp_dir archive extract_dir theme_dir install_dir

    if gtk_theme_is_installed; then
        log "Catppuccin GTK theme is already available."
        return 0
    fi

    if [ "$DISTRO_FAMILY" != debian ]; then
        warn "Catppuccin GTK theme was not found after package installation."
        return 1
    fi

    latest_tag="$(github_latest_release_tag catppuccin/gtk)"
    if [ -z "$latest_tag" ]; then
        error "Failed to determine the latest Catppuccin GTK release tag."
        return 1
    fi

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/${GTK_THEME_NAME}.zip"
    extract_dir="$tmp_dir/extracted"
    theme_dir="$extract_dir/$GTK_THEME_NAME"
    install_dir="$HOME/.local/share/themes/$GTK_THEME_NAME"

    if ! mkdir -p "$extract_dir" "$HOME/.local/share/themes"; then
        error "Failed to prepare Catppuccin GTK theme directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! curl -fsSL "https://github.com/catppuccin/gtk/releases/download/${latest_tag}/${GTK_THEME_NAME}.zip" -o "$archive"; then
        error "Failed to download the Catppuccin GTK theme archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! unzip -q "$archive" -d "$extract_dir"; then
        error "Failed to extract the Catppuccin GTK theme archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ ! -f "$theme_dir/index.theme" ]; then
        error "Catppuccin GTK theme archive did not contain the expected theme directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! replace_path "$theme_dir" "$install_dir"; then
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "Catppuccin GTK theme installed to ~/.local/share/themes/$GTK_THEME_NAME."
}

run_gsettings() {
    local -a cmd=(gsettings "$@")

    if [ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ] && has_cmd dbus-launch; then
        cmd=(dbus-launch gsettings "$@")
    fi

    "${cmd[@]}"
}

configure_gtk_appearance() {
    local had_failure=false
    local file
    local gtk_files=(
        "$HOME/.gtkrc-2.0"
        "$HOME/.icons/default/index.theme"
        "$HOME/.config/gtk-3.0/settings.ini"
        "$HOME/.config/gtk-4.0/settings.ini"
    )

    for file in "${gtk_files[@]}"; do
        if [ ! -e "$file" ] && [ ! -L "$file" ]; then
            warn "GTK appearance config missing after stow: $file"
            had_failure=true
        fi
    done

    if ! gtk_theme_is_installed; then
        warn "GTK theme $GTK_THEME_NAME is not installed in a standard theme directory."
        had_failure=true
    fi

    if ! cursor_theme_is_installed "$GTK_THEME_CURSOR_NAME"; then
        warn "Cursor theme $GTK_THEME_CURSOR_NAME is not installed in a standard icon directory."
        had_failure=true
    fi

    if ! has_cmd gsettings; then
        warn "gsettings not found; skipping GNOME appearance configuration."
        had_failure=true
    else
        run_gsettings set org.gnome.desktop.interface color-scheme prefer-dark || {
            warn "Failed to set GNOME color-scheme to prefer-dark."
            had_failure=true
        }
        run_gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME_NAME" || {
            warn "Failed to set the GNOME GTK theme to $GTK_THEME_NAME."
            had_failure=true
        }
        run_gsettings set org.gnome.desktop.interface cursor-theme "$GTK_THEME_CURSOR_NAME" || {
            warn "Failed to set the GNOME cursor theme to $GTK_THEME_CURSOR_NAME."
            had_failure=true
        }
        run_gsettings set org.gnome.desktop.interface cursor-size "$GTK_THEME_CURSOR_SIZE" || {
            warn "Failed to set the GNOME cursor size to $GTK_THEME_CURSOR_SIZE."
            had_failure=true
        }
        run_gsettings set org.gnome.desktop.interface font-name "$GTK_THEME_FONT_NAME" || {
            warn "Failed to set the GNOME interface font to $GTK_THEME_FONT_NAME."
            had_failure=true
        }
    fi

    [ "$had_failure" = false ] || return 1
    log "GTK and GNOME appearance configured."
}

configure_default_terminal() {
    local had_failure=false

    if ! command -v kitty &>/dev/null; then
        warn "Kitty is not installed; skipping default terminal configuration."
        return 0
    fi

    if ! mkdir -p "$HOME/.config"; then
        error "Failed to prepare ~/.config for terminal preferences."
        return 1
    fi

    if ! printf 'kitty.desktop\n' > "$HOME/.config/xdg-terminals.list"; then
        warn "Failed to configure xdg-terminals.list for Kitty."
        had_failure=true
    fi

    if has_cmd gsettings; then
        run_gsettings set org.gnome.desktop.default-applications.terminal exec kitty || {
            warn "Failed to set the GNOME default terminal executable to Kitty."
            had_failure=true
        }
        run_gsettings set org.gnome.desktop.default-applications.terminal exec-arg -- || {
            warn "Failed to set the GNOME default terminal argument style for Kitty."
            had_failure=true
        }
    fi

    [ "$had_failure" = false ] || return 1
    log "Default terminal configured for Kitty."
}

sync_gtk4_theme_support() {
    local sync_script="$DOTFILES_DIR/scripts/.local/bin/sync-gtk4-theme"

    if [ ! -f "$sync_script" ]; then
        error "Missing GTK4 theme sync helper: $sync_script"
        return 1
    fi

    GTK_THEME_NAME="$GTK_THEME_NAME" "$sync_script"
}

install_fonts() {
    info "Installing Fonts..."
    local FONT_ROOT="/usr/local/share/fonts"
    local FONT_DIR="$FONT_ROOT/nerd-fonts"
    local FONT_AWESOME_DIR="$FONT_ROOT/fontawesome"
    local had_failure=false

    if ! sudo install -d -m 0755 "$FONT_DIR" "$FONT_AWESOME_DIR"; then
        error "Failed to create font directories under $FONT_ROOT"
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

        if ! sudo unzip -qo "$TMP_DIR/$font.zip" -d "$FONT_DIR" -x "LICENSE*" "README*"; then
            warn "Failed to extract font $font."
            had_failure=true
            rm -rf "$TMP_DIR"
            continue
        fi

        rm -rf "$TMP_DIR"
        log "Font $font installed."
    done

    if ls "$FONT_AWESOME_DIR"/*.otf >/dev/null 2>&1; then
        warn "Font Awesome already present, skipping."
    else
        info "Downloading Font Awesome..."
        local TMP_DIR FONT_AWESOME_VERSION FONT_AWESOME_ARCHIVE FONT_AWESOME_EXTRACT_DIR FONT_AWESOME_SOURCE_DIR
        TMP_DIR=$(mktemp -d)
        FONT_AWESOME_VERSION="7.2.0"
        FONT_AWESOME_ARCHIVE="$TMP_DIR/fontawesome.zip"
        FONT_AWESOME_EXTRACT_DIR="$TMP_DIR/extracted"
        FONT_AWESOME_SOURCE_DIR="$FONT_AWESOME_EXTRACT_DIR/fontawesome-free-${FONT_AWESOME_VERSION}-desktop/otfs"

        if ! curl -fsSL "https://github.com/FortAwesome/Font-Awesome/releases/download/${FONT_AWESOME_VERSION}/fontawesome-free-${FONT_AWESOME_VERSION}-desktop.zip" -o "$FONT_AWESOME_ARCHIVE"; then
            warn "Failed to download Font Awesome."
            had_failure=true
            rm -rf "$TMP_DIR"
        else
            mkdir -p "$FONT_AWESOME_EXTRACT_DIR"
            if ! unzip -q "$FONT_AWESOME_ARCHIVE" -d "$FONT_AWESOME_EXTRACT_DIR"; then
                warn "Failed to extract Font Awesome."
                had_failure=true
                rm -rf "$TMP_DIR"
            elif ! ls "$FONT_AWESOME_SOURCE_DIR"/*.otf >/dev/null 2>&1; then
                warn "Font Awesome archive did not contain the expected OTF files."
                had_failure=true
                rm -rf "$TMP_DIR"
            elif ! sudo install -m 0644 "$FONT_AWESOME_SOURCE_DIR"/*.otf "$FONT_AWESOME_DIR/"; then
                warn "Failed to install Font Awesome OTF files."
                had_failure=true
                rm -rf "$TMP_DIR"
            else
                rm -rf "$TMP_DIR"
                log "Font Awesome installed."
            fi
        fi
    fi

    # Update cache
    if command -v fc-cache &>/dev/null; then
        if sudo fc-cache -fv "$FONT_ROOT"; then
            log "Font cache rebuilt."
        else
            warn "Failed to rebuild font cache."
            had_failure=true
        fi
    fi

    if command -v fc-list &>/dev/null; then
        if fc-list | grep -qi "Font Awesome"; then
            log "Font Awesome is available to fontconfig."
        else
            warn "Font Awesome was not found in the fontconfig database."
            had_failure=true
        fi
    fi

    if [ "$had_failure" = true ]; then
        return 1
    fi
}

ensure_system_service() {
    local service=$1
    local force_enable=${2:-false}
    local current_dm_target current_dm_unit
    local -a enable_cmd=(enable)

    if ! has_cmd systemctl; then
        warn "systemctl not found; skipping system service setup for $service."
        return 1
    fi

    if ! sudo systemctl is-enabled --quiet "$service"; then
        if [ "$force_enable" = true ] && sudo test -L /etc/systemd/system/display-manager.service; then
            current_dm_target=$(sudo readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)
            current_dm_unit=$(basename "$current_dm_target")

            if [ -n "$current_dm_unit" ] && [ "$current_dm_unit" != "$service" ]; then
                info "Replacing existing display manager service: $current_dm_unit -> $service"
                sudo systemctl disable "$current_dm_unit" >/dev/null 2>&1 || true
            fi

            enable_cmd+=(--force)
        fi

        info "Enabling system service: $service"
        if ! sudo systemctl "${enable_cmd[@]}" "$service"; then
            warn "Failed to enable system service $service."
            return 1
        fi
    fi

    return 0
}

configure_arch_desktop_services() {
    [ "$DISTRO_FAMILY" = arch ] || return 0
    ensure_system_service sddm.service true
}

generate_sddm_background() {
    local wallpaper=$1
    local theme_dst=$2
    local image_cmd
    local tmp_dir
    local background_tmp

    if [ ! -f "$wallpaper" ]; then
        warn "Wallpaper not found at $wallpaper; SDDM will fall back to a plain dark background."
        return 0
    fi

    if has_cmd magick; then
        image_cmd=magick
    elif has_cmd convert; then
        image_cmd=convert
    else
        warn "ImageMagick not found; SDDM will fall back to a plain dark background."
        return 0
    fi

    tmp_dir=$(mktemp -d)
    background_tmp="$tmp_dir/background-blur.jpg"

    if ! "$image_cmd" "$wallpaper" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x24 "$background_tmp"; then
        warn "Failed to generate blurred SDDM background from wallpaper."
        rm -rf "$tmp_dir"
        return 0
    fi

    if ! sudo install -m 0644 "$background_tmp" "$theme_dst/background-blur.jpg"; then
        warn "Failed to install blurred SDDM background image."
        rm -rf "$tmp_dir"
        return 0
    fi

    rm -rf "$tmp_dir"
    log "Blurred SDDM background generated from wallpaper."
}

install_sddm_theme() {
    local theme_src="$DOTFILES_DIR/sddm/usr/share/sddm/themes/tagarchy"
    local theme_dst="/usr/share/sddm/themes/tagarchy"
    local conf_src="$DOTFILES_DIR/sddm/etc/sddm.conf.d/zz-tagarchy-theme.conf"
    local conf_dst="/etc/sddm.conf.d/zz-tagarchy-theme.conf"
    local xsetup_src="$DOTFILES_DIR/sddm/usr/local/share/sddm/scripts/tagarchy-xsetup"
    local xsetup_dst="/usr/local/share/sddm/scripts/tagarchy-xsetup"
    local wallpaper="$HOME/Pictures/Wallpapers/catppuccin_gyro.jpg"
    local repo_wallpaper="$DOTFILES_DIR/wallpapers/Pictures/Wallpapers/catppuccin_gyro.jpg"
    local system_cursor_alias="/usr/share/icons/$GTK_THEME_CURSOR_NAME"
    local fallback_name fallback_path cursor_alias_ready=false

    [ "$DISTRO_FAMILY" = arch ] || return 0

    if ! has_cmd sddm; then
        warn "SDDM is not installed; skipping Tagarchy theme install."
        return 0
    fi

    if [ ! -d "$theme_src" ] || [ ! -f "$conf_src" ] || [ ! -f "$xsetup_src" ]; then
        error "Missing tracked SDDM theme files under $DOTFILES_DIR/sddm."
        return 1
    fi

    info "Installing Tagarchy SDDM theme..."

    if ! sudo mkdir -p /usr/share/sddm/themes /etc/sddm.conf.d /usr/local/share/sddm/scripts; then
        error "Failed to create SDDM theme/config directories."
        return 1
    fi

    if [ ! -d "/usr/share/icons/$GTK_THEME_CURSOR_NAME" ]; then
        for fallback_name in Vanilla-DMZ Vanilla-DMZ-AA; do
            for fallback_path in \
                "/usr/share/icons/$fallback_name"
            do
                [ -d "$fallback_path" ] || continue

                # SDDM cannot use the per-user ~/.icons alias created for the desktop session.
                if sudo test -e "$system_cursor_alias" && ! sudo test -L "$system_cursor_alias"; then
                    error "Cannot create system cursor alias at $system_cursor_alias because a non-symlink path already exists."
                    return 1
                fi

                if ! sudo mkdir -p /usr/share/icons; then
                    error "Failed to prepare /usr/share/icons for the SDDM cursor alias."
                    return 1
                fi

                if ! sudo ln -sfn "$fallback_path" "$system_cursor_alias"; then
                    error "Failed to alias $GTK_THEME_CURSOR_NAME to $fallback_name for SDDM."
                    return 1
                fi

                log "Aliased $GTK_THEME_CURSOR_NAME to $fallback_name for SDDM cursor compatibility."
                cursor_alias_ready=true
                break 2
            done
        done

        if [ "$cursor_alias_ready" = false ]; then
            error "Cursor theme $GTK_THEME_CURSOR_NAME is not available system-wide for SDDM."
            return 1
        fi
    fi

    if ! sudo rm -rf "$theme_dst"; then
        error "Failed to replace existing Tagarchy SDDM theme directory."
        return 1
    fi

    if ! sudo cp -r "$theme_src" "$theme_dst"; then
        error "Failed to install Tagarchy SDDM theme files."
        return 1
    fi

    if ! sudo cp "$conf_src" "$conf_dst"; then
        error "Failed to install SDDM theme selection config."
        return 1
    fi

    if ! sudo install -m 755 "$xsetup_src" "$xsetup_dst"; then
        error "Failed to install the SDDM X11 setup script."
        return 1
    fi

    if [ ! -f "$wallpaper" ] && [ -f "$repo_wallpaper" ]; then
        wallpaper="$repo_wallpaper"
    fi

    generate_sddm_background "$wallpaper" "$theme_dst"

    log "Tagarchy SDDM theme installed."
}

install_i3lock_color() {
    local latest_tag current_tag tmp_dir archive extract_dir source_dir candidate
    local license_path="/usr/local/share/licenses/i3lock-color/LICENSE"

    [ "$DISTRO_FAMILY" = debian ] || return 0

    latest_tag="$(github_latest_release_tag Raymo111/i3lock-color)"
    if [ -z "$latest_tag" ]; then
        error "Failed to determine the latest i3lock-color release tag."
        return 1
    fi

    current_tag=""
    if [ -x /usr/local/bin/i3lock ]; then
        current_tag="$(/usr/local/bin/i3lock --version 2>/dev/null | awk 'NR==1 { print $3 }')"
    fi

    if [ "$current_tag" = "$latest_tag" ]; then
        log "i3lock-color ${latest_tag} is already installed at /usr/local/bin/i3lock."
        return 0
    fi

    info "Installing i3lock-color ${latest_tag} from source..."
    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/i3lock-color-${latest_tag}.tar.gz"
    extract_dir="$tmp_dir/extracted"

    if ! mkdir -p "$extract_dir"; then
        error "Failed to prepare the i3lock-color build directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! curl -fsSL "https://github.com/Raymo111/i3lock-color/archive/refs/tags/${latest_tag}.tar.gz" -o "$archive"; then
        error "Failed to download the i3lock-color source archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$extract_dir"; then
        error "Failed to extract the i3lock-color source archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    source_dir=""
    for candidate in "$extract_dir"/i3lock-color-*; do
        [ -d "$candidate" ] || continue
        source_dir="$candidate"
        break
    done

    if [ -z "$source_dir" ]; then
        error "The i3lock-color source archive did not contain the expected source directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! (
        cd "$source_dir" &&
        autoreconf -fiv &&
        mkdir -p build &&
        cd build &&
        # Install to /usr/local so the source build wins without replacing distro-managed files.
        ../configure --prefix=/usr/local --sysconfdir=/etc &&
        make &&
        sudo make install
    ); then
        error "Failed to build or install i3lock-color."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! sudo install -Dm644 "$source_dir/LICENSE" "$license_path"; then
        error "Failed to install the i3lock-color license file."
        rm -rf "$tmp_dir"
        return 1
    fi

    current_tag="$(/usr/local/bin/i3lock --version 2>/dev/null | awk 'NR==1 { print $3 }')"
    if [ "$current_tag" != "$latest_tag" ]; then
        error "i3lock-color installed but reported version '$current_tag' instead of '$latest_tag'."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "i3lock-color ${latest_tag} installed to /usr/local/bin/i3lock."
}

set_wallpaper() {
    local wallpaper="$HOME/Pictures/Wallpapers/catppuccin_gyro.jpg"
    local fehbg="$HOME/.fehbg"

    if [ ! -f "$wallpaper" ]; then
        warn "Wallpaper not found at $wallpaper"
        return
    fi

    if ! command -v feh &>/dev/null; then
        warn "feh not found; skipping wallpaper setup."
        return
    fi

    if ! mkdir -p "$(dirname "$fehbg")"; then
        warn "Failed to prepare wallpaper launcher directory."
        return 1
    fi

    if ! printf '#!/usr/bin/env sh\nfeh --no-fehbg --bg-fill "%s"\n' "$wallpaper" > "$fehbg"; then
        warn "Failed to write $fehbg."
        return 1
    fi

    chmod +x "$fehbg"

    if [ -z "${DISPLAY:-}" ]; then
        info "No DISPLAY detected; wallpaper launcher written to $fehbg and will apply on graphical login."
        return
    fi

    if "$fehbg"; then
        log "Wallpaper set via feh."
    else
        warn "Failed to set wallpaper."
        return 1
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

set_default_text_editor() {
    local had_failure=false
    local text_mimes=(
        text/english
        text/plain
        text/markdown
        text/x-r-markdown
        text/x-quarto-markdown
        text/x-changelog
        text/csv
        text/csv-schema
        text/tab-separated-values
        text/x-log
        text/x-python
        text/x-python3
        text/x-lua
        text/x-makefile
        text/x-c
        text/x-c++
        text/x-csrc
        text/x-c++src
        text/x-chdr
        text/x-c++hdr
        text/x-java
        text/x-tex
        text/x-texinfo
        text/x-dbus-service
        text/x-systemd-unit
        application/json
        application/ld+json
        application/geo+json
        application/jrd+json
        application/json-patch+json
        application/x-ipynb+json
        application/x-shellscript
        application/x-yaml
        application/raml+yaml
        application/sql
        application/x-desktop
    )

    if ! command -v nvim &>/dev/null; then
        warn "Neovim is not installed; skipping default text editor configuration."
        return 0
    fi

    if ! command -v kitty &>/dev/null; then
        warn "Kitty is not installed; skipping default text editor configuration."
        return 0
    fi

    if ! set_default_mime_handler nvim.desktop "${text_mimes[@]}"; then
        warn "Failed to fully configure Neovim as the default text editor."
        had_failure=true
    fi

    [ "$had_failure" = false ]
}

configure_mime() {
    info "Configuring MIME types..."
    local had_failure=false
    local pdf_mimes=(
        application/pdf
        application/x-pdf
        application/acrobat
        application/vnd.pdf
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

    if ! set_default_text_editor; then
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

    run_step "i3lock-color install" install_i3lock_color
    [ "$fonts_enabled" = true ] && run_step "font installation" install_fonts
    [ "$DISTRO_FAMILY" = arch ] && run_step "SDDM theme install" install_sddm_theme
    run_step "Catppuccin GTK theme install" install_catppuccin_gtk_theme
    run_step "DMZ cursor theme compatibility" ensure_dmz_cursor_theme_name
    run_step "GTK appearance configuration" configure_gtk_appearance
    run_step "default terminal configuration" configure_default_terminal
    run_step "GTK4/libadwaita theme sync" sync_gtk4_theme_support
    run_step "wallpaper setup" set_wallpaper
    run_step "MIME configuration" configure_mime
}
