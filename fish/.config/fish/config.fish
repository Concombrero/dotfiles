if status is-interactive
    # Commands to run in interactive sessions can go here
end

# removes the mapping <C-t> which is being used to close the terminal in NeoVim
bind --erase --all \ct

# fish is aware of the paths set by brew:
# to ensure that brew paths are recognized inside fish, run:
#    /opt/brew/bin/brew shellenv >> ~/.config/fish/config.fish 

fish_config prompt choose scales

# Customize the prompt to use ->
function fish_prompt
    set -l last_status $status
    
    # Print the current directory
    set_color normal
    echo -n (prompt_pwd) 
    set_color normal
    
    # Print -> as prompt character
    echo -n " ➜ "
end

# Initialize zoxide
if type -q zoxide
    zoxide init fish --cmd cd | source
end

# set nvim as default editor
set -gx EDITOR nvim
set -gx VISUAL nvim
# CUDA Configuration (only if installed)
if test -d /usr/local/cuda
    # Use the highest version found, or a specific path like /usr/local/cuda-12.8
    set -l cuda_path /usr/local/cuda
    if test -d /usr/local/cuda-12.8
        set cuda_path /usr/local/cuda-12.8
    end
    set -gx CUDA_HOME $cuda_path
    set -gx CUDA_PATH $cuda_path
    fish_add_path $cuda_path/bin
    set -gx LD_LIBRARY_PATH $cuda_path/lib64 $LD_LIBRARY_PATH
end

# fzf (only if installed)
if test -d $HOME/.fzf/bin
    fish_add_path $HOME/.fzf/bin
end

# local binaries (e.g., zoxide)
if test -d $HOME/.local/bin
    fish_add_path $HOME/.local/bin
end

# juliaup (only if installed)
if test -d $HOME/.juliaup/bin
    fish_add_path $HOME/.juliaup/bin
end

# opencode (only if installed)
if test -d $HOME/.opencode/bin
    fish_add_path $HOME/.opencode/bin
end

# Use portal for file picker
set -gx GTK_USE_PORTAL 1

# Sync GUI/session environment from systemd user manager.
# This keeps long-lived shells (tmux/resurrect) aligned with the active X11 session.
if status is-interactive
    if type -q systemctl
        for entry in (systemctl --user show-environment 2>/dev/null)
            switch $entry
                case 'DISPLAY=*'
                    set -gx DISPLAY (string sub -s 9 -- $entry)
                case 'XAUTHORITY=*'
                    set -gx XAUTHORITY (string sub -s 12 -- $entry)
                case 'DBUS_SESSION_BUS_ADDRESS=*'
                    set -gx DBUS_SESSION_BUS_ADDRESS (string sub -s 26 -- $entry)
                case 'XDG_RUNTIME_DIR=*'
                    set -gx XDG_RUNTIME_DIR (string sub -s 17 -- $entry)
                case 'XDG_SESSION_TYPE=*'
                    set -gx XDG_SESSION_TYPE (string sub -s 18 -- $entry)
                case 'XDG_CURRENT_DESKTOP=*'
                    set -gx XDG_CURRENT_DESKTOP (string sub -s 21 -- $entry)
                case 'I3SOCK=*'
                    set -gx I3SOCK (string sub -s 8 -- $entry)
            end
        end
    end

    # Also refresh tmux server env for new panes/windows.
    if set -q TMUX
        for key in DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR XDG_SESSION_TYPE XDG_CURRENT_DESKTOP I3SOCK
            if set -q $key
                tmux set-environment -g $key $$key >/dev/null 2>&1
            end
        end
    end
end

# Machine-local overrides (optional):
# Put personal env vars, tokens, cloud project IDs, etc. in
# ~/.config/fish/local.fish so this public repo stays portable.
set -l fish_local_config "$HOME/.config/fish/local.fish"
if test -f "$fish_local_config"
    source "$fish_local_config"
end
