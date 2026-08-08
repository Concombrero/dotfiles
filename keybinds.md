# Keybindings Reference

This reference covers the keyboard and mouse bindings explicitly defined or intentionally enabled by this repository. It targets the X11/i3 session with the French AZERTY layout.

Application defaults that are not configured in this repository are not reproduced in full. Machine-local bindings from `~/.config/i3/local.conf`, qutebrowser autoconfig, or other untracked files are also outside this document.

## Notation

- `Super` is the Windows/Command key (`Mod4` in i3).
- `Leader` is `Space` in Neovim.
- `Prefix` is `Alt+Tab` in tmux.
- `Ctrl`, `Alt`, and `Shift` name modifier keys.
- `h/j/k/l` mean left/down/up/right unless a table says otherwise.
- A sequence such as `Ctrl+Space`, then `c` is pressed in order, not simultaneously.
- Caps Lock is remapped to Escape. The physical Escape key remains Escape.

## i3

Source: [`i3/.config/i3/config`](i3/.config/i3/config)

### Launchers

| Key | Action |
|---|---|
| `Super+Enter` | Open Kitty |
| `Super+d` | Open the rofi application/run/window combi launcher |
| `Super+b` | Open the Bitwarden credential picker |
| `Super+z` | Open Zen Browser |
| `Super+n` | Open Neovim in Kitty |
| `Super+g` | Open Lazygit in Kitty |
| `Super+o` | Open OpenCode in Kitty |
| `Super+t` | Open the tmux session picker |
| `Super+p` | Open the power menu |
| `Super+/` | Open the searchable rofi cheatsheet |
| `Print` | Take a screenshot with Flameshot |

### Focus, Windows, and Layouts

| Key | Action |
|---|---|
| `Super+h/j/k/l` | Focus left/down/up/right |
| `Super+Left/Down/Up/Right` | Focus left/down/up/right |
| `Super+Shift+h/j/k/l` | Move the focused window left/down/up/right |
| `Super+Shift+Left/Down/Up/Right` | Move the focused window left/down/up/right |
| `Super+q` | Close the focused window |
| `Super+v` | Split the focused container vertically |
| `Super+s` | Toggle split and stacking layout |
| `Super+w` | Use a tabbed layout |
| `Super+a` | Focus the parent container |
| `Super+f` | Toggle fullscreen |
| `Super+Shift+Space` | Toggle floating/tiling for the focused window |
| `Super+Space` | Switch focus between floating and tiled windows |

### Workspaces

| Key | Action |
|---|---|
| `Super+1` ... `Super+0` | Switch to workspace 1 ... 10 |
| `Super+Shift+1` ... `Super+Shift+0` | Move the focused container to workspace 1 ... 10 |
| `Super+Tab` | Switch to the previously used workspace |
| `Super+Shift+Tab` | Move the focused container to the previous workspace and follow it |

### Resize Mode

Enter resize mode with `Super+r`.

| Key in resize mode | Action |
|---|---|
| `h` | Shrink width |
| `l` | Grow width |
| `j` | Grow height |
| `k` | Shrink height |
| `Left` | Shrink width |
| `Right` | Grow width |
| `Down` | Shrink height |
| `Up` | Grow height |
| `Enter`, `Escape`, or `Super+r` | Leave resize mode |

The arrow-key height directions above reflect the configuration exactly; they are opposite to the `j/k` height actions.

### Session and Media

| Key | Action |
|---|---|
| `Super+Shift+c` | Reload the i3 configuration |
| `Super+Shift+r` | Restart i3 in place |
| `Volume Up` | Raise output volume by 10% |
| `Volume Down` | Lower output volume by 10% |
| `Volume Mute` | Toggle output mute |
| `Microphone Mute` | Toggle microphone mute |
| `Play` | Toggle play/pause |
| `Pause` | Pause playback |
| `Next` | Play the next track |
| `Previous` | Play the previous track |

### Mouse

| Gesture | Action |
|---|---|
| `Super+drag` on a floating window | Move the floating window |
| Drag a tiled window by its title bar | Reposition the tiled window |

## SDDM Login Screen

Source: [`sddm/usr/share/sddm/themes/tagarchy/Main.qml`](sddm/usr/share/sddm/themes/tagarchy/Main.qml)

