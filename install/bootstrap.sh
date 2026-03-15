#!/usr/bin/env bash

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

PACKAGE_DB_READY=false
PACMAN_FULL_UPGRADE_DONE=false
PACKAGE_INSTALL_HAD_FAILURES=false
PACKAGE_INSTALL_FAILED=()
STEP_HAD_FAILURES=false
STEP_FAILED_LABELS=()

log() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
die() { error "$1"; exit 1; }
has_cmd() { command -v "$1" >/dev/null 2>&1; }

record_step_failure() {
    STEP_HAD_FAILURES=true
    STEP_FAILED_LABELS+=("$1")
    warn "$1 failed; continuing with remaining setup."
}

run_step() {
    local label=$1
    shift

    "$@" || record_step_failure "$label"
}

detect_distro_family() {
    local candidate

    for candidate in "$DISTRO" $DISTRO_LIKE; do
        case "$candidate" in
            ubuntu|debian)
                printf 'debian\n'
                return
                ;;
            arch|archlinux|cachyos)
                printf 'arch\n'
                return
                ;;
        esac
    done

    printf '%s\n' "$DISTRO"
}

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        DISTRO=$ID
        DISTRO_LIKE=$(printf '%s' "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')
    elif has_cmd lsb_release; then
        OS=$(lsb_release -si)
        DISTRO=$(printf '%s' "$OS" | tr '[:upper:]' '[:lower:]')
        DISTRO_LIKE=""
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        DISTRO=$(printf '%s' "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
        DISTRO_LIKE=""
    elif [ -f /etc/debian_version ]; then
        OS="Debian"
        DISTRO="debian"
        DISTRO_LIKE=""
    else
        OS=$(uname -s)
        DISTRO=$(printf '%s' "$OS" | tr '[:upper:]' '[:lower:]')
        DISTRO_LIKE=""
    fi

    DISTRO_FAMILY=$(detect_distro_family)
}

ensure_supported_distro() {
    case "$DISTRO_FAMILY" in
        debian|arch)
            return 0
            ;;
        *)
            die "Unsupported distribution: $DISTRO. This installer currently supports Debian/Ubuntu and Arch-based distros that use pacman."
            ;;
    esac
}

refresh_package_database() {
    ensure_supported_distro

    case "$DISTRO_FAMILY" in
        debian)
            [ "$PACKAGE_DB_READY" = true ] && return 0
            info "Refreshing apt package metadata..."
            sudo apt-get update || return 1
            ;;
        arch)
            [ "$PACMAN_FULL_UPGRADE_DONE" = true ] && return 0
            info "Synchronizing pacman databases and upgrading installed packages..."
            sudo pacman -Syu --noconfirm || return 1
            PACMAN_FULL_UPGRADE_DONE=true
            ;;
    esac

    PACKAGE_DB_READY=true
}

install_single_package() {
    local package=$1
    local manager_name

    case "$DISTRO_FAMILY" in
        debian)
            manager_name="Debian"
            info "Installing ${manager_name} package: $package"
            if sudo apt-get install -y "$package"; then
                return 0
            fi
            ;;
        arch)
            manager_name="Arch"
            info "Installing ${manager_name} package: $package"
            if sudo pacman -S --needed --noconfirm "$package"; then
                return 0
            fi
            ;;
    esac

    warn "Skipping ${manager_name} package '$package' after the package manager failed."
    return 1
}

install_pkg() {
    local package
    local had_failure=false

    [ "$#" -gt 0 ] || return 0
    info "Installing packages: $*"

    if ! refresh_package_database; then
        error "Failed to refresh package database for $DISTRO_FAMILY."
        return 1
    fi

    for package in "$@"; do
        if ! install_single_package "$package"; then
            PACKAGE_INSTALL_HAD_FAILURES=true
            PACKAGE_INSTALL_FAILED+=("$package")
            had_failure=true
        fi
    done

    [ "$had_failure" = false ]
}

print_install_summary() {
    echo ""

    if [ "$PACKAGE_INSTALL_HAD_FAILURES" = true ] || [ "$STEP_HAD_FAILURES" = true ] || [ "$STOW_HAD_FAILURES" = true ]; then
        warn "Installation completed with partial success."
        [ "$PACKAGE_INSTALL_HAD_FAILURES" = true ] && warn "Skipped packages: ${PACKAGE_INSTALL_FAILED[*]}"
        [ "$STEP_HAD_FAILURES" = true ] && warn "Failed steps: ${STEP_FAILED_LABELS[*]}"
        [ "$STOW_HAD_FAILURES" = true ] && warn "Stow failed for: ${STOW_FAILED_PACKAGES[*]}"
        return
    fi

    log "Installation completed successfully."
}

detect_os
info "Detected OS: $OS ($DISTRO, family: $DISTRO_FAMILY)"
