#!/usr/bin/env bash

github_latest_release_tag() {
    local repo=$1
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name"' | head -1 | cut -d'"' -f4
}

github_latest_release_tag_with_prefix() {
    local repo=$1
    local prefix=$2

    curl -fsSL "https://api.github.com/repos/${repo}/releases?per_page=100" \
        | grep '"tag_name"' \
        | cut -d'"' -f4 \
        | grep -F "$prefix" \
        | head -1
}

install_upstream_tools() {
    run_step "7-Zip install" install_7zip
    run_step "fzf install" install_fzf
    run_step "Starship install" install_starship
    run_step "Zoxide install" install_zoxide
    run_step "Yazi install" install_yazi
    run_step "Lazygit install" install_lazygit
    run_step "GitHub CLI install" install_gh
    run_step "OpenCode install" install_opencode
    run_step "Typst install" install_typst
}

install_7zip() {
    local version version_digits arch asset tmp_dir archive extract_dir install_dir

    version="$(github_latest_release_tag ip7z/7zip)"
    if [ -z "$version" ]; then
        error "Could not determine latest 7-Zip version. Install manually."
        return 1
    fi

    version_digits=${version//./}
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="7z${version_digits}-linux-x64.tar.xz"
            ;;
        aarch64|arm64)
            asset="7z${version_digits}-linux-arm64.tar.xz"
            ;;
        armv7l|armv6l|arm)
            asset="7z${version_digits}-linux-arm.tar.xz"
            ;;
        i686|i386)
            asset="7z${version_digits}-linux-x86.tar.xz"
            ;;
        *)
            error "Unsupported architecture for 7-Zip prebuilt archive: $arch"
            return 1
            ;;
    esac

    install_dir="$HOME/.local/opt/7zip"

    if [ -x "$install_dir/7zz" ]; then
        ensure_local_bin_dir || return 1
        ln -sfn "$install_dir/7zz" "$HOME/.local/bin/7zz" || return 1
        ln -sfn "$install_dir/7zz" "$HOME/.local/bin/7z" || return 1
        export PATH="$HOME/.local/bin:$PATH"
        log "7-Zip ${version} already installed at ~/.local/opt/7zip."
        return 0
    fi

    info "Installing 7-Zip ${version} from the official release archive..."
    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    extract_dir="$tmp_dir/extracted"

    if ! curl -fsSL "https://github.com/ip7z/7zip/releases/download/${version}/${asset}" -o "$archive"; then
        error "Failed to download 7-Zip archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$extract_dir" "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare 7-Zip install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xJf "$archive" -C "$extract_dir"; then
        error "Failed to extract 7-Zip archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ ! -x "$extract_dir/7zz" ]; then
        error "7-Zip archive did not contain the expected 7zz binary."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! replace_path "$extract_dir" "$install_dir"; then
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/7zz" "$HOME/.local/bin/7zz"; then
        error "Failed to link 7zz into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/7zz" "$HOME/.local/bin/7z"; then
        error "Failed to link 7z into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! "$HOME/.local/bin/7zz" --help >/dev/null 2>&1; then
        error "7-Zip installed but failed smoke test."
        rm -rf "$tmp_dir"
        return 1
    fi

    export PATH="$HOME/.local/bin:$PATH"
    rm -rf "$tmp_dir"
    log "7-Zip ${version} installed to ~/.local/opt/7zip."
}

ensure_local_bin_dir() {
    mkdir -p "$HOME/.local/bin"
}

link_cargo_binary() {
    local binary=$1
    local source_path="$HOME/.cargo/bin/$binary"

    [ -x "$source_path" ] || return 0

    ensure_local_bin_dir || return 1
    ln -sfn "$source_path" "$HOME/.local/bin/$binary"
}

install_rust_toolchain() {
    if ! command -v rustup &>/dev/null; then
        info "Installing rustup..."

        if ! curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain stable --no-modify-path; then
            error "Failed to install rustup."
            return 1
        fi
    fi

    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

    if ! rustup default stable >/dev/null 2>&1; then
        error "Failed to install or activate the stable Rust toolchain."
        return 1
    fi

    link_cargo_binary rustup || return 1
    link_cargo_binary cargo || return 1
    link_cargo_binary rustc || return 1

    log "Rust toolchain ready."
}

libclang_is_available() {
    local candidate

    for candidate in "${LIBCLANG_PATH:-}" /usr/lib /usr/lib64 /usr/lib/llvm*/lib; do
        [ -n "$candidate" ] || continue
        [ -d "$candidate" ] || continue

        if compgen -G "$candidate/libclang.so*" >/dev/null || compgen -G "$candidate/libclang-*.so*" >/dev/null; then
            export LIBCLANG_PATH="$candidate"
            return 0
        fi
    done

    return 1
}