| Key | Context | Action |
|---|---|---|
| `Enter` or `Keypad Enter` | Username field | Focus the password field |
| `Enter` or `Keypad Enter` | Password field | Submit the username, password, and selected session |

## Rofi Menus

Sources: [`scripts/.local/bin/rofi-bitwarden`](scripts/.local/bin/rofi-bitwarden), [`scripts/.local/bin/rofi-power`](scripts/.local/bin/rofi-power), and [`README.md`](README.md)

### Bitwarden

The launcher starts `rofi-rbw` in username, Tab, password autotype mode.

| Key | Action |
|---|---|
| `Enter` | Type username, press Tab, then type password |
| `Alt+c` | Copy password; clear it after 30 seconds |
| `Alt+u` | Copy username |
| `Alt+t` | Copy TOTP |
| `Alt+m` | Choose another field and action |
| `Alt+s` | Synchronize the vault |

### Power Menu

Use the rofi navigation keys and `Enter` to choose Shutdown, Reboot, Logout, Lock, or Suspend. `Escape` cancels the menu.

## Kitty

Source: [`kitty/.config/kitty/kitty.conf`](kitty/.config/kitty/kitty.conf)

Kitty's default `kitty_mod` is `Ctrl+Shift`.

| Key | Action |
|---|---|
| `Ctrl+Shift+h` | Open the scrollback buffer in Neovim |
| `Ctrl+Shift+g` | Open the last command output in Neovim |
| `Ctrl+Space`, then `c` | Create a tab |
| `Ctrl+Space`, then `k` | Close the current tab |
| `Ctrl+Space`, then `n` | Select the next tab |
| `Ctrl+Space`, then `p` | Select the previous tab |
| `Ctrl+Shift+=` or `Ctrl+Shift++` | Increase the current window's font size |
| `Ctrl+Shift+-` or `Ctrl+Shift+Keypad -` | Decrease the current window's font size |

## tmux

Source: [`tmux/.config/tmux/tmux.conf`](tmux/.config/tmux/tmux.conf)

Every binding in this section begins with `Prefix`, which is `Alt+Tab`.

| Key | Action |
|---|---|
| `Prefix`, then `Alt+Tab` | Send the prefix through to a nested tmux session |
| `Prefix`, then `R` | Reload the tmux configuration |
| `Prefix`, then `Enter` | Create a window |
| `Prefix`, then `q` | Kill the current window |
| `Prefix`, then `v` | Split the pane using tmux's default split direction |
| `Prefix`, then `s` | Prompt for a window number and swap with it |
| `Prefix`, then `Tab` | Select the last window |
| `Prefix`, then `h/j/k/l` | Select the pane left/down/up/right |

### AZERTY Window Selection

The unshifted French AZERTY number-row symbols select windows 1 through 10.

| Key after `Prefix` | Window |
|---|---|
| `&` | 1 |
| `é` | 2 |
| `"` | 3 |
| `'` | 4 |
| `(` | 5 |
| `-` | 6 |
| `è` | 7 |
| `_` | 8 |
| `ç` | 9 |
| `à` | 10 |

The TPM, resurrect, and continuum plugins retain their upstream plugin bindings because this repository does not override them.

## Fish and fzf

Sources: [`fish/.config/fish/config.fish`](fish/.config/fish/config.fish) and [`fish/.config/fish/functions/fish_user_key_bindings.fish`](fish/.config/fish/functions/fish_user_key_bindings.fish)

Fish starts with its standard vi bindings in insert mode. The main config explicitly erases `Ctrl+t` and does not add another active custom binding.

The `fish_user_key_bindings` helper would source fzf's generated `Ctrl+r` history search, `Ctrl+t` file search, `Alt+c` directory search, and `Shift+Tab` completion maps if invoked. A fresh Fish process does not invoke that helper during the current startup sequence, so those fzf maps are not active by default.

## Neovim

Sources: [`nvim/.config/nvim/lua/config/keymaps.lua`](nvim/.config/nvim/lua/config/keymaps.lua), [`nvim/.config/nvim/lua/plugins/editor/which-key.lua`](nvim/.config/nvim/lua/plugins/editor/which-key.lua), and the plugin files named in each subsection.

