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

aur_package_list_file() {
    local base_name=$1
    printf '%s\n' "$DOTFILES_DIR/packages/${base_name}.aur.arch.txt"
}

read_package_list() {
    local file=$1
    local -n packages_ref=$2

    mapfile -t packages_ref < <(grep -vE '^\s*#|^\s*$' "$file")
}

install_package_file() {
    local file=$1
    local label=$2
    local installer=${3:-install_pkg}
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

    "$installer" "${packages[@]}"
}

install_system_packages() {
    local desktop_mode=$1
    local had_failure=false

    install_package_file "$(package_list_file common)" common install_pkg || had_failure=true

    if [ "$desktop_mode" = true ]; then
        install_package_file "$(package_list_file desktop)" desktop install_pkg || had_failure=true
    else
        info "Skipping desktop packages (--headless or not requested)."
    fi

    if [ "$DISTRO_FAMILY" = arch ]; then
        install_package_file "$(aur_package_list_file common)" "common AUR" install_aur_pkg || had_failure=true

        if [ "$desktop_mode" = true ]; then
            install_package_file "$(aur_package_list_file desktop)" "desktop AUR" install_aur_pkg || had_failure=true
        else
            info "Skipping desktop AUR packages (--headless or not requested)."
        fi
    fi

    [ "$had_failure" = false ]
}
