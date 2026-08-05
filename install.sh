#!/usr/bin/env bash

if [ -z "${BASH_VERSION:-}" ]; then
    exec bash "$0" "$@"
    printf 'This installer requires bash.\n' >&2
    exit 1
fi

if shopt -qo posix; then
    exec bash "$0" "$@"
    printf 'This installer requires bash without POSIX mode enabled.\n' >&2
    exit 1
fi

set -e

INSTALL_PACKAGES=true
INSTALL_TOOLS=true
INSTALL_FONTS=true
INSTALL_DESKTOP=true
STOW_ONLY=false
SKIP_PPAS=false

show_help() {
    cat <<'EOF'
Usage: ./install.sh [OPTIONS]

Options:
  --headless, --no-gui  Skip desktop/GUI packages and fonts
  --skip-packages       Skip system package installation
  --skip-tools          Skip external tool installation (upstream binaries and pipx tools)
  --skip-fonts          Skip font installation
  --skip-ppas           Skip adding external apt repos/PPAs (Debian/Ubuntu only)
  --stow-only           Only run stow (skip all installations)
EOF
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --headless|--no-gui)
            INSTALL_DESKTOP=false
            INSTALL_FONTS=false
            ;;
        --skip-packages)
            INSTALL_PACKAGES=false
            ;;
        --skip-tools)
            INSTALL_TOOLS=false
            ;;
        --skip-fonts)
            INSTALL_FONTS=false
            ;;
        --skip-ppas)
            SKIP_PPAS=true
            ;;
        --stow-only)
            STOW_ONLY=true
            INSTALL_PACKAGES=false
            INSTALL_TOOLS=false
            INSTALL_FONTS=false
            INSTALL_DESKTOP=false
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export LOG_FILE="$DOTFILES_DIR/install.log"
export STOW_HAD_FAILURES=false

: > "$LOG_FILE"

source "$DOTFILES_DIR/install/bootstrap.sh"
source "$DOTFILES_DIR/install/ppas.sh"
source "$DOTFILES_DIR/install/packages.sh"
source "$DOTFILES_DIR/install/tools.sh"
source "$DOTFILES_DIR/install/python.sh"
source "$DOTFILES_DIR/install/desktop.sh"
source "$DOTFILES_DIR/install/stow.sh"

install_requested_packages() {
    [ "$INSTALL_PACKAGES" = true ] || return 0
    [ "$SKIP_PPAS" = true ] || run_step "PPA setup" add_ppas
    run_step "system package installation" install_system_packages "$INSTALL_DESKTOP"
}

install_requested_tools() {
    [ "$INSTALL_TOOLS" = true ] || return 0
    install_tools "$INSTALL_DESKTOP"
}

apply_requested_desktop_extras() {
    [ "$INSTALL_DESKTOP" = true ] || return 0
    install_desktop_extras "$INSTALL_FONTS"
}

activate_desktop_integrations() {
    [ "$INSTALL_DESKTOP" = true ] || return 0
    case "$DISTRO_FAMILY" in
        arch|fedora)
            run_step "display manager service setup" configure_display_manager_services
            ;;
    esac
    activate_termfilechooser
}

print_post_install_notes() {
    if [ "$INSTALL_DESKTOP" = true ]; then
        case "$DISTRO_FAMILY" in
            arch|fedora)
                info "$OS desktop installs provision the SDDM login stack and enable sddm.service."
                ;;
        esac

        info "Zen UI CSS is staged at ~/.config/zen/chrome/."
        info "After launching Zen once, move that chrome directory into your active profile under ~/.zen/<profile>/chrome/."
    fi

    info "Please log out and log back in for all changes to take effect."
}

main() {
    info "Starting Dotfiles Installation..."
    info "OS: $OS, Distro: $DISTRO, Family: $DISTRO_FAMILY"
    info "Log file: $LOG_FILE"

    if [ "$STOW_ONLY" = true ]; then
        run_step "stow enforcement" stow_packages
        print_install_summary
        return 0
    fi

    ensure_supported_distro
    install_requested_packages
    install_requested_tools
    run_step "stow enforcement" stow_packages
    run_step "Neovim plugin sync" sync_neovim_plugins
    apply_requested_desktop_extras
    activate_desktop_integrations
    print_install_summary
    print_post_install_notes
}

main
