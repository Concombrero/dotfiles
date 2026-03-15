#!/usr/bin/env bash

stow_packages() {
    info "Stowing dotfiles packages..."

    local stow_list="$DOTFILES_DIR/packages/stow_list.txt"
    if [ ! -f "$stow_list" ]; then
        error "Stow package list not found: $stow_list"
        return
    fi

    # Ensure target directories exist
    mkdir -p "$HOME/.config"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.local/share/applications"

    local failed=()
    STOW_HAD_FAILURES=false
    STOW_FAILED_PACKAGES=()

    while read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            info "Stowing $pkg..."
            # Using --restow (-R) to ensure symlinks are refreshed
            stow -R -d "$DOTFILES_DIR" -t "$HOME" --no-folding --ignore='^AGENTS\.md$' "$pkg" 2>&1 | tee -a "$LOG_FILE"
            if [ "${PIPESTATUS[0]}" -ne 0 ]; then
                warn "Failed to stow $pkg. Check for conflicts."
                failed+=("$pkg")
            fi
        else
            warn "Package directory $pkg not found, skipping."
        fi
    done < "$stow_list"

    if [ ${#failed[@]} -gt 0 ]; then
        STOW_HAD_FAILURES=true
        STOW_FAILED_PACKAGES=("${failed[@]}")
        warn "Failed packages: ${failed[*]}"
        warn "You may need to manually move existing files out of the way."
    else
        log "All stow packages applied successfully."
    fi

    log "Stow process complete."
}