ensure_tree_sitter_build_deps() {
    if libclang_is_available; then
        return 0
    fi

    if [ "$INSTALL_PACKAGES" = true ]; then
        info "Installing clang for tree-sitter CLI build support..."

        if ! install_pkg clang; then
            error "Failed to install clang, which provides libclang for tree-sitter CLI builds."
            return 1
        fi

        if libclang_is_available; then
            return 0
        fi
    fi

    error "tree-sitter CLI build requires libclang. Install clang and rerun the installer."
    return 1
}

install_tree_sitter_cli() {
    if command -v tree-sitter &>/dev/null; then
        warn "tree-sitter CLI already installed, skipping."
        return
    fi

    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

    if ! command -v cargo &>/dev/null; then
        if ! install_rust_toolchain; then
            error "Rust toolchain is required to install tree-sitter CLI."
            return 1
        fi
    fi

    if ! ensure_tree_sitter_build_deps; then
        return 1
    fi

    info "Installing tree-sitter CLI via cargo..."

    if ! cargo install --locked tree-sitter-cli; then
        error "Failed to install tree-sitter CLI."
        return 1
    fi

    link_cargo_binary tree-sitter || return 1

    if ! command -v tree-sitter &>/dev/null; then
        error "tree-sitter CLI installed but is not available on PATH."
        return 1
    fi

    log "tree-sitter CLI installed."
}

install_tailor_cli() {
    local repo="AaronErhardt/tuxedo-rs"
    local version src_dir tmp_dir

    if command -v tailor &>/dev/null; then
        warn "TUXEDO Tailor CLI already installed, skipping."
        return
    fi

    export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"

    if ! command -v cargo &>/dev/null; then
        if ! install_rust_toolchain; then
            error "Rust toolchain is required to install TUXEDO Tailor CLI."
            return 1
        fi
    fi

    version="$(github_latest_release_tag_with_prefix "$repo" "tailor-v")"
    if [ -z "$version" ]; then
        error "Could not determine the latest TUXEDO Tailor CLI release."
        return 1
    fi

    info "Installing TUXEDO Tailor CLI ${version#tailor-v} from source..."
    tmp_dir="$(mktemp -d)"
    src_dir="$tmp_dir/tuxedo-rs"

    if ! git clone --depth 1 --branch "$version" "https://github.com/${repo}.git" "$src_dir"; then
        error "Failed to clone TUXEDO Tailor CLI source."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! cargo install --locked --path "$src_dir/tailor_cli"; then
        error "Failed to build and install TUXEDO Tailor CLI."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! link_cargo_binary tailor; then
        error "Failed to link TUXEDO Tailor CLI into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"

    if ! "$HOME/.local/bin/tailor" --help >/dev/null 2>&1; then
        error "TUXEDO Tailor CLI installed but failed smoke test."
        return 1
    fi

    log "TUXEDO Tailor CLI ${version#tailor-v} installed from source."
}

install_tools() {
    run_step "TPM install" install_tpm
    case "$DISTRO_FAMILY" in
        debian|fedora)
            run_step "Clipboard install" install_clipboard
            ;;
    esac
    run_step "Rust toolchain install" install_rust_toolchain
    run_step "tree-sitter CLI install" install_tree_sitter_cli
    run_step "TUXEDO Tailor CLI install" install_tailor_cli
    run_step "Neovim install" install_neovim
    run_step "Julia install" install_julia

    if [ "$DISTRO_FAMILY" = "debian" ] || [ "$DISTRO_FAMILY" = "fedora" ]; then
        install_upstream_tools
        run_step "Sesh install" install_sesh_binary
    elif [ "$INSTALL_PACKAGES" = true ]; then
        info "Using pacman and an AUR helper for remaining Arch-managed CLI tools."
    else
        warn "Skipping remaining Arch-managed CLI tools because package installation was disabled."
    fi

    run_step "Python tool install" install_python_tools

    if [ "$1" = true ] && { [ "$DISTRO_FAMILY" = "debian" ] || [ "$DISTRO_FAMILY" = "fedora" ]; }; then
        run_step "Kitty install" install_kitty
        run_step "LocalSend install" install_localsend
        run_step "termfilechooser install" install_termfilechooser
        run_step "Zen Browser install" install_zen
    fi

    return 0
}

