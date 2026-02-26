#!/usr/bin/env bash

add_ppas() {
    # PPAs are Ubuntu-specific. Debian uses official repos.
    if [[ "$DISTRO" == "debian" ]]; then
        info "Skipping PPAs on Debian."
        return
    fi

    if [[ "$DISTRO" != "ubuntu" ]]; then
        info "Skipping PPAs (unsupported distribution: $DISTRO)"
        return
    fi

    if ! command -v add-apt-repository >/dev/null 2>&1; then
        warn "add-apt-repository not found; install software-properties-common or use --skip-ppas."
        return
    fi

    info "Adding PPAs..."

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
}
