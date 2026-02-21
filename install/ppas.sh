#!/usr/bin/env bash

add_ppas() {
    # Check if distribution is Ubuntu or Debian-based (that supports PPAs)
    if [[ "$DISTRO" != "ubuntu" ]] && [[ "$DISTRO" != "pop" ]] && [[ "$DISTRO" != "mint" ]]; then
        info "Skipping PPA installation (Distribution: $DISTRO)"
        return
    fi

    info "Adding PPAs..."

    # Neovim
    if ! grep -q "neovim-ppa/unstable" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:neovim-ppa/unstable
        log "Neovim PPA added."
    else
        warn "Neovim PPA already present."
    fi

    # Fish Shell
    if ! grep -q "fish-shell/release-4" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:fish-shell/release-4
        log "Fish PPA added."
    else
        warn "Fish PPA already present."
    fi

    # Alacritty
    if ! grep -q "aslatter/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
        sudo add-apt-repository -y ppa:aslatter/ppa
        log "Alacritty PPA added."
    else
        warn "Alacritty PPA already present."
    fi

    # NodeSource (Node.js LTS)
    if ! command -v node &>/dev/null; then
        info "Adding NodeSource repository for Node.js LTS..."
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        log "NodeSource repo added."
    else
        warn "Node.js already installed ($(node --version)), skipping NodeSource setup."
    fi
}
