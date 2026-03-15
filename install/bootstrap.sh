#!/usr/bin/env bash

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

PACKAGE_DB_READY=false
PACMAN_FULL_UPGRADE_DONE=false
PACKAGE_INSTALL_HAD_FAILURES=false
PACKAGE_INSTALL_FAILED=()
STEP_HAD_FAILURES=false
STEP_FAILED_LABELS=()

# Logging Functions
log()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
die()   { error "$1"; exit 1; }

record_step_failure() {
    local step_label=$1

    STEP_HAD_FAILURES=true
    STEP_FAILED_LABELS+=("$step_label")
    warn "$step_label failed; continuing with remaining setup."
}

run_step() {
    local step_label=$1
    shift

    if "$@"; then
        return 0
    fi

    record_step_failure "$step_label"
    return 0
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

# OS Detection
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        DISTRO=$ID
        DISTRO_LIKE=$(printf '%s' "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
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
            return
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
            if [ "$PACKAGE_DB_READY" != true ]; then
                info "Refreshing apt package metadata..."
                sudo apt-get update || return 1
                PACKAGE_DB_READY=true
            fi
            ;;
        arch)
            if [ "$PACMAN_FULL_UPGRADE_DONE" != true ]; then
                info "Synchronizing pacman databases and upgrading installed packages..."
                sudo pacman -Syu --noconfirm || return 1
                PACMAN_FULL_UPGRADE_DONE=true
                PACKAGE_DB_READY=true
            fi
            ;;
    esac
}

detect_os
info "Detected OS: $OS ($DISTRO, family: $DISTRO_FAMILY)"

# Package Manager Wrapper
install_pkg() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return
    fi

    info "Installing packages: ${packages[*]}"

    if ! refresh_package_database; then
        error "Failed to refresh package database for $DISTRO_FAMILY."
        return 1
    fi

    case "$DISTRO_FAMILY" in
        debian)
            install_debian_packages "${packages[@]}"
            ;;
        arch)
            install_arch_packages "${packages[@]}"
            ;;
    esac
}

install_debian_packages() {
    local package

    for package in "$@"; do
        if ! install_debian_package "$package"; then
            PACKAGE_INSTALL_HAD_FAILURES=true
            PACKAGE_INSTALL_FAILED+=("$package")
        fi
    done
}

install_debian_package() {
    local package=$1

    info "Installing Debian package: $package"

    if sudo apt-get install -y "$package"; then
        return 0
    fi

    warn "Skipping Debian package '$package' after apt failed."
    return 1
}

install_arch_packages() {
    local package

    for package in "$@"; do
        if ! install_arch_package "$package"; then
            PACKAGE_INSTALL_HAD_FAILURES=true
            PACKAGE_INSTALL_FAILED+=("$package")
        fi
    done
}

install_arch_package() {
    local package=$1

    info "Installing Arch package: $package"

    if sudo pacman -S --needed --noconfirm "$package"; then
        return 0
    fi

    warn "Skipping Arch package '$package' after pacman failed. This usually means it conflicts with something already installed or is temporarily unavailable."
    return 1
}

# Check if a command exists
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}