sync_neovim_plugins() {
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
    local managed_nvim="$HOME/.local/bin/nvim"
    local nvim_cmd="nvim"

    if [ -x "$managed_nvim" ]; then
        nvim_cmd="$managed_nvim"
    fi

    if [ "$nvim_cmd" = "nvim" ] && ! command -v nvim &>/dev/null; then
        warn "Neovim is not installed; skipping plugin sync."
        return 0
    fi

    if [ ! -f "$config_home/nvim/init.lua" ]; then
        warn "Neovim config not found in $config_home/nvim; skipping plugin sync."
        return 0
    fi

    info "Syncing Neovim plugins with lazy.nvim..."

    if ! "$nvim_cmd" --headless "+Lazy sync" +qa; then
        error "Failed to sync Neovim plugins."
        return 1
    fi

    info "Updating Mason registries..."

    if ! "$nvim_cmd" --headless "+MasonUpdate" +qa; then
        error "Failed to update Mason registries."
        return 1
    fi

    log "Neovim plugins synced and Mason registries updated."
}

termfilechooser_is_installed() {
    local binary_path="" dbus_service="" portal_file="" dbus_exec="" dbus_systemd_service="" systemd_unit="" candidate

    # Treat stale portal metadata as not installed, otherwise xdg-desktop-portal silently falls back to gtk.
    for candidate in \
        /usr/libexec/xdg-desktop-portal-termfilechooser \
        /usr/lib/xdg-desktop-portal-termfilechooser \
        /usr/local/libexec/xdg-desktop-portal-termfilechooser \
        /usr/local/lib/xdg-desktop-portal-termfilechooser
    do
        if [ -x "$candidate" ]; then
            binary_path="$candidate"
            break
        fi
    done

    for candidate in \
        /usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service \
        /usr/local/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service
    do
        if [ -f "$candidate" ]; then
            dbus_service="$candidate"
            break
        fi
    done

    for candidate in \
        /usr/share/xdg-desktop-portal/portals/termfilechooser.portal \
        /usr/local/share/xdg-desktop-portal/portals/termfilechooser.portal
    do
        if [ -f "$candidate" ]; then
            portal_file="$candidate"
            break
        fi
    done

    [ -n "$binary_path" ] || return 1
    [ -n "$dbus_service" ] || return 1
    [ -n "$portal_file" ] || return 1

    dbus_exec="$(awk -F= '$1 == "Exec" { print $2; exit }' "$dbus_service")"
    [ -n "$dbus_exec" ] || return 1
    [ -x "$dbus_exec" ] || return 1

    dbus_systemd_service="$(awk -F= '$1 == "SystemdService" { print $2; exit }' "$dbus_service")"
    if [ -n "$dbus_systemd_service" ]; then
        for candidate in \
            "/usr/lib/systemd/user/$dbus_systemd_service" \
            "/usr/local/lib/systemd/user/$dbus_systemd_service" \
            "/lib/systemd/user/$dbus_systemd_service"
        do
            if [ -f "$candidate" ]; then
                systemd_unit="$candidate"
                break
            fi
        done

        [ -n "$systemd_unit" ] || return 1
    fi
}

activate_termfilechooser() {
    local env_vars=(DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS I3SOCK PATH)

    if ! termfilechooser_is_installed; then
        return 0
    fi

    if ! command -v systemctl &>/dev/null; then
        warn "systemctl not found; relogin to activate xdg-desktop-portal-termfilechooser."
        return 0
    fi

    systemctl --user import-environment "${env_vars[@]}" &>/dev/null || true

    if command -v dbus-update-activation-environment &>/dev/null; then
        dbus-update-activation-environment --systemd "${env_vars[@]}" &>/dev/null || true
    fi

    systemctl --user daemon-reload &>/dev/null || true

    if systemctl --user restart xdg-desktop-portal-termfilechooser.service xdg-desktop-portal.service &>/dev/null; then
        log "xdg-desktop-portal-termfilechooser activated."
        return 0
    fi

    warn "Could not restart portal services from this shell. Relogin to activate xdg-desktop-portal-termfilechooser."
    return 0
}