Modes are abbreviated as Normal, Insert, Visual, Select, Command, and Terminal. `Leader` is `Space`.

### Main Leader Bindings

| Key | Modes | Action |
|---|---|---|
| `Leader+b` | Normal | Build the current buffer with `makeprg` |
| `Leader+d` | Normal, Visual | Save and delete the current buffer |
| `Leader+e` | Normal, Visual | Open Yazi |
| `Leader+g` | Normal | Toggle Diffview |
| `Leader+h` | Normal, Visual | Open the alternate buffer in a vertical split |
| `Leader+a` | Normal | Switch to the alternate buffer |
| `Leader+q` | Normal, Visual | Save all files and quit |
| `Leader+w` | Normal, Visual | Save all files |
| `Leader+z` | Normal, Visual | Toggle Zen mode |

### Copilot Leader Bindings

| Key | Action |
|---|---|
| `Leader+cb` | Previous suggestion |
| `Leader+cd` | Disable Copilot |
| `Leader+ce` | Enable Copilot |
| `Leader+cl` | Accept the suggested line |
| `Leader+cn` | Next suggestion |
| `Leader+cp` | Open the Copilot panel |
| `Leader+cs` | Show Copilot status |
| `Leader+cw` | Accept the suggested word |
| `Leader+cx` | Dismiss the suggestion |

### Find Leader Bindings

| Key | Action |
|---|---|
| `Leader+fa` | Find all files under the home directory, including hidden/ignored files |
| `Leader+fb` | Find open buffers |
| `Leader+fc` | Find bibliography citations |
| `Leader+ff` | Find files |
| `Leader+fg` | Search Git commit history |
| `Leader+fh` | Search help tags |
| `Leader+fk` | Search all active Neovim keymaps |
| `Leader+fl` | Resume the last Telescope search |
| `Leader+fp` | Live grep the project |
| `Leader+fq` | Search the quickfix list |
| `Leader+fr` | Search registers |
| `Leader+fs` | Live grep the word under the cursor or visual selection |
| `Leader+ft` | Search TODO comments |
| `Leader+fu` | Browse undo history |
| `Leader+fy` | Browse yank history |

### Jupyter Leader Bindings

| Key | Action |
|---|---|
| `Leader+jI` | Convert the current `.ipynb` to `.ju.py` |
| `Leader+jR` | Restart the kernel and run all cells |
| `Leader+jS` | Save the current notebook as `.ipynb` with outputs |
| `Leader+ja` | Run all cells |
| `Leader+jb` | Run the selected cell and all cells below it |
| `Leader+jc` | Connect Neopyter |
| `Leader+je` | Run the current cell |
| `Leader+ji` | Show Neopyter status |
| `Leader+jn` | Run the current cell and select the next one |
| `Leader+jo` | Open the current notebook in the browser |
| `Leader+jr` | Restart the kernel |
| `Leader+js` | Synchronize the current notebook tab |
| `Leader+jv` | Bootstrap the project's notebook virtual environment |

### LSP and Diagnostics Leader Bindings

| Key | Action |
|---|---|
| `Leader+lB` | Toggle linting for the current buffer |
| `Leader+lD` | Go to declaration |
| `Leader+lH` | Switch between C/C++ source and header |
| `Leader+lL` | Lint the current file |
| `Leader+lR` | Rename symbol |
| `Leader+lS` | Show clangd symbol information |
| `Leader+lb` | Show buffer diagnostics in Telescope |
| `Leader+lc` | Show code actions |
| `Leader+ld` | Go to definition |
| `Leader+lf` | Format the buffer or selection |
| `Leader+lg` | Toggle global linting |
| `Leader+lh` | Show hover help |
| `Leader+li` | Find implementations |
| `Leader+lk` | Stop LSP clients |
| `Leader+ll` | Show diagnostics for the current line |
| `Leader+ln` | Go to the next warning or error |
| `Leader+lp` | Go to the previous warning or error |
| `Leader+lr` | Find references |
| `Leader+ls` | Restart LSP clients |
| `Leader+lt` | Start LSP clients |
| `Leader+ly` | Copy diagnostics to the system clipboard |

