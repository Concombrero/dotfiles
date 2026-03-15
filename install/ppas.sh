#!/usr/bin/env bash

ueberzugpp_repo_path() {
    case "$DISTRO" in
        ubuntu)
            case "${VERSION_ID:-}" in
                22.04|23.04|24.04|24.10|25.04)
                    printf 'xUbuntu_%s\n' "$VERSION_ID"
                    return 0
                    ;;
            esac
            ;;
        debian)
            case "${VERSION_ID:-}" in
                12|13)
                    printf 'Debian_%s\n' "$VERSION_ID"
                    return 0
                    ;;
            esac

            case "${VERSION_CODENAME:-}" in
                bookworm)
                    printf 'Debian_12\n'
                    return 0
                    ;;
                trixie)
                    printf 'Debian_13\n'
                    return 0
                    ;;
                testing)
                    printf 'Debian_Testing\n'
                    return 0
                    ;;
                sid|unstable)
                    printf 'Debian_Unstable\n'
                    return 0
                    ;;
            esac
            ;;
    esac

    return 1
}

setup_ueberzugpp_repo() {
    local repo_path repo_line repo_file key_file key_url

    [ "$DISTRO_FAMILY" = debian ] || return 0

    if ! repo_path=$(ueberzugpp_repo_path); then
        warn "No supported upstream ueberzugpp apt repository mapping for $DISTRO ${VERSION_ID:-unknown}; skipping repo setup."
        return 0
    fi

    repo_line="deb http://download.opensuse.org/repositories/home:/justkidding/${repo_path}/ /"
    repo_file="/etc/apt/sources.list.d/home:justkidding-ueberzugpp.list"
    key_file="/etc/apt/trusted.gpg.d/home_justkidding_ueberzugpp.gpg"
    key_url="https://download.opensuse.org/repositories/home:justkidding/${repo_path}/Release.key"

    if sudo test -f "$repo_file" && sudo grep -Fxq "$repo_line" "$repo_file"; then
        warn "ueberzugpp apt repository already present."
        return 0
    fi

    info "Adding upstream ueberzugpp apt repository for $repo_path..."

    if ! printf '%s\n' "$repo_line" | sudo tee "$repo_file" >/dev/null; then
        warn "Failed to write ueberzugpp apt repository file."
        return 1
    fi

    if ! curl -fsSL "$key_url" | gpg --dearmor | sudo tee "$key_file" >/dev/null; then
        warn "Failed to install ueberzugpp apt repository key."
        return 1
    fi

    log "ueberzugpp apt repository added."
}

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

    setup_ueberzugpp_repo || return 1

    if [ "$DISTRO" != "ubuntu" ]; then
        info "Skipping Ubuntu-only PPAs on $DISTRO."
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