install_neovim() {
    local latest_tag managed_bin link_bin current_tag
    managed_bin="$HOME/.local/opt/nvim/bin/nvim"
    link_bin="$HOME/.local/bin/nvim"
    latest_tag="$(github_latest_release_tag neovim/neovim)"

    if [ -z "$latest_tag" ]; then
        error "Failed to determine the latest Neovim release tag."
        return 1
    fi

    current_tag=""
    if [ -x "$managed_bin" ]; then
        current_tag="$($managed_bin --version 2>/dev/null | awk 'NR==1 { print $2 }')"
    fi

    if [ "$current_tag" = "$latest_tag" ]; then
        ensure_local_bin_dir || return 1

        if ! ln -sfn "$managed_bin" "$link_bin"; then
            error "Failed to link Neovim into ~/.local/bin."
            return 1
        fi

        export PATH="$HOME/.local/bin:$PATH"
        log "Neovim ${latest_tag} already installed at ~/.local/opt/nvim."
        return 0
    fi

    if [ -n "$current_tag" ]; then
        info "Updating Neovim from ${current_tag} to ${latest_tag} using the official release archive..."
    else
        info "Installing Neovim ${latest_tag} from the official release archive..."
    fi

    local arch asset
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="nvim-linux-x86_64.tar.gz"
            ;;
        aarch64|arm64)
            asset="nvim-linux-arm64.tar.gz"
            ;;
        *)
            error "Unsupported architecture for Neovim prebuilt archive: $arch"
            return
            ;;
    esac

    local tmp_dir archive extracted_dir install_dir
    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    extracted_dir="$tmp_dir/${asset%.tar.gz}"
    install_dir="$HOME/.local/opt/nvim"

    if ! curl -fsSL "https://github.com/neovim/neovim/releases/download/${latest_tag}/${asset}" -o "$archive"; then
        error "Failed to download Neovim archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        error "Failed to extract Neovim archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare Neovim install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$install_dir"

    if ! mv "$extracted_dir" "$install_dir"; then
        error "Failed to place Neovim under ~/.local/opt."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/bin/nvim" "$link_bin"; then
        error "Failed to link Neovim into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    export PATH="$HOME/.local/bin:$PATH"
    rm -rf "$tmp_dir"
    log "Neovim ${latest_tag} installed to ~/.local/opt/nvim."
}

install_fzf() {
    local fzf_dir="$HOME/.fzf"
    local fzf_bin="$fzf_dir/bin/fzf"

    if command -v fzf &>/dev/null || [ -x "$fzf_bin" ]; then
        if [ -x "$fzf_bin" ]; then
            ensure_local_bin_dir || return 1
            ln -sfn "$fzf_bin" "$HOME/.local/bin/fzf" || return 1
            export PATH="$HOME/.local/bin:$PATH"
        fi

        warn "fzf already installed, skipping."
        return
    fi

    if [ -d "$fzf_dir" ]; then
        if [ ! -f "$fzf_dir/install" ]; then
            error "Existing $fzf_dir is not a valid fzf checkout."
            return 1
        fi

        info "Completing existing fzf checkout at ~/.fzf..."
    else
        info "Installing fzf via git..."

        if ! git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"; then
            error "Failed to clone fzf."
            return 1
        fi
    fi

    if ! "$fzf_dir/install" --bin; then
        error "Failed to install fzf binaries."
        return 1
    fi

    if [ ! -x "$fzf_bin" ]; then
        error "fzf install completed but the expected binary was not found."
        return 1
    fi

    ensure_local_bin_dir || return 1
    if ! ln -sfn "$fzf_bin" "$HOME/.local/bin/fzf"; then
        error "Failed to link fzf into ~/.local/bin."
        return 1
    fi

    export PATH="$HOME/.local/bin:$PATH"

    log "fzf installed to ~/.fzf."
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        warn "TPM already installed at ~/.tmux/plugins/tpm, skipping."
        return
    fi

    info "Installing tmux plugin manager (TPM)..."

    if ! mkdir -p "$HOME/.tmux/plugins"; then
        error "Failed to create TPM directory."
        return 1
    fi

    if ! git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"; then
        error "Failed to clone TPM."
        return 1
    fi

    log "TPM installed."
}

install_starship() {
    if command -v starship &>/dev/null; then
        warn "Starship already installed, skipping."
        return
    fi

    info "Installing Starship prompt..."

    if ! curl -sS https://starship.rs/install.sh | sh -s -- -y; then
        error "Failed to install Starship."
        return 1
    fi

    log "Starship installed."
}

install_zoxide() {
    if command -v zoxide &>/dev/null; then
        warn "Zoxide already installed, skipping."
        return
    fi

    info "Installing Zoxide..."

    if ! curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh; then
        error "Failed to install Zoxide."
        return 1
    fi

    log "Zoxide installed."
}