### Markdown Leader Bindings

| Key | Action |
|---|---|
| `Leader+ma` | Toggle all folds |
| `Leader+mf` | Toggle the fold under the cursor |
| `Leader+mo` | Toggle Markdown preview |
| `Leader+ms` | Submit the visual selection through Lectic |
| `Leader+mt` | Toggle the folding method |
| `Leader+mu` | Open the URL under the cursor |

### OpenCode Leader Bindings

| Key | Action |
|---|---|
| `Leader+oO` | Open input for a new session |
| `Leader+oR` | Rename the session |
| `Leader+oT` | Open the session timeline |
| `Leader+oV` | Configure the model variant |
| `Leader+o[` | Go to the previous diff |
| `Leader+o]` | Go to the next diff |
| `Leader+oa` | Open quick chat |
| `Leader+oc` | Close the diff view |
| `Leader+od` | Open the diff view |
| `Leader+oh` | Select from history |
| `Leader+oo` | Open the input window |
| `Leader+oq` | Close OpenCode UI windows |
| `Leader+orA` | Revert all changes |
| `Leader+orR` | Restore all snapshots |
| `Leader+orT` | Revert the current change |
| `Leader+ora` | Revert all changes from the last prompt |
| `Leader+orr` | Restore the current file snapshot |
| `Leader+ort` | Revert the current change from the last prompt |
| `Leader+os` | Select a session |
| `Leader+ov` | Paste an image from the clipboard |
| `Leader+ox` | Swap the OpenCode window position |
| `Leader+oy` | Add the visual selection to context; Visual mode only |
| `Leader+oz` | Toggle OpenCode zoom |

### Session, Typst, and LaTeX Leader Bindings

| Key | Action |
|---|---|
| `Leader+sd` | Delete a Neovim session |
| `Leader+sl` | Load a Neovim session |
| `Leader+ss` | Save the current Neovim session |
| `Leader+tf` | Toggle Typst preview cursor following |
| `Leader+to` | Start Typst preview |
| `Leader+tp` | Toggle Typst preview |
| `Leader+ts` | Stop Typst preview |
| `Leader+tw` | Watch the Typst document |
| `Leader+xb` | Export the current LaTeX bibliography |
| `Leader+xc` | Clear all VimTeX caches |
| `Leader+xe` | Show the VimTeX error report |
| `Leader+xi` | Open the VimTeX table of contents |
| `Leader+xk` | Clean LaTeX auxiliary files |
| `Leader+xm` | Open the VimTeX context menu |
| `Leader+xv` | Open the compiled document |
| `Leader+xw` | Count words |

### General and Editing Bindings

| Key | Modes | Action |
|---|---|---|
| `Ctrl+z` | Normal | Disabled to prevent accidental suspension |
| `gc`, `gcc` | Normal | Disabled globally; commenting uses `Ctrl+;` |
| `Ctrl+t` | Normal, Terminal | Toggle the terminal |
| `Ctrl+s` | Normal | Show spelling suggestions |
| `Enter` | Normal | Clear search highlighting |
| `Ctrl+p` | Normal | Find files with Telescope |
| `Ctrl+;` | Normal | Toggle the current line comment |
| `Ctrl+;` | Visual | Toggle comments for the selection |
| `Shift+m` | Normal | Search help for the word under the cursor |
| `Ctrl+m` | Normal | Search man pages |
| `Y` | Normal, Visual | Yank from the cursor to the end of the line |
| `E` | Normal | Go to the end of the previous word |
| `m` | Normal, Visual | Put the cursor line at the top of the window |
| `Ctrl+h/j/k/l` | Normal | Move to the window left/down/up/right |
| `Alt+Left` or `Alt+h` | Normal | Decrease window width |
| `Alt+Right` or `Alt+l` | Normal | Increase window width |
| `Tab` | Normal | Select the next buffer by modification time |
| `Shift+Tab` | Normal | Select the previous buffer by modification time |
| `Alt+j` / `Alt+k` | Normal, Visual | Move the current line or selection down/up |
| `Ctrl+u` / `Ctrl+d` | Normal | Scroll half a page up/down and center the cursor |
| `Shift+h` / `Shift+l` | Normal, Visual | Go to the start/end of the display line |
| `<` / `>` | Normal, Visual | Decrease/increase indentation and retain selection |
| `J` / `K` | Normal, Visual | Move down/up by display line |
| `gx` | Normal | Open the URL under the cursor |
| `Ctrl+Left click` | Normal | Open the URL under the mouse |
| `Ctrl+Left release` | Normal | Disabled after URL handling |

