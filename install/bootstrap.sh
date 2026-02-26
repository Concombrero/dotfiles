#!/usr/bin/env bash

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Logging Functions
log()   { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
die()   { error "$1"; exit 1; }

# OS Detection
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        OS=$DISTRIB_ID
        DISTRO=$(printf '%s' "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]')
    elif [ -f /etc/debian_version ]; then
        OS="Debian"
        DISTRO="debian"
    else
        OS=$(uname -s)
    fi
}

ensure_supported_distro() {
    case "$DISTRO" in
        ubuntu|debian)
            return
            ;;
        *)
            die "Unsupported distribution: $DISTRO. This installer currently supports Ubuntu and Debian only."
            ;;
    esac
}

detect_os
info "Detected OS: $OS ($DISTRO)"

# Package Manager Wrapper
install_pkg() {
    local packages=("$@")
    if [ ${#packages[@]} -eq 0 ]; then
        return
    fi

    info "Installing packages: ${packages[*]}"

    ensure_supported_distro
    sudo apt-get update -y
    sudo apt-get install -y "${packages[@]}"
}

# Check if a command exists
has_cmd() {
    command -v "$1" >/dev/null 2>&1
}