install_yazi() {
    if command -v yazi &>/dev/null; then
        warn "Yazi already installed, skipping."
        return
    fi

    info "Installing Yazi..."
    local YAZI_VERSION arch asset YAZI_URL
    YAZI_VERSION=$(github_latest_release_tag sxyazi/yazi)
    if [ -z "$YAZI_VERSION" ]; then
        error "Could not determine latest Yazi version. Install manually."
        return 1
    fi

    arch=$(uname -m)
    case "$arch" in
        x86_64|amd64)
            asset="yazi-x86_64-unknown-linux-musl.zip"
            ;;
        aarch64|arm64)
            asset="yazi-aarch64-unknown-linux-musl.zip"
            ;;
        *)
            error "Unsupported architecture for Yazi prebuilt archive: $arch"
            return 1
            ;;
    esac

    YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/${asset}"
    local TMP_DIR
    TMP_DIR=$(mktemp -d)

    if ! curl -sL "$YAZI_URL" -o "$TMP_DIR/yazi.zip"; then
        error "Failed to download Yazi."
        rm -rf "$TMP_DIR"
        return 1
    fi

    if ! unzip -q "$TMP_DIR/yazi.zip" -d "$TMP_DIR"; then
        error "Failed to extract Yazi archive."
        rm -rf "$TMP_DIR"
        return 1
    fi

    if ! sudo mv "$TMP_DIR"/yazi-*/yazi /usr/local/bin/yazi; then
        error "Failed to install Yazi binary."
        rm -rf "$TMP_DIR"
        return 1
    fi

    if ! sudo mv "$TMP_DIR"/yazi-*/ya /usr/local/bin/ya; then
        error "Failed to install Yazi helper binary."
        rm -rf "$TMP_DIR"
        return 1
    fi

    rm -rf "$TMP_DIR"
    log "Yazi installed."
}

install_lazygit() {
    if command -v lazygit &>/dev/null; then
        warn "Lazygit already installed, skipping."
        return
    fi

    info "Installing Lazygit..."
    local LAZYGIT_VERSION
    LAZYGIT_VERSION=$(github_latest_release_tag jesseduffield/lazygit | sed 's/^v//')
    if [ -z "$LAZYGIT_VERSION" ]; then
        error "Could not determine latest Lazygit version. Install manually."
        return 1
    fi
    local TMP_DIR
    TMP_DIR=$(mktemp -d)

    if ! curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o "$TMP_DIR/lazygit.tar.gz"; then
        error "Failed to download Lazygit."
        rm -rf "$TMP_DIR"
        return 1
    fi

    if ! tar -xzf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR"; then
        error "Failed to extract Lazygit archive."
        rm -rf "$TMP_DIR"
        return 1
    fi

    if ! sudo mv "$TMP_DIR/lazygit" /usr/local/bin/lazygit; then
        error "Failed to install Lazygit binary."
        rm -rf "$TMP_DIR"
        return 1
    fi

    rm -rf "$TMP_DIR"
    log "Lazygit installed."
}

install_gh() {
    if command -v gh &>/dev/null; then
        warn "GitHub CLI already installed, skipping."
        return
    fi

    info "Installing GitHub CLI from official release archive..."

    local arch asset asset_arch version version_no_v tmp_dir archive extracted_dir install_dir
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset_arch="amd64"
            ;;
        aarch64|arm64)
            asset_arch="arm64"
            ;;
        *)
            error "Unsupported architecture for GitHub CLI prebuilt archive: $arch"
            return 1
            ;;
    esac

    version="$(github_latest_release_tag cli/cli)"
    if [ -z "$version" ]; then
        error "Could not determine latest GitHub CLI version. Install manually."
        return 1
    fi

    version_no_v="${version#v}"
    asset="gh_${version_no_v}_linux_${asset_arch}.tar.gz"

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    extracted_dir="$tmp_dir/gh_${version_no_v}_linux_${asset_arch}"
    install_dir="$HOME/.local/opt/gh"

    if ! curl -fsSL "https://github.com/cli/cli/releases/download/${version}/${asset}" -o "$archive"; then
        error "Failed to download GitHub CLI archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        error "Failed to extract GitHub CLI archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare GitHub CLI install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$install_dir"
    if ! mv "$extracted_dir" "$install_dir"; then
        error "Failed to place GitHub CLI under ~/.local/opt."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/bin/gh" "$HOME/.local/bin/gh"; then
        error "Failed to link GitHub CLI into ~/.local/bin."
        rm -rf "$tmp_dir" "$install_dir"
        return 1
    fi

    if ! "$HOME/.local/bin/gh" --version >/dev/null 2>&1; then
        error "GitHub CLI installed but failed smoke test."
        rm -rf "$tmp_dir" "$install_dir"
        rm -f "$HOME/.local/bin/gh"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "GitHub CLI installed to ~/.local/opt/gh."
}