The Markdown bindings described in comments for list renumbering are not active keymaps in the current implementation, so they are not listed here.

### Terminal Buffers

| Key | Modes | Action |
|---|---|---|
| `Escape` | Terminal | Exit terminal mode; passed through unchanged in Yazi terminals |
| `Ctrl+h/j/k/l` | Terminal | Move to the window left/down/up/right |
| `Alt+Left` or `Alt+h` | Terminal | Increase terminal window width |
| `Alt+Right` or `Alt+l` | Terminal | Decrease terminal window width |
| `Ctrl+a` | Terminal, Normal, Visual | Ask OpenCode about the current terminal; unavailable in Yazi terminals |

### Completion and Snippets

Source: [`nvim/.config/nvim/lua/plugins/lsp/nvim-cmp.lua`](nvim/.config/nvim/lua/plugins/lsp/nvim-cmp.lua)

| Key | Modes | Action |
|---|---|---|
| `Ctrl+k` / `Ctrl+j` | Insert, Command | Select previous/next completion item |
| `Ctrl+b` / `Ctrl+f` | Insert, Command | Scroll completion documentation up/down |
| `Enter` | Insert, Command | Confirm the selected completion item without auto-selecting one |
| `Tab` | Insert, Select | Accept Copilot, expand/jump through a snippet, or select the next completion item |
| `Shift+Tab` | Insert, Select | Select the previous completion item or jump backward in a snippet |
| `Tab` | Visual | Store the selection for a LuaSnip snippet |

### Copilot Direct Bindings

Source: [`nvim/.config/nvim/lua/plugins/tools/copilot.lua`](nvim/.config/nvim/lua/plugins/tools/copilot.lua)

| Key | Context | Action |
|---|---|---|
| `Alt+w` | Suggestion | Accept word |
| `Alt+l` | Suggestion | Accept line |
| `Alt+]` / `Alt+[` | Suggestion | Next/previous suggestion |
| `Ctrl+]` | Suggestion | Dismiss suggestion |
| `[[` / `]]` | Copilot panel | Previous/next entry |
| `Enter` | Copilot panel | Accept entry |
| `gr` | Copilot panel | Refresh |
| `Alt+Enter` | Copilot panel | Open entry |

### Telescope

Source: [`nvim/.config/nvim/lua/plugins/editor/telescope.lua`](nvim/.config/nvim/lua/plugins/editor/telescope.lua)

| Key | Mode | Action |
|---|---|---|
| `Ctrl+j` / `Ctrl+k`, `Down` / `Up` | Insert | Select next/previous result |
| `j` / `k`, `Down` / `Up` | Normal | Select next/previous result |
| `J` or `G` / `K` or `gg` | Normal | Go to the bottom/top result |
| `Enter` | Insert, Normal | Open the selected result |
| `Ctrl+c` | Insert | Close Telescope |
| `Escape` | Normal | Close Telescope |
| `Ctrl+u` / `Ctrl+d` | Insert, Normal | Scroll the preview up/down |
| `Page Up` / `Page Down` | Insert, Normal | Scroll the results up/down |
| `Tab` / `Shift+Tab` | Insert, Normal | Toggle selection and move down/up |
| `Ctrl+q` | Insert, Normal | Send all results to quickfix and open it |
| `Alt+q` | Insert, Normal | Send selected results to quickfix and open it |
| `?` | Normal | Show Telescope mappings |
| `Ctrl+a` / `Ctrl+d` / `Ctrl+u` | Undo picker, Insert | Yank additions/yank deletions/restore |
| `y` / `Y` / `u` | Undo picker, Normal | Yank additions/yank deletions/restore |

### Dashboard

Source: [`nvim/.config/nvim/lua/plugins/tools/snacks/dashboard.lua`](nvim/.config/nvim/lua/plugins/tools/snacks/dashboard.lua)

