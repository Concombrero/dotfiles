#!/usr/bin/env bash

github_latest_release_tag() {
    local repo=$1
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name"' | head -1 | cut -d'"' -f4
}

install_tools() {
    run_step "Neovim install" install_neovim
    run_step "fzf install" install_fzf
    run_step "TPM install" install_tpm
    run_step "Starship install" install_starship
    run_step "Zoxide install" install_zoxide
    run_step "Yazi install" install_yazi
    run_step "Lazygit install" install_lazygit
    run_step "OpenCode install" install_opencode
    run_step "Python tool install" install_python_tools

    if [ "$1" = true ]; then
        run_step "Zen Browser install" install_zen
    fi
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
