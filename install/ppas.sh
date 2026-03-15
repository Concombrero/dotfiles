#!/usr/bin/env bash

ensure_ubuntu_ppa() {
    local grep_pattern=$1
    local ppa_name=$2
    local label=$3

    if grep -q "$grep_pattern" /etc/apt/sources.list.d/* 2>/dev/null; then
        warn "$label PPA already present."
        return 0
    fi

    if sudo add-apt-repository -y "$ppa_name"; then
        log "$label PPA added."
        return 0
    fi

    warn "Failed to add $label PPA."
    return 1
}

add_ppas() {
    if [ "$DISTRO_FAMILY" != "debian" ]; then
        info "Skipping PPAs on $DISTRO_FAMILY-based distro."
        return 0
    fi

    if [ "$DISTRO" != "ubuntu" ]; then
        info "Skipping PPAs on $DISTRO."
        return 0
    fi

    if ! has_cmd add-apt-repository; then
        warn "add-apt-repository not found; install software-properties-common or use --skip-ppas."
        return 0
    fi

    info "Adding PPAs..."
    ensure_ubuntu_ppa "fish-shell/release-4" ppa:fish-shell/release-4 Fish || return 1
    ensure_ubuntu_ppa "aslatter/ppa" ppa:aslatter/ppa Alacritty || return 1
}