| Key | Action |
|---|---|
| `s` | Restore a session |
| `r` | Open recent files |
| `e` | Open Yazi |
| `f` | Find a file |
| `g` | Find text |
| `n` | Create a new file |
| `c` | Find a Neovim config file |
| `i` | Open the Neovim configuration README |
| `m` | Manage plugins with Lazy |
| `h` | Run `checkhealth` |
| `q` | Quit Neovim |

### Jupyter Buffers

Source: [`nvim/.config/nvim/lua/plugins/text/jupyter/init.lua`](nvim/.config/nvim/lua/plugins/text/jupyter/init.lua)

| Key | Action |
|---|---|
| `Ctrl+Enter` | Run the current cell |
| `Shift+Enter` | Run the current cell and select the next one |
| `Alt+Enter` | Run the current cell and insert one below |

### Plugin and Special-Buffer Bindings

| Key | Context | Action |
|---|---|---|
| `]t` / `[t` | TODO comments | Go to the next/previous TODO |
| `y` | Normal, Visual | Yank through Yanky |
| `p` / `P` | Normal | Put through Yanky after/before the cursor |
| `gp` / `gP` | Normal | Put through Yanky after/before and leave the cursor after the text |
| `ii` / `ai` | Operator/Visual text object | Select inner/full Snacks scope |
| `q` | Help, man, quickfix, LSP info, NvimTree | Close the special buffer |
| `q` | Generated optimization report | Close the report window |
| `q` or `Escape` | Custom diagnostics popup | Close the popup |
| `Enter` | Custom diagnostics popup | Jump to the selected diagnostic |
| `j` / `k` | Custom diagnostics popup | Move down/up |
| `Ctrl+d` / `Ctrl+u` | Which-key popup | Scroll down/up |
| `F1` | Yazi opened inside Neovim | Show Yazi help |
| `(`, `[`, `{`, `)`, `]`, `}`, `$` | Insert | Insert or skip configured MiniPairs pairs |
| `"`, backtick | Insert | Insert or skip a matching quote pair |

`nvim-surround` also enables its default maps: `ys{motion}{char}` adds a surround, `ds{char}` deletes one, `cs{old}{new}` changes one, and `S{char}` surrounds a visual selection. The configuration adds LaTeX surrounds `E`, `$`, `i`, `b`, `t`, `u`, `q`, and `Q`.

## Yazi

Source: [`yazi/.config/yazi/keymap.toml`](yazi/.config/yazi/keymap.toml)

### Manager: Navigation and Selection

| Key | Action |
|---|---|
| `Escape` or `Ctrl+[` | Leave visual mode, clear selection, or cancel search |
| `q` | Quit and report the current directory |
| `Q` | Quit without reporting the current directory |
| `Ctrl+c` | Close the current tab, or quit if it is the last tab |
| `Ctrl+z` | Suspend Yazi |
| `k` or `Up` | Previous file |
| `j` or `Down` | Next file |
| `Ctrl+u` or `Shift+Page Up` | Move up half a page |
| `Ctrl+d` or `Shift+Page Down` | Move down half a page |
| `Ctrl+b` or `Page Up` | Move up one page |
| `Ctrl+f` or `Page Down` | Move down one page |
| `gg` / `G` | Go to the top/bottom |
| `h` or `Left` | Go to the parent directory |
| `l` or `Right` | Enter the child directory |
| `H` / `L` | Go back/forward in directory history |
| `Space` | Toggle selection and move down |
| `Ctrl+a` | Select all files |
| `Ctrl+r` | Invert selection |
| `v` | Enter selection visual mode |
| `V` | Enter visual unset mode |
| `K` / `J` | Seek preview up/down by five units |
| `Tab` | Spot the hovered file |

### Manager: File Operations

