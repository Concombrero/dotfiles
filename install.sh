#!/usr/bin/env bash

# ============================================================
# Dotfiles Bootstrap Script (Modular)
# ============================================================
# Usage: ./install.sh [OPTIONS]

set -e

# Default Settings
INSTALL_PACKAGES=true
INSTALL_TOOLS=true
INSTALL_FONTS=true
INSTALL_DESKTOP=true
STOW_ONLY=false
SKIP_PPAS=false

# 1. Parse Arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --headless|--no-gui)
            INSTALL_DESKTOP=false
            INSTALL_FONTS=false
            shift
            ;;
        --skip-packages)
            INSTALL_PACKAGES=false
            shift
            ;;
        --skip-tools)
            INSTALL_TOOLS=false
            shift
            ;;
        --skip-fonts)
            INSTALL_FONTS=false
            shift
            ;;
        --skip-ppas)
            SKIP_PPAS=true
            shift
            ;;
        --stow-only)
            STOW_ONLY=true
            INSTALL_PACKAGES=false
            INSTALL_TOOLS=false
            INSTALL_FONTS=false
            INSTALL_DESKTOP=false
            shift
            ;;
        --help|-h)
            echo "Usage: ./install.sh [OPTIONS]"
            echo "Options:"
            echo "  --headless, --no-gui  Skip desktop/GUI packages and fonts"
            echo "  --skip-packages       Skip system package installation"
            echo "  --skip-tools          Skip external tool installation (cargo/go/pip binaries)"
            echo "  --skip-fonts          Skip font installation"
            echo "  --skip-ppas           Skip adding PPAs (Ubuntu only)"
            echo "  --stow-only           Only run stow (skip all installations)"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# 2. Setup Environment
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="$DOTFILES_DIR/install.log"
export STOW_HAD_FAILURES=false

# Initialize Log
echo "" > "$LOG_FILE"

# Source Modules
source "$DOTFILES_DIR/install/bootstrap.sh"
source "$DOTFILES_DIR/install/ppas.sh"
source "$DOTFILES_DIR/install/packages.sh"
source "$DOTFILES_DIR/install/tools.sh"
source "$DOTFILES_DIR/install/python.sh"
source "$DOTFILES_DIR/install/desktop.sh"
source "$DOTFILES_DIR/install/stow.sh"

# 3. Main Execution
main() {
    info "Starting Dotfiles Installation..."
    info "OS: $OS, Distro: $DISTRO"
    info "Log file: $LOG_FILE"

    # Stow Only Mode
    if [ "$STOW_ONLY" = true ]; then
        stow_packages
        echo ""
        if [ "$STOW_HAD_FAILURES" = true ]; then
            warn "Stow-only mode completed with partial success. Failed packages: ${STOW_FAILED_PACKAGES[*]}"
        else
            log "Stow-only mode completed successfully."
        fi
        return
    fi

    ensure_supported_distro

    # System Packages
    if [ "$INSTALL_PACKAGES" = true ]; then
        if [ "$SKIP_PPAS" = false ]; then
            add_ppas
        fi
        install_system_packages "$INSTALL_DESKTOP"
    fi

    # External Tools
    if [ "$INSTALL_TOOLS" = true ]; then
        install_neovim
        install_fzf
        install_tpm
        install_starship
        install_zoxide
        install_yazi
        install_lazygit
        install_opencode
        install_python_tools

        # Desktop-only tools
        if [ "$INSTALL_DESKTOP" = true ]; then
            install_betterlockscreen
            install_zen
        fi
    fi

    # Stow Packages
    stow_packages

    # Fonts & Desktop Extras
    if [ "$INSTALL_DESKTOP" = true ]; then
        if [ "$INSTALL_FONTS" = true ]; then
            install_fonts
        fi

        set_wallpaper
        configure_mime
    fi

    echo ""
    if [ "$STOW_HAD_FAILURES" = true ]; then
        warn "Installation completed with partial success. Stow failed for: ${STOW_FAILED_PACKAGES[*]}"
    else
        log "Installation completed successfully."
    fi
    info "Please log out and log back in for all changes to take effect."
}

main