install_kitty() {
    local install_dir app_dir config_dir desktop_file
    install_dir="$HOME/.local/kitty.app"
    app_dir="$HOME/.local/share/applications"
    config_dir="$HOME/.config"
    desktop_file="$app_dir/kitty.desktop"

    if [ ! -x "$install_dir/bin/kitty" ]; then
        if command -v kitty &>/dev/null; then
            warn "Kitty is already installed outside ~/.local/kitty.app; skipping upstream installer."
            return
        fi

        if ! command -v curl &>/dev/null; then
            error "curl is required to install Kitty."
            return 1
        fi

        info "Installing Kitty from the official upstream installer..."

        if ! curl -fsSL https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n; then
            error "Failed to install Kitty."
            return 1
        fi
    else
        info "Refreshing Kitty desktop integration..."
    fi

    if [ ! -x "$install_dir/bin/kitty" ] || [ ! -x "$install_dir/bin/kitten" ]; then
        error "Kitty installer completed but expected binaries were not found."
        return 1
    fi

    if ! mkdir -p "$HOME/.local/bin" "$app_dir" "$config_dir"; then
        error "Failed to prepare Kitty integration directories."
        return 1
    fi

    if ! ln -sfn "$install_dir/bin/kitty" "$HOME/.local/bin/kitty"; then
        error "Failed to link Kitty into ~/.local/bin."
        return 1
    fi

    if ! ln -sfn "$install_dir/bin/kitten" "$HOME/.local/bin/kitten"; then
        error "Failed to link kitten into ~/.local/bin."
        return 1
    fi

    if ! cp "$install_dir/share/applications/kitty.desktop" "$desktop_file"; then
        error "Failed to install kitty.desktop."
        return 1
    fi

    if ! sed -i "s|^Exec=kitty|Exec=$install_dir/bin/kitty|" "$desktop_file"; then
        error "Failed to patch kitty.desktop Exec path."
        return 1
    fi

    if ! sed -i "s|^Icon=kitty|Icon=$install_dir/share/icons/hicolor/256x256/apps/kitty.png|" "$desktop_file"; then
        error "Failed to patch kitty.desktop icon path."
        return 1
    fi

    if ! printf 'kitty.desktop\n' > "$config_dir/xdg-terminals.list"; then
        error "Failed to configure xdg-terminals.list for Kitty."
        return 1
    fi

    if ! "$HOME/.local/bin/kitty" --version >/dev/null 2>&1; then
        error "Kitty installed but failed smoke test."
        rm -f "$HOME/.local/bin/kitty" "$HOME/.local/bin/kitten"
        return 1
    fi

    log "Kitty installed to ~/.local/kitty.app."
}

install_sesh_binary() {
    if command -v sesh &>/dev/null; then
        warn "sesh already installed, skipping."
        return
    fi

    info "Installing sesh from official release archive..."

    local arch asset version tmp_dir archive install_dir
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="sesh_Linux_x86_64.tar.gz"
            ;;
        aarch64|arm64)
            asset="sesh_Linux_arm64.tar.gz"
            ;;
        *)
            error "Unsupported architecture for sesh prebuilt archive: $arch"
            return 1
            ;;
    esac

    version="$(github_latest_release_tag joshmedeski/sesh)"
    if [ -z "$version" ]; then
        error "Could not determine latest sesh version. Install manually."
        return 1
    fi

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    install_dir="$HOME/.local/opt/sesh"

    if ! curl -fsSL "https://github.com/joshmedeski/sesh/releases/download/${version}/${asset}" -o "$archive"; then
        error "Failed to download sesh archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$tmp_dir"; then
        error "Failed to extract sesh archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ ! -x "$tmp_dir/sesh" ]; then
        error "sesh archive did not contain the expected binary."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare sesh install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$install_dir"
    if ! mkdir -p "$install_dir"; then
        error "Failed to prepare sesh install directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! install -m 0755 "$tmp_dir/sesh" "$install_dir/sesh"; then
        error "Failed to install sesh binary."
        rm -rf "$tmp_dir" "$install_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/sesh" "$HOME/.local/bin/sesh"; then
        error "Failed to link sesh into ~/.local/bin."
        rm -rf "$tmp_dir" "$install_dir"
        return 1
    fi

    if ! "$HOME/.local/bin/sesh" --version >/dev/null 2>&1; then
        error "sesh installed but failed smoke test."
        rm -rf "$tmp_dir" "$install_dir"
        rm -f "$HOME/.local/bin/sesh"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "sesh installed to ~/.local/opt/sesh."
}

