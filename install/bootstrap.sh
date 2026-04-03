#!/usr/bin/env bash

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m'

PACKAGE_DB_READY=false
PACMAN_FULL_UPGRADE_DONE=false
AUR_HELPER_CMD=""
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

replace_path() {
    local source_path=$1
    local target_path=$2
    local backup_path="${target_path}.backup.$$"

    rm -rf "$backup_path"

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        if ! mv "$target_path" "$backup_path"; then
            error "Failed to back up existing path at $target_path."
            rm -rf "$backup_path"
            return 1
        fi
    fi

    if mv "$source_path" "$target_path"; then
        rm -rf "$backup_path"
        return 0
    fi

    error "Failed to replace $target_path."

    if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
        mv "$backup_path" "$target_path" >/dev/null 2>&1 || true
    fi

    return 1
}

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

current_aur_helper() {
    local helper

    for helper in paru yay; do
        if has_cmd "$helper"; then
            printf '%s\n' "$helper"
            return 0
        fi
    done

    return 1
}

ensure_aur_helper() {
    local tmp_dir pkg_dir

    [ "$DISTRO_FAMILY" = arch ] || return 0

    if [ -n "$AUR_HELPER_CMD" ] && has_cmd "$AUR_HELPER_CMD"; then
        return 0
    fi

    AUR_HELPER_CMD="$(current_aur_helper 2>/dev/null || true)"
    if [ -n "$AUR_HELPER_CMD" ]; then
        return 0
    fi

    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        error "Install the dotfiles as a regular user so an AUR helper can be built safely."
        return 1
    fi

    for cmd in git makepkg; do
        if ! has_cmd "$cmd"; then
            error "Missing required command for AUR helper bootstrap: $cmd"
            return 1
        fi
    done

    info "Bootstrapping yay-bin from the AUR..."
    tmp_dir=$(mktemp -d)
    pkg_dir="$tmp_dir/yay-bin"

    if ! git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$pkg_dir"; then
        error "Failed to clone the yay-bin AUR package."
        rm -rf "$tmp_dir"
        return 1
    fi

    if ! (cd "$pkg_dir" && makepkg -si --noconfirm); then
        error "Failed to build or install yay-bin."
        rm -rf "$tmp_dir"
        return 1
    fi

    rm -rf "$tmp_dir"

    if ! has_cmd yay; then
        error "AUR helper bootstrap completed but yay is not available on PATH."
        return 1
    fi

    AUR_HELPER_CMD="yay"
    log "$AUR_HELPER_CMD is ready."
}

install_single_aur_package() {
    local package=$1

    [ "$DISTRO_FAMILY" = arch ] || return 1
    [ -n "$AUR_HELPER_CMD" ] || return 1

    info "Installing Arch AUR package: $package"

    if "$AUR_HELPER_CMD" -S --needed --noconfirm --answerdiff None --answerclean None "$package"; then
        return 0
    fi

    warn "Skipping Arch AUR package '$package' after $AUR_HELPER_CMD failed."
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

install_aur_pkg() {
    local package
    local had_failure=false

    [ "$#" -gt 0 ] || return 0
    [ "$DISTRO_FAMILY" = arch ] || return 0

    if ! refresh_package_database; then
        error "Failed to refresh package database for Arch AUR installs."
        return 1
    fi

    if ! ensure_aur_helper; then
        return 1
    fi

    info "Installing AUR packages with $AUR_HELPER_CMD: $*"

    for package in "$@"; do
        if ! install_single_aur_package "$package"; then
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