| Key | Action |
|---|---|
| `o` or `Enter` | Open selected files |
| `O` or `Shift+Enter` | Open selected files interactively |
| `y` | Yank selected files for copying |
| `Ctrl+y` | Copy selected files to the system clipboard |
| `x` | Yank selected files for cutting |
| `p` | Paste yanked files |
| `P` | Paste and overwrite existing destinations |
| `-` | Create absolute symbolic links to yanked files |
| `_` | Create relative symbolic links to yanked files |
| `Ctrl+-` | Create hard links to yanked files |
| `Y` or `X` | Cancel yank status |
| `d` | Move selected files to trash |
| `D` | Permanently delete selected files |
| `a` | Create a file; end the name with `/` for a directory |
| `r` | Rename selected files, placing the cursor before the extension |
| `;` | Run an interactive shell command |
| `:` | Run a blocking interactive shell command |
| `.` | Toggle hidden files |
| `s` | Search file names with `fd` |
| `S` | Search file contents with ripgrep |
| `Ctrl+s` | Cancel the current search |
| `z` | Jump to a file or directory with fzf |
| `Z` | Jump to a directory with zoxide |

`o` is defined twice in the manager keymap: once for a forced detached `xdg-open` and later for Yazi's normal `open`. The duplicate should be treated as a configuration conflict; the effective action depends on Yazi's duplicate-map resolution.

### Manager: Display, Copy, and Search

| Key | Action |
|---|---|
| `ms` | Show size linemode |
| `mp` | Show permissions linemode |
| `mb` | Show birth-time linemode |
| `mm` | Show modification-time linemode |
| `mo` | Show owner linemode |
| `mn` | Disable linemode |
| `caa` | Archive selected files |
| `cap` | Archive with a password |
| `cah` | Archive with password and encrypted header |
| `cal` | Archive with a chosen compression level |
| `cau` | Archive with password, encrypted header, and compression level |
| `cc` | Copy the file path |
| `cd` | Copy the directory path |
| `cf` | Copy the filename |
| `cn` | Copy the filename without its extension |
| `f` | Filter files |
| `/` / `?` | Find the next/previous matching file |
| `n` / `N` | Go to the next/previous found file |

### Manager: Sorting

| Key | Action |
|---|---|
| `,m` / `,M` | Sort by modification time ascending/descending |
| `,b` / `,B` | Sort by birth time ascending/descending |
| `,e` / `,E` | Sort by extension ascending/descending |
| `,a` / `,A` | Sort alphabetically ascending/descending |
| `,n` / `,N` | Sort naturally ascending/descending |
| `,s` / `,S` | Sort by size ascending/descending |
| `,r` | Sort randomly |

### Manager: Locations, Tabs, and Help

| Key | Action |
|---|---|
| `gh` | Go to the home directory |
| `gc` | Go to `~/.config` |
| `gd` | Go to `~/Downloads` |
| `g Space` | Choose a directory interactively |
| `gf` | Follow the hovered symbolic link |
| `t` | Create a tab in the current directory |
| `1` ... `9` | Switch to tab 1 ... 9 |
| `[` / `]` | Switch to the previous/next tab |
| `{` / `}` | Swap the current tab with the previous/next tab |
| `w` | Show the task manager |
| `~` or `F1` | Open help |

### Task Manager

| Key | Action |
|---|---|
| `Escape`, `Ctrl+[`, `Ctrl+c`, or `w` | Close the task manager |
| `k` or `Up` / `j` or `Down` | Select the previous/next task |
| `Enter` | Inspect the task |
| `x` | Cancel the task |
| `~` or `F1` | Open help |

### Spot View

| Key | Action |
|---|---|
| `Escape`, `Ctrl+[`, `Ctrl+c`, or `Tab` | Close spot view |
| `k` or `Up` / `j` or `Down` | Select the previous/next line |
| `h` or `Left` / `l` or `Right` | Show the previous/next file |
| `cc` | Copy the selected cell |
| `~` or `F1` | Open help |

### Pick View

| Key | Action |
|---|---|
| `Escape`, `Ctrl+[`, or `Ctrl+c` | Cancel the picker |
| `Enter` | Submit the selected option |
| `k` or `Up` / `j` or `Down` | Select the previous/next option |
| `~` or `F1` | Open help |

### Input Editor