install_typst() {
    if command -v typst &>/dev/null; then
        warn "Typst already installed, skipping."
        return
    fi

    info "Installing Typst from official release archive..."

    local arch asset version tmp_dir archive extracted_dir install_dir
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="typst-x86_64-unknown-linux-musl.tar.xz"
            ;;
        aarch64|arm64)
            asset="typst-aarch64-unknown-linux-musl.tar.xz"
            ;;
        *)
            error "Unsupported architecture for Typst prebuilt archive: $arch"
            return 1
            ;;
    esac

    version="$(github_latest_release_tag typst/typst)"
    if [ -z "$version" ]; then
        error "Could not determine latest Typst version. Install manually."
        return 1
    fi

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    extracted_dir="$tmp_dir/${asset%.tar.xz}"
    install_dir="$HOME/.local/opt/typst"

    if ! curl -fsSL "https://github.com/typst/typst/releases/download/${version}/${asset}" -o "$archive"; then
        error "Failed to download Typst archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xJf "$archive" -C "$tmp_dir"; then
        error "Failed to extract Typst archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare Typst install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$install_dir"
    if ! mv "$extracted_dir" "$install_dir"; then
        error "Failed to place Typst under ~/.local/opt."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/typst" "$HOME/.local/bin/typst"; then
        error "Failed to link Typst into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "Typst installed to ~/.local/opt/typst."
}

install_julia() {
    if command -v julia &>/dev/null || command -v juliaup &>/dev/null || [ -x "$HOME/.juliaup/bin/julia" ] || [ -x "$HOME/.juliaup/bin/juliaup" ]; then
        warn "Julia/juliaup already installed, skipping."
        return
    fi

    info "Installing Julia via the official juliaup installer..."

    if ! (set -o pipefail; curl -fsSL https://install.julialang.org | sh -s -- --yes --add-to-path=no); then
        error "Failed to install Julia."
        return 1
    fi

    if [ ! -x "$HOME/.juliaup/bin/juliaup" ] || [ ! -x "$HOME/.juliaup/bin/julia" ]; then
        error "Julia installer completed but ~/.juliaup/bin is missing expected binaries."
        return 1
    fi

    if ! "$HOME/.juliaup/bin/julia" --version >/dev/null 2>&1; then
        error "Julia installed but failed smoke test."
        return 1
    fi

    log "Julia installed via juliaup."
}

install_clipboard() {
    if command -v cb &>/dev/null; then
        warn "Clipboard already installed, skipping."
        return
    fi

    info "Installing Clipboard from official release archive..."

    local arch asset version tmp_dir archive extracted_dir install_dir
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="clipboard-linux-amd64.zip"
            ;;
        aarch64|arm64)
            asset="clipboard-linux-arm64.zip"
            ;;
        *)
            error "Unsupported architecture for Clipboard prebuilt archive: $arch"
            return 1
            ;;
    esac

    version="$(github_latest_release_tag Slackadays/Clipboard)"
    if [ -z "$version" ]; then
        error "Could not determine latest Clipboard version. Install manually."
        return 1
    fi

    tmp_dir="$(mktemp -d)"
    archive="$tmp_dir/$asset"
    extracted_dir="$tmp_dir/clipboard"
    install_dir="$HOME/.local/opt/clipboard"

    if ! curl -fsSL "https://github.com/Slackadays/Clipboard/releases/download/${version}/${asset}" -o "$archive"; then
        error "Failed to download Clipboard archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$extracted_dir"; then
        error "Failed to prepare Clipboard extraction directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! unzip -q "$archive" -d "$extracted_dir"; then
        error "Failed to extract Clipboard archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare Clipboard install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$install_dir"
    if ! mv "$extracted_dir" "$install_dir"; then
        error "Failed to place Clipboard under ~/.local/opt."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! ln -sfn "$install_dir/bin/cb" "$HOME/.local/bin/cb"; then
        error "Failed to link Clipboard into ~/.local/bin."
        rm -rf "$tmp_dir" "$install_dir"
        return 1
    fi

    if ! "$HOME/.local/bin/cb" --help >/dev/null 2>&1; then
        error "Clipboard installed but failed smoke test. Check runtime libraries like ALSA."
        rm -rf "$tmp_dir" "$install_dir"
        rm -f "$HOME/.local/bin/cb"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "Clipboard installed to ~/.local/opt/clipboard."
}

