#!/usr/bin/env bash

source "$DOTFILES_DIR/install/stow_helpers.sh"

stow_packages() {
    info "Enforcing stowed dotfiles..."

    load_stow_packages "$DOTFILES_DIR" || return 1
    STOW_DRY_RUN=false
    STOW_BACKUP_DIR=${STOW_BACKUP_DIR:-$HOME/dotfiles-stow-backup-$(date +%F-%H%M%S)}

    if force_stow_packages "$DOTFILES_DIR" "${STOW_PACKAGE_LIST[@]}"; then
        log "All stow packages applied successfully."
        return 0
    fi

    warn "Stow completed with conflicts. Backup dir: $STOW_BACKUP_DIR"
    warn "Failed packages: ${STOW_FAILED_PACKAGES[*]}"
    return 1
}
