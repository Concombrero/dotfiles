#!/usr/bin/env bash

add_ppas() {
    # PPAs are Ubuntu-specific. Debian and Arch-based distros use their own official repos.
    if [[ "$DISTRO_FAMILY" != "debian" ]]; then
        info "Skipping PPAs on $DISTRO_FAMILY-based distro."
        return
    fi

    if [[ "$DISTRO" != "ubuntu" ]]; then
        info "Skipping PPAs on $DISTRO."
        return
    fi

    if ! command -v add-apt-repository >/dev/null 2>&1; then
        warn "add-apt-repository not found; install software-properties-common or use --skip-ppas."
        return
    fi

    info "Adding PPAs..."
    local had_failure=false

    # Fish Shell
    if ! grep -q "fish-shell/release-4" /etc/apt/sources.list.d/* 2>/dev/null; then
        if sudo add-apt-repository -y ppa:fish-shell/release-4; then
            log "Fish PPA added."
        else
            warn "Failed to add Fish PPA."
            had_failure=true
        fi
    else
        warn "Fish PPA already present."
    fi

    # Alacritty
    if ! grep -q "aslatter/ppa" /etc/apt/sources.list.d/* 2>/dev/null; then
        if sudo add-apt-repository -y ppa:aslatter/ppa; then
            log "Alacritty PPA added."
        else
            warn "Failed to add Alacritty PPA."
            had_failure=true
        fi
    else
        warn "Alacritty PPA already present."
    fi

    if [ "$had_failure" = true ]; then
        return 1
    fi
}