install_termfilechooser() {
    local src_dir build_dir tmp_dir

    if termfilechooser_is_installed; then
        warn "xdg-desktop-portal-termfilechooser already installed, skipping build."
        return
    fi

    for cmd in git meson ninja sudo; do
        if ! command -v "$cmd" &>/dev/null; then
            error "Missing required command for xdg-desktop-portal-termfilechooser install: $cmd"
            return 1
        fi
    done

    info "Installing xdg-desktop-portal-termfilechooser from source..."
    tmp_dir="$(mktemp -d)"
    src_dir="$tmp_dir/xdg-desktop-portal-termfilechooser"
    build_dir="$src_dir/build"

    if ! git clone --depth 1 https://github.com/hunkyburrito/xdg-desktop-portal-termfilechooser.git "$src_dir"; then
        error "Failed to clone xdg-desktop-portal-termfilechooser."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! meson setup "$build_dir" "$src_dir" --prefix=/usr; then
        warn "meson setup failed; retrying without man page generation."
        rm -rf "$build_dir"
        if ! meson setup "$build_dir" "$src_dir" --prefix=/usr -Dman-pages=disabled; then
            error "Failed to configure xdg-desktop-portal-termfilechooser build."
            rm -rf "$tmp_dir"
            return 1
        fi
    fi

    if ! ninja -C "$build_dir"; then
        error "Failed to build xdg-desktop-portal-termfilechooser."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! sudo ninja -C "$build_dir" install; then
        error "Failed to install xdg-desktop-portal-termfilechooser."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "xdg-desktop-portal-termfilechooser installed."
}

install_zen() {
    if [ -x "$HOME/.local/bin/zen" ] || command -v zen &>/dev/null; then
        warn "Zen Browser already installed, skipping."
        return
    fi

    info "Installing Zen Browser..."

    if ! curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | bash; then
        error "Failed to install Zen Browser."
        return 1
    fi

    log "Zen Browser installed."
}

install_localsend() {
    local install_dir link_path current_tag latest_tag version_no_v arch asset url tmp_dir bundle_dir archive
    install_dir="$HOME/.local/opt/localsend"
    link_path="$HOME/.local/bin/localsend"
    latest_tag="$(github_latest_release_tag localsend/localsend)"

    if [ -z "$latest_tag" ]; then
        error "Failed to determine the latest LocalSend release tag."
        return 1
    fi

    if [ ! -x "$install_dir/localsend_app" ] && { [ -x "$link_path" ] || command -v localsend &>/dev/null; }; then
        warn "LocalSend is already installed outside ~/.local/opt/localsend; skipping upstream archive install."
        return 0
    fi

    current_tag=""
    if [ -f "$install_dir/.repo-version" ]; then
        current_tag="$(cat "$install_dir/.repo-version" 2>/dev/null || true)"
    fi

    if [ "$current_tag" = "$latest_tag" ] && [ -x "$install_dir/localsend_app" ]; then
        ensure_local_bin_dir || return 1

        if ! ln -sfn "$install_dir/localsend_app" "$link_path"; then
            error "Failed to link LocalSend into ~/.local/bin."
            return 1
        fi

        log "LocalSend ${latest_tag} already installed at ~/.local/opt/localsend."
        return 0
    fi

    version_no_v=${latest_tag#v}
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64)
            asset="LocalSend-${version_no_v}-linux-x86-64.tar.gz"
            ;;
        aarch64|arm64)
            asset="LocalSend-${version_no_v}-linux-arm-64.tar.gz"
            ;;
        *)
            error "Unsupported architecture for LocalSend archive: $arch"
            return 1
            ;;
    esac

    url="https://github.com/localsend/localsend/releases/download/${latest_tag}/${asset}"
    tmp_dir="$(mktemp -d)"
    bundle_dir="$tmp_dir/localsend"
    archive="$tmp_dir/localsend.tar.gz"

    if ! mkdir -p "$bundle_dir"; then
        error "Failed to prepare temporary LocalSend extraction directory."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! curl -fsSL "$url" -o "$archive"; then
        error "Failed to download LocalSend archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! tar -xzf "$archive" -C "$bundle_dir"; then
        error "Failed to extract LocalSend archive."
        rm -rf "$tmp_dir"
        return 1
    fi

    if [ ! -x "$bundle_dir/localsend_app" ]; then
        error "LocalSend archive did not contain the expected launcher."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"; then
        error "Failed to prepare LocalSend install directories."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! replace_path "$bundle_dir" "$install_dir"; then
        rm -rf "$tmp_dir"
        return 1
    fi

    printf '%s\n' "$latest_tag" > "$install_dir/.repo-version" || warn "Failed to write LocalSend version marker."

    if ! ln -sfn "$install_dir/localsend_app" "$link_path"; then
        error "Failed to link LocalSend into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"

    if [ ! -x "$link_path" ]; then
        error "LocalSend installed but is not available at ~/.local/bin/localsend."
        return 1
    fi

    log "LocalSend ${latest_tag} installed to ~/.local/opt/localsend."
}

install_opencode() {
    if command -v opencode &>/dev/null; then
        warn "OpenCode already installed, skipping."
        return
    fi

    info "Installing OpenCode..."

    if ! curl -fsSL https://opencode.ai/install | bash; then
        error "Failed to install OpenCode."
        return 1
    fi

    log "OpenCode installed."
}