| Key | Action |
|---|---|
| `Ctrl+c` | Cancel input |
| `Enter` | Submit input |
| `Escape` or `Ctrl+[` | Return to Normal mode or cancel input |
| `i` / `I` | Insert at the cursor/first nonblank character |
| `a` / `A` | Append at the cursor/end of line |
| `v` | Enter Visual mode |
| `r` | Replace one character |
| `V` | Select from beginning to end of line |
| `Ctrl+a` / `Ctrl+e` | Select from end to beginning/from beginning to end |
| `h`, `Left`, or `Ctrl+b` | Move back one character |
| `l`, `Right`, or `Ctrl+f` | Move forward one character |
| `b` / `B` | Move to the previous word/WORD |
| `w` / `W` | Move to the next word/WORD |
| `e` / `E` | Move to the end of the next word/WORD |
| `Alt+b` or `Ctrl+Left` | Move to the previous word |
| `Alt+f` or `Ctrl+Right` | Move to the end of the next word |
| `0`, `Ctrl+a`, or `Home` | Move to the beginning of the line |
| `$`, `Ctrl+e`, or `End` | Move to the end of the line |
| `_` or `^` | Move to the first nonblank character |
| `Backspace` or `Ctrl+h` | Delete the previous character |
| `Delete` or `Ctrl+d` | Delete the character under the cursor |
| `Ctrl+u` / `Ctrl+k` | Delete to the beginning/end of the line |
| `Ctrl+w` or `Ctrl+Backspace` | Delete the previous word |
| `Alt+d` or `Ctrl+Delete` | Delete the next word |
| `d` / `D` | Cut the selection/cut to end of line |
| `c` / `C` | Cut the selection/to end of line and enter Insert mode |
| `s` / `S` | Cut the current character/line and enter Insert mode |
| `x` | Cut the current character |
| `y` | Copy selected characters |
| `p` / `P` | Paste after/before the cursor |
| `u` | Undo, or lowercase in Visual mode |
| `U` | Uppercase |
| `Ctrl+r` | Redo |
| `~` or `F1` | Open help |

### Confirmation, Completion, and Help Views

| Key | Context | Action |
|---|---|---|
| `Escape`, `Ctrl+[`, or `Ctrl+c` | Confirmation | Cancel |
| `n` | Confirmation | Cancel |
| `Enter` or `y` | Confirmation | Confirm |
| `k` or `Up` / `j` or `Down` | Confirmation | Scroll up/down |
| `Ctrl+c` | Completion | Cancel completion |
| `Tab` | Completion | Accept completion |
| `Enter` | Completion | Accept completion and submit input |
| `Alt+k`, `Up`, or `Ctrl+p` | Completion | Select previous item |
| `Alt+j`, `Down`, or `Ctrl+n` | Completion | Select next item |
| `Escape` or `Ctrl+[` | Help | Clear the filter or close help |
| `Ctrl+c` | Help | Close help |
| `k` or `Up` / `j` or `Down` | Help | Select previous/next line |
| `f` | Help | Filter help entries |
| `~` or `F1` | Confirmation or completion | Open help |

## Zathura

Source: [`zathura/.config/zathura/zathurarc`](zathura/.config/zathura/zathurarc)

| Key | Action |
|---|---|
| `Space` | Toggle the document index |
| `p` | Print |
| `w` | Toggle recoloring |
| `k` / `j` | Scroll up/down |
| `Ctrl+v` | Toggle fullscreen |

The alternate theme files additionally map `K` / `J` to zoom in/out when one of those files is loaded as configuration.

## Applications Using Upstream Keymaps

These applications are configured here but do not define a complete repository-owned keymap:

- **btop** enables its upstream Vim directional keys with `vim_keys = True`: `h/j/k/l` navigate, while `Shift+h` opens help and `Shift+k` accesses kill.
- **qutebrowser** loads its normal autoconfig and defines no tracked custom binds. Use `:bind` or qutebrowser help to inspect the effective map.
- **Lazygit** changes only appearance and repository handling. Press `?` in Lazygit for its effective keymap.
- **OpenCode** defines providers, plugins, permissions, and MCP servers but no tracked CLI key overrides. Use its in-app help for the installed version's map.
- **rofi** uses upstream navigation and acceptance keys; the repository changes its modes and presentation, not its base keymap.
- **Fish** enables upstream vi bindings; only the fzf additions and `Ctrl+t` erase are repository-specific.