#!/usr/bin/env bash

install_python_tools() {
    info "Installing Python tools via pipx..."

    if ! command -v pipx &>/dev/null; then
        info "Installing pipx..."
        install_pkg "$(pipx_package_name)"
    fi
    
    # Ensure pipx path is available
    export PATH="$HOME/.local/bin:$PATH"

    local tools=(
        ipython
        jupytext
        black
        isort
        pylint
    )

    for tool in "${tools[@]}"; do
        if pipx list | grep -q "$tool"; then
            warn "$tool already installed via pipx."
        else
            info "Installing $tool..."
            pipx install "$tool"
        fi
    done
    
    pipx ensurepath
    log "Python tools installed."
}

pipx_package_name() {
    case "$DISTRO_FAMILY" in
        arch)
            printf 'python-pipx\n'
            ;;
        *)
            printf 'pipx\n'
            ;;
    esac
}
