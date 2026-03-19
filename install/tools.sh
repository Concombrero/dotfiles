#!/usr/bin/env bash

github_latest_release_tag() {
    local repo=$1
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name"' | head -1 | cut -d'"' -f4
}

install_upstream_tools() {
    run_step "Neovim install" install_neovim
    run_step "fzf install" install_fzf
    run_step "Starship install" install_starship
    run_step "Zoxide install" install_zoxide
    run_step "Yazi install" install_yazi
    run_step "Lazygit install" install_lazygit
    run_step "GitHub CLI install" install_gh
    run_step "OpenCode install" install_opencode
    run_step "Typst install" install_typst
}

install_tools() {
    run_step "TPM install" install_tpm
    run_step "Clipboard install" install_clipboard

    if [ "$DISTRO_FAMILY" = "debian" ]; then
        install_upstream_tools
    elif [ "$INSTALL_PACKAGES" = true ]; then
        info "Using pacman packages for Arch-managed CLI tools."
    else
        warn "Skipping Arch-managed CLI tools because package installation was disabled."
    fi

    run_step "Python tool install" install_python_tools

    if [ "$1" = true ]; then
        run_step "termfilechooser install" install_termfilechooser
        run_step "Zen Browser install" install_zen
    fi
}

sync_neovim_plugins() {
    local config_home="${XDG_CONFIG_HOME:-$HOME/.config}"

    if ! command -v nvim &>/dev/null; then
        warn "Neovim is not installed; skipping plugin sync."
        return 0
    fi

    if [ ! -f "$config_home/nvim/init.lua" ]; then
        warn "Neovim config not found in $config_home/nvim; skipping plugin sync."
        return 0
    fi

    info "Syncing Neovim plugins with lazy.nvim..."

    if ! nvim --headless "+Lazy sync" +qa; then
        error "Failed to sync Neovim plugins."
        return 1
    fi

    log "Neovim plugins synced."
}

termfilechooser_is_installed() {
    [ -x /usr/libexec/xdg-desktop-portal-termfilechooser ] || [ -x /usr/lib/xdg-desktop-portal-termfilechooser ] || return 1
    [ -f /usr/share/dbus-1/services/org.freedesktop.impl.portal.desktop.termfilechooser.service ] || return 1
    [ -f /usr/share/xdg-desktop-portal/portals/termfilechooser.portal ] || return 1
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
    if command -v nvim &>/dev/null; then
        warn "Neovim already installed, skipping."
        return
    fi

    info "Installing Neovim from official release archive..."

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

    if ! curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${asset}" -o "$archive"; then
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

    if ! ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"; then
        error "Failed to link Neovim into ~/.local/bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"
    log "Neovim installed to ~/.local/opt/nvim."
}

install_fzf() {
    if command -v fzf &>/dev/null; then
        warn "fzf already installed, skipping."
        return
    fi

    if [ -d "$HOME/.fzf" ]; then
        warn "fzf already installed at ~/.fzf, skipping."
        return
    fi

    info "Installing fzf via git..."

    if ! git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"; then
        error "Failed to clone fzf."
        return 1
    fi

    if ! "$HOME/.fzf/install" --bin; then
        error "Failed to install fzf binaries."
        return 1
    fi

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
    local YAZI_VERSION
    YAZI_VERSION=$(github_latest_release_tag sxyazi/yazi)
    if [ -z "$YAZI_VERSION" ]; then
        error "Could not determine latest Yazi version. Install manually."
        return 1
    fi
    local YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
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

    if ! git clone --depth 1 https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser.git "$src_dir"; then
        error "Failed to clone xdg-desktop-portal-termfilechooser."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! bash "$src_dir/remove_legacy_file.sh"; then
        error "Failed to remove legacy xdg-desktop-portal-termfilechooser files."
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
