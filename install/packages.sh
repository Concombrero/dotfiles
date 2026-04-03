#!/usr/bin/env bash

package_list_file() {
    local base_name=$1
    local distro_specific="$DOTFILES_DIR/packages/${base_name}.${DISTRO_FAMILY}.txt"
    local default_file="$DOTFILES_DIR/packages/${base_name}.txt"

    if [ -f "$distro_specific" ]; then
        printf '%s\n' "$distro_specific"
    else
        printf '%s\n' "$default_file"
    fi
}

read_package_list() {
    local file=$1
    local -n packages_ref=$2

    mapfile -t packages_ref < <(grep -vE '^\s*#|^\s*$' "$file")
}

install_package_file() {
    local file=$1
    local label=$2
    local packages=()

    if [ ! -f "$file" ]; then
        [ "$label" = desktop ] && warn "Desktop package list not found: $file" && return 0
        error "Package list not found: $file"
        return 1
    fi

    read_package_list "$file" packages
    if [ ${#packages[@]} -eq 0 ]; then
        warn "${label^} package list is empty."
        return 0
    fi

    install_pkg "${packages[@]}"
}

install_system_packages() {
    local desktop_mode=$1
    local had_failure=false

    install_package_file "$(package_list_file common)" common || had_failure=true

    if [ "$desktop_mode" = true ]; then
        install_package_file "$(package_list_file desktop)" desktop || had_failure=true
    else
        info "Skipping desktop packages (--headless or not requested)."
    fi

    [ "$had_failure" = false ]
}
