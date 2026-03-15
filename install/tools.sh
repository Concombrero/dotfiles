#!/usr/bin/env bash

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

    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${asset}" -o "$archive"
    tar -xzf "$archive" -C "$tmp_dir"

    mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
    rm -rf "$install_dir"
    mv "$extracted_dir" "$install_dir"
    ln -sfn "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"

    rm -rf "$tmp_dir"
    log "Neovim installed to ~/.local/opt/nvim."
}

install_fzf() {
    if [ -d "$HOME/.fzf" ]; then
        warn "fzf already installed at ~/.fzf, skipping."
        return
    fi
    info "Installing fzf via git..."
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin
    log "fzf installed to ~/.fzf."
}

install_tpm() {
    local tpm_dir="$HOME/.tmux/plugins/tpm"
    if [ -d "$tpm_dir" ]; then
        warn "TPM already installed at ~/.tmux/plugins/tpm, skipping."
        return
    fi

    info "Installing tmux plugin manager (TPM)..."
    mkdir -p "$HOME/.tmux/plugins"
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
    log "TPM installed."
}

install_starship() {
    if command -v starship &>/dev/null; then
        warn "Starship already installed, skipping."
        return
    fi
    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    log "Starship installed."
}

install_zoxide() {
    if command -v zoxide &>/dev/null; then
        warn "Zoxide already installed, skipping."
        return
    fi
    info "Installing Zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    log "Zoxide installed."
}

install_yazi() {
    if command -v yazi &>/dev/null; then
        warn "Yazi already installed, skipping."
        return
    fi
    info "Installing Yazi..."
    local YAZI_VERSION
    YAZI_VERSION=$(curl -sL https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    if [ -z "$YAZI_VERSION" ]; then
        error "Could not determine latest Yazi version. Install manually."
        return
    fi
    local YAZI_URL="https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
    local TMP_DIR=$(mktemp -d)
    curl -sL "$YAZI_URL" -o "$TMP_DIR/yazi.zip"
    unzip -q "$TMP_DIR/yazi.zip" -d "$TMP_DIR"
    sudo mv "$TMP_DIR"/yazi-*/yazi /usr/local/bin/yazi
    sudo mv "$TMP_DIR"/yazi-*/ya /usr/local/bin/ya
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
    LAZYGIT_VERSION=$(curl -sL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep '"tag_name"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
    if [ -z "$LAZYGIT_VERSION" ]; then
        error "Could not determine latest Lazygit version. Install manually."
        return
    fi
    local TMP_DIR=$(mktemp -d)
    curl -sL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" -o "$TMP_DIR/lazygit.tar.gz"
    tar -xzf "$TMP_DIR/lazygit.tar.gz" -C "$TMP_DIR"
    sudo mv "$TMP_DIR/lazygit" /usr/local/bin/lazygit
    rm -rf "$TMP_DIR"
    log "Lazygit installed."
}

install_zen() {
    if [ -x "$HOME/.local/bin/zen" ] || command -v zen &>/dev/null; then
        warn "Zen Browser already installed, skipping."
        return
    fi
    info "Installing Zen Browser..."
    curl -fsSL https://github.com/zen-browser/updates-server/raw/refs/heads/main/install.sh | bash
    log "Zen Browser installed."
}

install_opencode() {
    if command -v opencode &>/dev/null; then
        warn "OpenCode already installed, skipping."
        return
    fi
    info "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    log "OpenCode installed."
}
