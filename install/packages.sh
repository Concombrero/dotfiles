#!/usr/bin/env bash

install_system_packages() {
    local desktop_mode=$1
    local pkg_file_common="$DOTFILES_DIR/packages/common.txt"
    local pkg_file_desktop="$DOTFILES_DIR/packages/desktop.txt"

    if [ ! -f "$pkg_file_common" ]; then
        error "Package list not found: $pkg_file_common"
        exit 1
    fi

    # Read common packages
    mapfile -t common_pkgs < <(grep -vE "^\s*#|^\s*$" "$pkg_file_common")

    if [ ${#common_pkgs[@]} -eq 0 ]; then
        warn "Common package list is empty."
    else
        install_pkg "${common_pkgs[@]}"
    fi

    # If desktop mode, read desktop packages
    if [ "$desktop_mode" = true ]; then
        if [ ! -f "$pkg_file_desktop" ]; then
            warn "Desktop package list not found: $pkg_file_desktop"
        else
             mapfile -t desktop_pkgs < <(grep -vE "^\s*#|^\s*$" "$pkg_file_desktop")
             if [ ${#desktop_pkgs[@]} -gt 0 ]; then
                install_pkg "${desktop_pkgs[@]}"
             fi
        fi
    else
        info "Skipping desktop packages (--headless or not requested)."
    fi
}
