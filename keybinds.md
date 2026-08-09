# Keybindings Reference

This reference covers the keyboard and mouse bindings explicitly defined or intentionally enabled by this repository. It targets the X11/i3 session with the French AZERTY layout.

Bindings are documented at three levels:

- **Repository bindings** are exhaustive and come directly from the tracked configuration.
- **Enabled defaults** are the upstream maps deliberately retained by this setup. They are grouped by workflow and may vary with the installed application version.
- **Runtime help** is the final authority for applications installed from a moving `latest` release or applications that load machine-local state.

Machine-local bindings from `~/.config/i3/local.conf`, qutebrowser autoconfig, or other untracked files cannot be listed here. Use the discovery command shown in the relevant application section to inspect them.

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

### How i3 Is Organized

i3 arranges windows in a tree of **containers**. A workspace is one tree, and splits determine how the next window is placed. The usual workflow is:

1. Open a program with a launcher binding such as `Super+Enter`.
2. Move focus with `Super+h/j/k/l`.
3. Move the focused window with the same direction plus `Shift`.
4. Choose a split or layout before opening the next window.
5. Send windows to numbered workspaces with `Super+Shift+number` and switch workspaces with `Super+number`.

`Super+a` focuses the parent container. This matters when a move or layout command should affect a group of windows rather than only the current leaf. Floating windows form a separate focus layer: `Super+Space` switches between floating and tiled focus, while `Super+Shift+Space` moves the focused window between those layers.

### Common Workflows

| Goal | Sequence |
|---|---|
| Open a terminal beside the current window | `Super+v`, then `Super+Enter` |
| Put two windows in tabs | Focus their parent with `Super+a` if needed, then `Super+w` |
| Stack windows vertically | Focus their parent with `Super+a` if needed, then `Super+s` |
| Move a window to workspace 4 and follow it | `Super+Shift+4`, then `Super+4` |
| Send a window to the last workspace and follow it | `Super+Shift+Tab` |
| Temporarily enlarge one window | `Super+f`; press it again to restore |
| Resize without the mouse | `Super+r`, resize with directions, then `Enter` |

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

The custom login form is a two-step keyboard flow: type the username, press `Enter`, type the password, and press `Enter` again. The second press submits the selected desktop session. These are the only keys handled explicitly by the tracked theme; focus traversal and session-list navigation otherwise come from Qt/SDDM.

| Key | Context | Action |
|---|---|---|
| `Enter` or `Keypad Enter` | Username field | Focus the password field |
| `Enter` or `Keypad Enter` | Password field | Submit the username, password, and selected session |

## i3lock Lock Screen

Sources: [`scripts/.local/bin/lock-screen`](scripts/.local/bin/lock-screen) and [`i3/.config/i3/config`](i3/.config/i3/config)

The lock helper starts i3lock-color with a blurred wallpaper, clock, password indicator, and failed-attempt display. It is invoked automatically by `xss-lock` before suspend and from the Lock choice in `Super+p`'s power menu. There is no separate tracked one-key lock binding.

The lock screen captures ordinary keyboard input as the password and displays only an indicator, never the password itself. The active X11 layout remains French AZERTY. Because this workstation maps Caps Lock to Escape, pressing Caps Lock at the lock screen clears the current password just like the physical Escape key.

| Key | Action |
|---|---|
| Printable characters | Append to the hidden password buffer |
| `Enter` or `Keypad Enter` | Submit the current password for verification |
| `Backspace` | Delete the previous password character |
| `Ctrl+u` | Clear the entire password buffer |
| `Escape` or `Caps Lock` | Clear the password buffer; this does not unlock or close i3lock |
| `Delete` | Consume the key without inserting a password character |
| Empty `Enter` | Do nothing because `--ignore-empty-password` is enabled |

The helper enables `--pass-media-keys` and `--pass-screen-keys`, so these hardware controls continue to reach the desktop while locked:

| Key | Passed-through action |
|---|---|
| Play/Pause, Stop, Previous, or Next | Control media playback |
| Volume Up / Volume Down / Volume Mute | Control output volume |
| Microphone Mute | Toggle microphone mute |
| Brightness Up / Brightness Down | Adjust screen brightness |

Power keys are not passed through by this helper. If i3lock-color is unavailable, the script falls back to plain i3lock with the same basic password, `Enter`, `Backspace`, `Ctrl+u`, and `Escape` behavior, but without the color fork's pass-through options.

## Flameshot Screenshot Editor

Sources: [`i3/.config/i3/config`](i3/.config/i3/config) and [`scripts/.local/bin/flameshot-gui-focus-fix`](scripts/.local/bin/flameshot-gui-focus-fix)

Press `Print` from i3 to open Flameshot's full-screen capture editor. Drag a region, annotate it with the tool keys, then copy, save, open, or accept the capture. The tracked wrapper only starts `flameshot gui` and restores focus afterward; it does not change Flameshot's own shortcuts.

Flameshot allows its action keys to be changed in **Configuration > Shortcuts**, so that page is the authority after local customization or an upgrade. The map below is the current upstream Linux default.

### Common Workflows

| Goal | Sequence |
|---|---|
| Capture a region to the clipboard | `Print`, drag the region, then `Ctrl+c` |
| Capture and save to a file | `Print`, drag the region, then `Ctrl+s` |
| Capture the whole screen | `Print`, then `Ctrl+a` |
| Draw an arrow | Press `a`, then drag from tail to tip |
| Hide sensitive text | Press `b`, then drag over it to pixelate |
| Add text | Press `t`, click, type, then press `Ctrl+Enter` |
| Correct an annotation | `Ctrl+z`; redo with `Ctrl+Shift+z` |
| Move or resize the capture by keyboard | Arrows to move; `Shift`+arrows to resize |
| Cancel the capture | `Escape` |

### Capture and Output

| Key | Action |
|---|---|
| `Print` | Open the Flameshot capture editor through i3 |
| `Enter` | Accept the current capture using the active capture task |
| `Ctrl+c` | Copy the selected capture to the desktop clipboard |
| `Ctrl+s` | Save the capture to a file |
| `Ctrl+o` | Open the capture with another application |
| `Escape` | Cancel and close the capture editor |
| `Ctrl+z` / `Ctrl+Shift+z` | Undo/redo the last edit |
| `Delete` | Delete the selected annotation object |
| `Ctrl+Backspace` | Cancel the current selection |

Upload, pin, circle-counter, keyboard size-increase/decrease, and some optional build actions are present in Flameshot but unbound by default. Use the toolbar or assign them under **Configuration > Shortcuts**.

### Annotation Tools

| Key | Tool |
|---|---|
| `p` | Pencil/freehand drawing |
| `d` | Straight line |
| `a` | Arrow |
| `s` | Selection tool |
| `r` | Rectangle |
| `c` | Circle/ellipse |
| `m` | Marker/highlighter |
| `t` | Text |
| `b` | Pixelate/blur an area |
| `i` | Invert colors in an area |
| `Ctrl+m` | Move the capture selection |
| `g` | Pick a color from the screen |
| `Space` | Toggle the side panel |

While drawing a line, arrow, or marker, hold `Ctrl` to constrain it to horizontal, vertical, or diagonal directions. Hold `Ctrl` while drawing a rectangle or circle to preserve its aspect ratio. In the text tool, `Ctrl+Enter` commits the current text object.

### Selection and Tool Size

| Key or gesture | Action |
|---|---|
| `Ctrl+a` | Select the full screen |
| Arrows | Move the capture selection by one pixel |
| `Shift`+arrows | Resize the selection by one pixel |
| `Ctrl+Shift`+arrows | Resize symmetrically by two pixels |
| Left drag on the screen | Create or move the capture selection |
| Drag a selection handle | Resize from that edge or corner |
| `Shift`+drag a selection handle | Mirror the resize at the opposite handle |
| `Ctrl`+drag a selection handle | Preserve the selection's aspect ratio |
| Mouse wheel | Increase/decrease the active tool's thickness |
| Number keys | Set the active tool to an absolute size |

### Color and Mouse Controls

| Key or gesture | Action |
|---|---|
| Right click in the editor | Show the color wheel/picker |
| `g` | Enter screen-color sampling mode |
| Left click or `Enter` while sampling | Accept the sampled color |
| Hold left click while sampling | Use the magnified precision picker |
| Right click or `Space` while sampling | Toggle the sampling magnifier |
| `Escape` while sampling | Cancel color sampling |

## Rofi Menus

Sources: [`scripts/.local/bin/rofi-bitwarden`](scripts/.local/bin/rofi-bitwarden), [`scripts/.local/bin/rofi-power`](scripts/.local/bin/rofi-power), and [`README.md`](README.md)

Rofi is the common picker behind the application launcher, power menu, cheatsheet, and credential picker. Start typing to filter, move through results, then accept or cancel. The repository does not override Rofi's base map, so the following upstream bindings apply to the installed version.

### Navigation and Acceptance

| Key | Action |
|---|---|
| `Up` / `Ctrl+p` | Select the previous entry |
| `Down` / `Ctrl+n` | Select the next entry |
| `Tab` / `Shift+Tab` | Select the next/previous element |
| `Page Up` / `Page Down` | Select the previous/next page |
| `Home` / `End` | Select the first/last entry |
| `Ctrl+Page Up` / `Ctrl+Page Down` | Move to the previous/next column |
| `Enter`, `Keypad Enter`, `Ctrl+j`, or `Ctrl+m` | Accept the selected entry |
| `Shift+Enter` | Use the alternate accept action |
| `Ctrl+Enter` | Accept typed text as a custom command in run/SSH mode |
| `Ctrl+Shift+Enter` | Use the alternate custom-command action |
| `Ctrl+Space` | Put the selected row text into the input field |
| `Shift+Delete` | Delete the selected entry from history |
| `Shift+Right` / `Ctrl+Tab` | Switch to the next Rofi mode |
| `Shift+Left` / `Ctrl+Shift+Tab` | Switch to the previous Rofi mode |
| `Ctrl+l` | Complete input using the current mode |
| `Escape`, `Ctrl+g`, or `Ctrl+[` | Cancel and close Rofi |

### Editing the Search Field

| Key | Action |
|---|---|
| `Left` / `Ctrl+b` | Move back one character |
| `Right` / `Ctrl+f` | Move forward one character |
| `Alt+b` / `Ctrl+Left` | Move back one word |
| `Alt+f` / `Ctrl+Right` | Move forward one word |
| `Ctrl+a` / `Ctrl+e` | Move to the beginning/end of the line |
| `Backspace`, `Shift+Backspace`, or `Ctrl+h` | Delete the previous character |
| `Delete` / `Ctrl+d` | Delete the next character |
| `Ctrl+Backspace` / `Ctrl+Alt+h` | Delete the previous word |
| `Ctrl+Alt+d` | Delete the next word |
| `Ctrl+u` / `Ctrl+k` | Delete to the beginning/end of the line |
| `Ctrl+w` | Clear the input line |
| `Ctrl+t` | Transpose the two characters before the cursor |
| `Ctrl+Shift+v` / `Shift+Insert` | Paste the X11 primary selection |
| `Ctrl+v` / `Insert` | Paste the clipboard |
| `Ctrl+c` | Copy the selected entry to the clipboard |

### Filtering and Direct Selection

| Key | Action |
|---|---|
| `` ` `` | Toggle case-sensitive matching |
| `Alt+`` ` `` | Toggle sorting of filtered results |
| `Alt+.` | Toggle text ellipsizing |
| `Alt+s` | Save a screenshot of the Rofi window |
| `Ctrl+Up` / `Ctrl+Down` | Move backward/forward through input history |
| `Super+=` / `Super+-` | Select the next/previous matcher |
| `Super+1` ... `Super+0` | Select rows 1 ... 10 directly |
| `Alt+1` ... `Alt+0` | Invoke custom actions 1 ... 10 |
| `Alt+!/@/#/$/%/^/&/*/(` | Invoke custom actions 11 ... 19 |

### Mouse

| Gesture | Action |
|---|---|
| Scroll up/down | Select the previous/next entry |
| Scroll left/right | Select the previous/next column |
| Left click | Select the hovered entry |
| Double left click | Accept the hovered entry |
| `Ctrl`+double left click | Use the custom accept action |

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

Kitty has three levels: an OS window contains tabs, and each tab can contain one or more Kitty windows arranged by a layout. This setup normally uses one shell window per tab and uses tmux for terminal multiplexing, but Kitty's own window controls remain active.

Kitty's `kitty_mod` is `Ctrl+Shift`. The repository keeps the built-in shortcuts and overrides or adds the following bindings.

### Repository Bindings

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

The four `Ctrl+Space` shortcuts are sequences: press and release `Ctrl+Space`, then press the final letter. There is no timeout in the current Kitty configuration.

### Copy, Select, and Paste

Selecting text with the mouse immediately copies it to the desktop clipboard because `copy_on_select clipboard` is enabled. `Ctrl+Shift+c` remains useful to copy an existing selection explicitly. `Ctrl+Shift+v` is the reliable system-paste key inside shells, tmux, and Neovim terminals.

| Key or gesture | Action |
|---|---|
| Left drag | Select text and copy it to the clipboard |
| Double left click | Select and copy a word |
| Triple left click | Select and copy a line |
| `Ctrl+Alt`+left drag | Make a rectangular selection |
| Right click or `Shift`+left click | Extend the current selection |
| `Shift`+left drag | Select even when a terminal program has captured the mouse |
| `Ctrl+Shift+c` | Copy the current selection to the clipboard |
| `Ctrl+Shift+v` | Paste the clipboard |
| `Ctrl+Shift+s` or `Shift+Insert` | Paste the X11 primary selection |
| Middle click | Paste the X11 primary selection |
| `Ctrl+Shift+o` | Open the selected text with the system handler |
| Left click on a detected link | Open the link when no selection is active |
| `Ctrl+Shift`+left click | Open a detected link even when an application captured the mouse |
| `Ctrl+Shift`+right click | Show the clicked shell command's output in the pager |

### Scrollback and Shell Output

| Key | Action |
|---|---|
| `Ctrl+Shift+Up` / `Ctrl+Shift+k` | Scroll one line up |
| `Ctrl+Shift+Down` / `Ctrl+Shift+j` | Scroll one line down |
| `Ctrl+Shift+Page Up` / `Ctrl+Shift+Page Down` | Scroll one page up/down |
| `Ctrl+Shift+Home` / `Ctrl+Shift+End` | Go to the top/bottom of scrollback |
| `Ctrl+Shift+z` / `Ctrl+Shift+x` | Go to the previous/next shell prompt |
| `Ctrl+Shift+h` | Open all scrollback in Neovim through kitty-scrollback.nvim |
| `Ctrl+Shift+g` | Open the last command output in Neovim through kitty-scrollback.nvim |

Prompt navigation and last-command output require Kitty shell integration, which this configuration enables.

### Kitty Windows

| Key | Action |
|---|---|
| `Ctrl+Shift+Enter` | Create a Kitty window in the current tab |
| `Ctrl+Shift+n` | Create a new top-level OS window |
| `Ctrl+Shift+w` | Close the current Kitty window |
| `Ctrl+Shift+]` / `Ctrl+Shift+[` | Focus the next/previous Kitty window |
| `Ctrl+Shift+f` / `Ctrl+Shift+b` | Move the current Kitty window forward/backward |
| `Ctrl+Shift+`` ` `` | Move the current Kitty window to the top |
| `Ctrl+Shift+r` | Enter interactive Kitty-window resize mode |
| `Ctrl+Shift+1` ... `Ctrl+Shift+0` | Focus Kitty window 1 ... 10 |
| `Ctrl+Shift+F7` | Label visible Kitty windows and choose one |
| `Ctrl+Shift+F8` | Label visible Kitty windows and choose one to swap with |

### Tabs and Layouts

| Key | Action |
|---|---|
| `Ctrl+Space`, then `c` | Create a tab |
| `Ctrl+Space`, then `k` | Close the current tab |
| `Ctrl+Space`, then `n` / `p` | Select the next/previous tab |
| `Ctrl+Shift+Right` or `Ctrl+Tab` | Select the next tab |
| `Ctrl+Shift+Left` or `Ctrl+Shift+Tab` | Select the previous tab |
| `Ctrl+Shift+t` | Create a tab |
| `Ctrl+Shift+q` | Close the current tab |
| `Ctrl+Shift+.` / `Ctrl+Shift+,` | Move the tab forward/backward |
| `Ctrl+Shift+Alt+t` | Set the tab title |
| `Ctrl+Shift+l` | Cycle to the next Kitty window layout |

### Font, Display, and Configuration

| Key | Action |
|---|---|
| `Ctrl+Shift+=` / `Ctrl+Shift++` | Increase font size for the current OS window by 2 points |
| `Ctrl+Shift+-` / `Ctrl+Shift+Keypad -` | Decrease font size for the current OS window by 2 points |
| `Ctrl+Shift+Keypad +` | Increase font size for all Kitty OS windows by 2 points |
| `Ctrl+Shift+Backspace` | Reset font size in all Kitty OS windows |
| `Ctrl+Shift+F11` | Toggle fullscreen |
| `Ctrl+Shift+F10` | Toggle maximized state |
| `Ctrl+Shift+a`, then `m` / `l` | Increase/decrease background opacity |
| `Ctrl+Shift+a`, then `1` / `d` | Make the background opaque/reset configured opacity |
| `Ctrl+Shift+Delete` | Reset the active terminal |
| `Ctrl+Shift+F1` | Open Kitty documentation |
| `Ctrl+Shift+F2` | Edit `kitty.conf` |
| `Ctrl+Shift+F5` | Reload `kitty.conf` |
| `Ctrl+Shift+F6` | Show the effective Kitty configuration |
| `Ctrl+Shift+Escape` | Open the Kitty control shell in a new window |
| `Ctrl+Shift+u` | Open Unicode character input |

### Keyboard Hints

Kitty hints label text visible in the terminal so it can be selected without the mouse. The `Ctrl+Shift+p` bindings below are sequences.

| Key | Action |
|---|---|
| `Ctrl+Shift+e` | Label and open a visible URL |
| `Ctrl+Shift+p`, then `f` | Select a path and insert it at the prompt |
| `Ctrl+Shift+p`, then `Shift+f` | Select a path and open it |
| `Ctrl+Shift+p`, then `l` | Select a line and insert it |
| `Ctrl+Shift+p`, then `w` | Select a word and insert it |
| `Ctrl+Shift+p`, then `h` | Select a hash and insert it |
| `Ctrl+Shift+p`, then `n` | Select a `filename:line` reference and open it in the editor |
| `Ctrl+Shift+p`, then `y` | Select and open a terminal hyperlink |

The inherited tables above were generated from Kitty 0.43.1 on this workstation. Use `Ctrl+Shift+F6` after an upgrade to inspect the exact effective map.

## tmux

Source: [`tmux/.config/tmux/tmux.conf`](tmux/.config/tmux/tmux.conf)

tmux keeps long-running terminal work in **sessions**. A session contains numbered **windows**, and a window contains one or more **panes**. Detaching leaves programs running; attaching later restores the same terminal workspace.

Most commands begin with `Prefix`, which is `Alt+Tab`: press and release `Alt+Tab`, then press the command key. Prefix commands do not require holding `Alt+Tab` while pressing the second key.

### Common Workflows

| Goal | Sequence |
|---|---|
| Create and name a window | `Prefix`, then `Enter`; `Prefix`, then `,` |
| Split and move between panes | `Prefix`, then `v`; use `Prefix+h/j/k/l` |
| Temporarily enlarge a pane | `Prefix`, then `z`; repeat to restore |
| Switch between two recent windows | `Prefix`, then `Tab` |
| Detach while leaving programs running | `Prefix`, then `d` |
| Copy terminal output | `Prefix`, then `[`, select with vi keys, then `Enter` |
| Paste tmux's copied buffer | `Prefix`, then `]` |
| Paste the desktop clipboard directly | `Ctrl+Shift+v` through Kitty |
| Discover a forgotten command | `Prefix`, then `?` |

### Repository Bindings

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

### Retained Prefix Defaults: Sessions and Discovery

These are tmux 3.7b defaults that remain active after loading the repository configuration.

| Key | Action |
|---|---|
| `Prefix`, then `$` | Rename the current session |
| `Prefix`, then `)` | Switch to the next attached client |
| `Prefix`, then `d` | Detach the current client |
| `Prefix`, then `D` | Choose a client to detach |
| `Prefix`, then `L` | Switch to the last client |
| `Prefix`, then `Ctrl+z` | Suspend the tmux client |
| `Prefix`, then `?` | Show the complete effective key table |
| `Prefix`, then `/` | Describe the binding for a prompted key |
| `Prefix`, then `:` | Open the tmux command prompt |
| `Prefix`, then `C` | Open customize mode |
| `Prefix`, then `i` | Display current window/pane information |
| `Prefix`, then `~` | Show tmux messages |
| `Prefix`, then `r` | Refresh the client |
| `Prefix`, then `Delete` | Run `refresh-client -c` |
| `Prefix`, then `Shift+Arrow` | Pan the client viewport by ten cells |

### Retained Prefix Defaults: Windows and Panes

| Key | Action |
|---|---|
| `Prefix`, then `c` | Create a window; equivalent to configured `Enter` |
| `Prefix`, then `0` ... `9` | Select numbered window 0 ... 9; digits require `Shift` on French AZERTY |
| `Prefix`, then `n` / `p` | Select the next/previous window |
| `Prefix`, then `Alt+n` / `Alt+p` | Select the next/previous window with activity |
| `Prefix`, then `f` | Find a window by name or contents |
| `Prefix`, then `w` | Open the window/session tree chooser |
| `Prefix`, then `,` | Rename the current window |
| `Prefix`, then `.` | Move the current window to a prompted index |
| `Prefix`, then `<` | Open the window menu |
| `Prefix`, then `Space` | Cycle to the next pane layout |
| `Prefix`, then `Alt+1` ... `Alt+7` | Select an even, main, tiled, or mirrored layout |
| `Prefix`, then `E` | Spread panes evenly |
| `Prefix`, then `%` | Split the current pane left/right |
| `Prefix`, then `!` | Break the current pane into a new window |
| `Prefix`, then `*` | Run tmux's `new-pane` action |
| `Prefix`, then `o` | Focus the next pane |
| `Prefix`, then `;` | Focus the previously active pane |
| `Prefix`, then `Arrow` | Focus the pane in that direction |
| `Prefix`, then `x` | Confirm, then kill the current pane |
| `Prefix`, then `z` | Zoom/unzoom the current pane |
| `Prefix`, then `{` / `}` | Swap the current pane upward/downward |
| `Prefix`, then `Ctrl+o` / `Alt+o` | Rotate panes upward/downward |
| `Prefix`, then `m` / `M` | Mark the current pane |
| `Prefix`, then `>` | Open the pane menu |
| `Prefix`, then `Ctrl+Arrow` | Resize the pane by one cell |
| `Prefix`, then `Alt+Arrow` | Resize the pane by five cells |
| `Prefix`, then `Ctrl+b` | Send tmux's compatibility prefix to the application |

Configured AZERTY keys override some punctuation defaults. In particular, `Prefix+&`, `Prefix+"`, `Prefix+'`, `Prefix+(`, and `Prefix+-` select windows instead of running their stock tmux actions; `Prefix+q` kills the window instead of displaying pane numbers; and `Prefix+s` prompts for a window swap instead of opening the tree chooser.

### Copy Mode and tmux Buffers

Enter copy mode with `Prefix+[`. The pane stops following live output and uses the `copy-mode-vi` table. A basic copy is: move to the start, press `Space`, extend the selection, then press `Enter`. tmux stores the text in its paste buffer and, with `set-clipboard on`, forwards the copy to Kitty through OSC 52.

| Key in copy mode | Action |
|---|---|
| `q`, `Ctrl+c` | Leave copy mode |
| `Escape` or `Ctrl+[` | Clear the current selection |
| `Space` | Begin a character selection |
| `V` | Select the current line |
| `v` or `Ctrl+v` | Toggle rectangular selection |
| `o` | Move the cursor to the other end of the selection |
| `Enter` or `Ctrl+j` | Copy the selection and leave copy mode |
| `A` | Append the selection to a buffer and leave copy mode |
| `D` | Copy from the cursor to end of line and leave copy mode |
| Double left click | Copy the clicked word and leave copy mode |
| Triple left click | Copy the clicked line and leave copy mode |

### Copy-Mode Movement

| Key in copy mode | Action |
|---|---|
| `h/j/k/l` or arrows | Move left/down/up/right |
| `Backspace` or `Ctrl+h` | Move left |
| `0` / `^` | Move to line start/first nonblank character |
| `$` | Move to the end of the line |
| `Home` / `End` | Move to the start/end of the line |
| `w` / `b` | Move to the next/previous word |
| `e` | Move to the end of the next word |
| `W` / `B` | Move to the next/previous whitespace-delimited word |
| `E` | Move to the end of the next whitespace-delimited word |
| `f{char}` / `F{char}` | Jump forward/backward to a character |
| `t{char}` / `T{char}` | Jump just before a character forward/backward |
| `;` / `,` | Repeat/reverse the last character jump |
| `%` | Jump to the next matching bracket |
| `{` / `}` | Move to the previous/next paragraph |
| `H` / `M` / `L` | Move to the top/middle/bottom visible line |
| `g` / `G` | Go to the top/bottom of history |
| `Page Up` / `Page Down` | Move one page up/down |
| `Ctrl+b` / `Ctrl+f` | Move one page up/down |
| `Ctrl+u` / `Ctrl+d` | Move half a page up/down |
| `Ctrl+y` / `Ctrl+e` | Scroll one line up/down |
| `K` / `J` | Scroll one line up/down |
| `z` | Center the cursor line |
| `1` ... `9`, then a command | Apply a repeat count |

### Copy-Mode Search and Marks

| Key in copy mode | Action |
|---|---|
| `/text` / `?text` | Search forward/backward |
| `n` / `N` | Repeat the search forward/reverse |
| `*` / `#` | Search forward/backward for the word under the cursor |
| `:number` | Go to a history line |
| `X` | Set a mark |
| `Alt+x` | Jump to the mark |
| `P` | Toggle between the current and previous cursor positions |
| `r` | Refresh history from the live pane |

Outside copy mode, `Prefix+#` lists paste buffers, `Prefix+=` opens the buffer chooser, and `Prefix+]` pastes the latest tmux buffer. Desktop clipboard paste is separate: use Kitty's `Ctrl+Shift+v`.

### Mouse

Mouse mode is enabled.

| Gesture | Action |
|---|---|
| Left click in a pane | Focus that pane and forward the click when appropriate |
| Left click a status-line window | Select that window |
| Drag a pane border | Resize the pane |
| Mouse wheel | Scroll; enter copy mode when the application has not captured the mouse |
| Double/triple left click in copy mode | Copy the word/line |
| Middle click | Paste a tmux buffer where supported |
| Right click a pane or status item | Open the contextual tmux menu |

### Plugin Bindings

| Key | Plugin action |
|---|---|
| `Prefix`, then `I` | Install TPM plugins |
| `Prefix`, then `U` | Update TPM plugins |
| `Prefix`, then `Alt+u` | Remove plugins no longer listed in the configuration |
| `Prefix`, then `Ctrl+s` | Save the session with tmux-resurrect |
| `Prefix`, then `Ctrl+r` | Restore the session with tmux-resurrect |

tmux-continuum automatically saves and restores sessions and does not add a normal workflow key. Run `Prefix+?` to inspect the authoritative effective table after tmux or plugin upgrades.

## Bash and fzf

Sources: [`bash/.bashrc`](bash/.bashrc) and [`bash/.fzf.bash`](bash/.fzf.bash)

Bash is the configured fallback interactive shell. It uses GNU Readline's Emacs editing mode unless a machine-local `~/.inputrc` changes it, and this repository loads fzf's generated Bash integration. Unlike Fish's modal prompt, the normal Bash prompt is always ready for text entry; `Alt` combinations handle word movement and `Ctrl` combinations handle characters, history, deletion, and completion.

The tables below match Bash 5.3 and fzf 0.74 on the inspected workstation. Run `bind -P` for the effective Readline functions, `bind -S` for macros, and `fzf --bash` to inspect the generated fzf integration after an upgrade.

### Common Workflows

| Goal | Sequence |
|---|---|
| Run a command | Type it, then press `Enter` |
| Complete a command, option, or path | Type a prefix, then press `Tab`; repeat or choose a result |
| Search command history | `Ctrl+r`, type a query in fzf, then press `Enter` |
| Insert one or more paths | `Ctrl+t`, find and select paths, then press `Enter` |
| Change to a recently found directory | `Alt+c`, find a directory, then press `Enter` |
| Correct the previous command | `Up`, edit it, then press `Enter` |
| Cancel the current command line | `Ctrl+c` |
| Paste text removed with a Readline command | `Ctrl+y` |
| Edit a long command in an external editor | `Ctrl+x`, then `Ctrl+e` |
| Inspect every active Readline function | Run `bind -P` |

### Movement and Submission

| Key | Action |
|---|---|
| `Enter`, `Ctrl+j`, or `Ctrl+m` | Submit the command line |
| `Ctrl+a` or `Home` | Move to the beginning of the line |
| `Ctrl+e` or `End` | Move to the end of the line |
| `Ctrl+b` or `Left` | Move back one character |
| `Ctrl+f` or `Right` | Move forward one character |
| `Alt+b` / `Alt+f` | Move back/forward one word |
| `Ctrl+xx` | Exchange the cursor and the saved mark |
| `Ctrl+]`, then a character | Move forward to that character |
| `Alt+Ctrl+]`, then a character | Move backward to that character |
| `Ctrl+q` or `Ctrl+v`, then a key | Insert the next key literally |
| `Ctrl+c` | Cancel the current line or interrupt the foreground command |
| `Ctrl+g` | Abort the current Readline command or incremental search |
| `Ctrl+d` on an empty line | Send end-of-file and exit an interactive Bash shell |

### Editing and the Kill Ring

Readline calls cut text **killed** text and stores it in a kill ring. `Ctrl+y` yanks, or pastes, the newest entry; `Alt+y` rotates through older entries immediately after a yank.

| Key | Action |
|---|---|
| `Backspace` or `Ctrl+h` | Delete the character before the cursor |
| `Delete` or `Ctrl+d` | Delete the character under the cursor |
| `Ctrl+u` | Cut from the cursor to the beginning of the line |
| `Ctrl+k` | Cut from the cursor to the end of the line |
| `Ctrl+w` | Cut the previous whitespace-delimited word |
| `Alt+Backspace` | Cut the previous Readline word |
| `Alt+d` | Cut the next word |
| `Ctrl+y` | Paste the latest kill-ring entry |
| `Alt+y` | Replace the last yank with the previous kill-ring entry |
| `Ctrl+t` | Normally transpose characters, but fzf overrides it to find and insert paths |
| `Alt+t` | Transpose the current and previous word |
| `Alt+u` / `Alt+l` / `Alt+c` | Uppercase/lowercase/capitalize the next word; `Alt+c` is overridden by fzf to find and enter a directory |
| `Ctrl+_` or `Ctrl+x`, then `Ctrl+u` | Undo the last Readline edit |
| `Alt+r` | Revert the line to the version taken from history |
| `Alt+\` | Delete horizontal whitespace around the cursor |
| `Alt+#` | Comment the line and submit it to history without executing it |
| `Ctrl+x`, then `Ctrl+e` | Edit the command in `$VISUAL` or `$EDITOR`, then execute it |

Kitty still owns terminal-level clipboard operations: use `Ctrl+Shift+c` to copy a terminal selection and `Ctrl+Shift+v` to paste the desktop clipboard at the Bash prompt.

### History and Arguments

| Key | Action |
|---|---|
| `Up` or `Ctrl+p` | Load the previous history entry |
| `Down` or `Ctrl+n` | Load the next history entry |
| `Ctrl+r` | Open fzf history search; replaces Readline's normal reverse incremental search |
| `Ctrl+s` | Search history forward when terminal flow control does not consume the key |
| `Alt+p` / `Alt+n` | Search backward/forward for a history entry beginning with the text already typed |
| `Ctrl+o` | Execute the current history entry and prepare the following entry |
| `Alt+.` or `Alt+_` | Insert the last argument of the previous command; repeat to walk farther back |
| `Alt+Ctrl+y` | Insert the first argument of the previous command |
| `Ctrl+x`, then `Ctrl+r` | Reload the Readline initialization file |

### Completion and Expansion

| Key | Action |
|---|---|
| `Tab` or `Alt+Ctrl+i` | Complete the current command, option, variable, user, host, or path |
| `Alt+?` | List possible completions without changing the line |
| `Alt+*` | Insert every possible completion |
| `Alt+/` | Complete a filename |
| `Alt+~` | Complete a username |
| `Alt+$` | Complete a shell variable |
| `Alt+@` | Complete a hostname |
| `Alt+!` | Complete a command name |
| `Alt+{` | Complete a filename into a brace expansion when several matches exist |
| `Alt+g` | Expand the pathname pattern at the cursor into matching words |
| `Ctrl+x`, then `*` | Expand the pathname pattern at the cursor |
| `Ctrl+x`, then `g` | List matches for the pathname pattern at the cursor |
| `Alt+Ctrl+e` | Perform shell aliases, history, parameter, command, arithmetic, and filename expansion on the line |
| `Ctrl+x`, then `Ctrl+v` | Display the Bash version |

### fzf Shell Widgets

The repository evaluates `fzf --bash`, which installs these bindings into Readline. They work in Bash's Emacs and vi keymaps, though this Bash setup starts in Emacs mode.

| Key | Action |
|---|---|
| `Ctrl+t` | Search files and directories, then insert the selected paths into the command line |
| `Ctrl+r` | Search command history, then replace the command line with the selected entry |
| `Alt+c` | Search directories, change to the selected directory, and redraw the prompt |

Inside any of those fzf pickers:

| Key or gesture | Action |
|---|---|
| Type text | Filter candidates by the query |
| `Up` / `Ctrl+k` / `Ctrl+p` | Select the previous match |
| `Down` / `Ctrl+j` / `Ctrl+n` | Select the next match |
| `Page Up` / `Page Down` | Move one result page up/down |
| `Tab` / `Shift+Tab` | Toggle the current selection and move down/up; useful in the `Ctrl+t` multi-picker |
| `Enter` or double left click | Accept the current selection |
| `Escape`, `Ctrl+c`, `Ctrl+g`, or `Ctrl+q` | Abort the picker |
| `Ctrl+a` / `Ctrl+e` or `Home` / `End` | Move to the beginning/end of the query |
| `Backspace` or `Ctrl+h` | Delete the previous query character |
| `Delete` or `Ctrl+d` | Delete the next query character |
| `Ctrl+u` / `Ctrl+w` | Delete to the start of the query / delete the previous query word |
| `Ctrl+r` in history search | Toggle result sorting |
| `Alt+r` in history search | Toggle the raw history display |
| `Shift+Delete` in history search | Remove the selected entries from shell history |
| Left click / scroll wheel | Select a visible row / move through results |
| Right click | Toggle the current item in a multi-selection picker |

## Fish and fzf

Sources: [`fish/.config/fish/config.fish`](fish/.config/fish/config.fish) and [`fish/.config/fish/functions/fish_user_key_bindings.fish`](fish/.config/fish/functions/fish_user_key_bindings.fish)

Fish starts with its standard vi bindings in **Insert mode**, so a new prompt accepts normal typing immediately. Press `Escape` to enter **Command mode**, where movement and editing work like a compact Vim command line. Press `i` to return to Insert mode.

### Changing Modes and Running Commands

| Key | Starting mode | Action |
|---|---|---|
| `Escape` or `Ctrl+[` | Insert | Enter Command mode |
| `i` / `a` | Command | Insert at the cursor/after the cursor |
| `I` / `A` | Command | Insert at the beginning/end of the line |
| `o` / `O` | Command | Open a line below/above and enter Insert mode |
| `v` | Command | Start Visual selection |
| `r`, then a character | Command | Replace one character and return to Command mode |
| `Escape` or `Ctrl+c` | Visual | Return to Command mode |
| `Enter`, `Ctrl+j`, or `Ctrl+m` | Any normal prompt mode | Execute a complete command, or continue an incomplete block |
| `Alt+Enter` | Insert | Insert a newline without executing |
| `:q` | Command | Exit Fish |
| `Ctrl+d` | Empty command line | Exit Fish |

### Shared Editing and Shell Keys

These work in Fish's vi modes unless a mode-specific command overrides them.

| Key | Action |
|---|---|
| `Left` / `Right` | Move one character; `Right` at line end accepts an autosuggestion |
| `Alt+Left` / `Alt+Right` | Move one word, or navigate directory history on an empty line |
| `Ctrl+Left` / `Ctrl+Right` | Move one shell token; accept that token from an autosuggestion |
| `Shift+Left` / `Shift+Right` | Move one big word; accept that part of an autosuggestion |
| `Up` / `Down` | Search backward/forward through matching command history |
| `Alt+Up` / `Alt+Down` | Search history for the previous/next matching token |
| `Ctrl+c` | Interrupt the running command; at a vi command prompt, clear the line and enter Insert mode |
| `Ctrl+d` | Delete the next character, or exit on an empty line |
| `Ctrl+u` | Cut from the cursor to the beginning of the line |
| `Ctrl+w` | Cut the previous path component |
| `Ctrl+l` | Move the screen into scrollback, clear, and repaint |
| `Ctrl+Space` | Insert a literal space without expanding an abbreviation |
| `Ctrl+x` / `Ctrl+v` | Copy the command buffer to/paste from the system clipboard |
| `Alt+d` / `Ctrl+Delete` | Cut the next word |
| `Alt+Delete` | Cut the next shell argument |
| `Shift+Delete` | Remove the current history item or autosuggestion |
| `Alt+e` or `Alt+v` | Edit the command line in `$VISUAL` or `$EDITOR` |
| `Alt+h` or `F1` | Show the manual page for the command under the cursor |
| `Alt+l` | List the directory under the cursor, or the current directory |
| `Alt+o` | Open the file or script under the cursor |
| `Alt+p` | Append a pager pipeline to the current job |
| `Alt+w` | Show a short description of the command under the cursor |
| `Alt+s` | Prepend `sudo`, `doas`, `please`, or `run0` |

`Ctrl+t` is explicitly erased by the tracked configuration, so Fish performs no action for it even if a preset or integration would normally claim it.

### Command-Mode Movement

| Key | Action |
|---|---|
| `h` / `l` | Move left/right |
| `j` / `k` | Search newer/older history; move down/up in multiline input |
| `0`, `^`, `_`, or `g^` | Move to the beginning/first nonblank part of the line |
| `$` or `g$` | Move to the end of the line |
| `gg` / `G` | Move to the beginning/end of the whole command buffer |
| `w` / `b` | Move to the next/previous word |
| `e` | Move to the end of the next word |
| `W` / `B` / `E` | Move by whitespace-delimited WORDs |
| `ge` / `gE` | Move to the previous word/WORD |
| `f{char}` / `F{char}` | Jump forward/backward to a character |
| `t{char}` / `T{char}` | Jump just before a character forward/backward |
| `;` / `,` | Repeat/reverse the last character jump |
| `%` | Jump to the matching bracket |
| `[` / `]` | Search for the previous/next history token matching the token under the cursor |
| `/` | Open searchable command history in the completion pager |
| `Backspace` or `Ctrl+h` | Move left without deleting |

### Copy, Cut, Change, and Paste

Fish has an internal **kill ring**, separate from the desktop clipboard. `y` copies into it, `d` cuts into it, and `p` pastes from it. Operators combine with motions in the same order as Vim: `dw` means cut through the next word, and `ciw` means replace the current word.

| Key | Action |
|---|---|
| `yy` or `Y` | Copy the whole command line to the kill ring |
| `y{motion}` | Copy through a motion: `$`, `^`, `0`, `w`, `W`, `e`, `E`, `b`, `B`, `ge`, `gE`, `f`, `F`, `t`, or `T` |
| `yiw` / `yiW` | Copy the current word/WORD |
| `yaw` / `yaW` | Copy around the current word/WORD |
| `dd` | Cut the whole command line |
| `D` or `d$` | Cut from the cursor to the end of the line |
| `d^` or `d0` | Cut from the cursor to the beginning of the line |
| `d{motion}` | Cut through a supported motion |
| `diw` / `diW` | Cut the current word/WORD |
| `daw` / `daW` | Cut around the current word/WORD |
| `dib` / `dab` | Cut inside/around matching brackets |
| `x` / `X` | Cut the character under/before the cursor |
| `cc` or `S` | Replace the whole inner command line and enter Insert mode |
| `C` or `c$` | Replace to the end of the line and enter Insert mode |
| `c{motion}` | Cut through a supported motion and enter Insert mode |
| `ciw` / `ciW` | Replace the current word/WORD |
| `caw` / `caW` | Replace around the current word/WORD |
| `cib` / `cab` | Replace inside/around matching brackets |
| `s` | Replace the current character and enter Insert mode |
| `p` / `P` | Paste the latest kill-ring entry after/at the cursor |
| `gp` | Rotate to the previous kill-ring entry after pasting |
| `"*yy` or `"+yy` | Copy the whole command line to the system clipboard |
| `"*p` / `"+p` | Paste the system clipboard after the cursor |
| `"*P` / `"+P` | Paste the system clipboard at the cursor |

The system clipboard commands require one of Fish's supported clipboard tools, such as `xclip` or `xsel` under X11. Kitty's `Ctrl+Shift+c` and `Ctrl+Shift+v` remain available for terminal-level copy and paste.

### Undo, Case, and Line Operations

| Key | Action |
|---|---|
| `u` / `Ctrl+r` | Undo/redo the last command-line edit |
| `~` | Toggle the current character's case and move right |
| `gu` / `gU` | Lowercase/uppercase to the end of the word |
| `J` | Join the next line to the current line |
| `K` | Show the manual page for the token under the cursor |

### Visual Mode

Press `v` in Command mode, move to extend the selection, then choose an operation.

| Key in Visual mode | Action |
|---|---|
| `h/j/k/l` or arrows | Extend the selection left/down/up/right |
| `b` / `w` | Extend to the previous/next word |
| `d` or `x` | Cut the selection to the kill ring and return to Command mode |
| `c` or `s` | Cut the selection and enter Insert mode |
| `X` | Cut the entire line and enter Command mode |
| `y` | Copy the selection to the kill ring and return to Command mode |
| `"*y` | Copy the selection to the system clipboard |
| `~` | Toggle the selected text's case |
| `gu` / `gU` | Lowercase/uppercase the selection |
| `Escape` or `Ctrl+c` | Cancel selection and return to Command mode |

### Autosuggestions, History, and Completion

| Key | Action |
|---|---|
| `Right` or `Ctrl+f` at line end | Accept the complete autosuggestion |
| `Alt+Right` or `Alt+f` at line end | Accept the next suggested word |
| `Ctrl+Right` | Accept the next suggested shell token |
| `Ctrl+n` in Insert mode | Accept the complete autosuggestion |
| `Up` / `Down` | Search command history using the text already typed |
| `Alt+Up` / `Alt+Down` | Search history using the token under the cursor |
| `/` in Command mode | Open the searchable history pager |
| `Ctrl+r` in normal Emacs-style contexts | Open history search; in Fish vi Command mode it is redo |
| `Tab` | Complete the current token or open the completion pager |
| `Shift+Tab` | Complete and start pager search |
| Arrows, `Page Up`, or `Page Down` | Navigate completion choices |
| `Ctrl+s`, or `/` in vi pager contexts | Toggle filtering/search in the completion pager |
| `Escape` | Cancel the pager or current completion operation |

### fzf Integration Status

The tracked `fish_user_key_bindings` helper would source fzf's generated bindings, but the current startup sequence never calls that helper. These keys are therefore **inactive by default**:

| Inactive key | Would perform |
|---|---|
| `Ctrl+r` | Search command history with fzf |
| `Ctrl+t` | Search files with fzf; also conflicts with the explicit erase |
| `Alt+c` | Search directories with fzf |
| `Shift+Tab` | Trigger the fzf completion integration |

The active tables above come from Fish 4.2.0's embedded `fish_vi_key_bindings` plus the tracked `Ctrl+t` erase. Run `bind --all` in an interactive Fish session to inspect the effective map after an upgrade.

## Neovim

Sources: [`nvim/.config/nvim/lua/config/keymaps.lua`](nvim/.config/nvim/lua/config/keymaps.lua), [`nvim/.config/nvim/lua/plugins/editor/which-key.lua`](nvim/.config/nvim/lua/plugins/editor/which-key.lua), and the plugin files named in each subsection.

Modes are abbreviated as Normal, Insert, Visual, Select, Command, and Terminal. `Leader` is `Space`.

Neovim commands are usually sequences. For example, `Leader+fk` means press `Space`, then `f`, then `k`; `ciw` means press `c`, then `i`, then `w`. Do not hold the keys together unless modifiers such as `Ctrl` or `Shift` are shown.

### Changing Modes

Neovim starts in Normal mode. Use Normal mode for navigation and commands, then enter another mode only for the operation being performed.

| Key | Starting mode | Result |
|---|---|---|
| `Escape` or `Caps Lock` | Any editing mode | Return to Normal mode |
| `i` | Normal | Insert before the cursor |
| `a` | Normal | Insert after the cursor |
| `I` | Normal | Insert at the first nonblank character of the line |
| `A` | Normal | Insert at the end of the line |
| `o` | Normal | Open a new line below and enter Insert mode |
| `O` | Normal | Open a new line above and enter Insert mode |
| `v` | Normal | Start character-wise Visual selection |
| `V` | Normal | Start line-wise Visual selection |
| `Ctrl+v` | Normal | Start block-wise Visual selection |
| `R` | Normal | Enter Replace mode and overwrite text as you type |
| `:` | Normal | Enter Command-line mode |
| `Ctrl+\`, then `Ctrl+n` | Terminal | Return to Terminal-Normal mode; plain `Escape` already does this in configured non-Yazi terminals |

In Visual mode, move the cursor to extend the selection, press `o` to switch which end is active, `gv` to reselect the last selection, or `Escape` to cancel.

### Basic Movement

Motions can be used by themselves or after an operator such as `y`, `d`, or `c`.

| Key | Action |
|---|---|
| `h/j/k/l` | Move left/down/up/right |
| `w` / `b` | Move to the next/previous word start |
| `e` | Move to the end of the word |
| `0` / `^` | Move to the first column/first nonblank character |
| `$` | Move to the end of the line |
| `gg` / `G` | Go to the first/last line |
| `{` / `}` | Go to the previous/next paragraph |
| `%` | Jump between matching brackets |
| `f{character}` / `F{character}` | Find a character forward/backward on the current line |
| `t{character}` / `T{character}` | Move just before a character forward/backward |
| `Ctrl+o` / `Ctrl+i` | Move backward/forward through the jump list |

A number repeats a command or motion: `5j` moves down five lines, `3w` moves forward three words, and `2dd` cuts two lines.

### Text Objects

Text objects select meaningful regions without manually positioning both ends. Use `i` for **inside** and `a` for **around**, including delimiters or surrounding whitespace.

| Text object | Region |
|---|---|
| `iw` / `aw` | Inner word/around word |
| `is` / `as` | Inner sentence/around sentence |
| `ip` / `ap` | Inner paragraph/around paragraph |
| `i"` / `a"` | Text inside/around double quotes |
| `i'` / `a'` | Text inside/around single quotes |
| `i)` / `a)` | Text inside/around parentheses |
| `i]` / `a]` | Text inside/around square brackets |
| `i}` / `a}` | Text inside/around braces |

Combine an operator with a text object: `yiw` copies the current word, `di"` cuts inside quotes, and `ci)` replaces the contents of parentheses.

### Copy, Cut, Change, and Paste

Vim calls copying **yanking**. Delete and change operations also save removed text in a register, so they behave like cutting. This configuration routes the standard `y`, `p`, and `P` operations through Yanky and keeps a 50-entry in-memory yank history.

| Key | Mode | Action |
|---|---|---|
| `yy` | Normal | Copy the current line |
| `Y` | Normal | Copy from the cursor to the end of the line |
| `y{motion}` | Normal | Copy through a motion, such as `yw`, `y$`, or `y}` |
| `y` | Visual | Copy the selection and return to Normal mode |
| `dd` | Normal | Cut the current line |
| `d{motion}` | Normal | Cut through a motion, such as `dw`, `d$`, or `dG` |
| `d` or `x` | Visual | Cut the selection |
| `x` / `X` | Normal | Cut the character under/before the cursor |
| `cc` | Normal | Cut the current line and enter Insert mode |
| `c{motion}` | Normal | Cut through a motion and enter Insert mode |
| `c` | Visual | Replace the selection by entering Insert mode |
| `s` / `S` | Normal | Replace the current character/current line |
| `p` / `P` | Normal | Paste after/before the cursor or current line |
| `p` / `P` | Visual | Replace the selection with the copied text |
| `gp` / `gP` | Normal | Paste after/before and leave the cursor after the inserted text |
| `Leader+fy` | Normal | Browse and restore entries from Yanky's history |

Common examples:

| Sequence | Action |
|---|---|
| `viw`, then `y` | Select and copy the current word |
| `V`, move with `j/k`, then `y` | Select and copy complete lines |
| `Ctrl+v`, move, then `y` | Copy a rectangular block |
| `diw` | Cut the current word |
| `ciw` | Replace the current word and enter Insert mode |
| `daw` | Cut the current word and its surrounding whitespace |
| `yyp` | Duplicate the current line below |
| `ddp` | Move the current line down |
| `ddkP` | Move the current line up |

### System Clipboard and Registers

Source: [`nvim/.config/nvim/lua/config/options.lua`](nvim/.config/nvim/lua/config/options.lua)

Clipboard behavior changes depending on whether Neovim is running inside tmux:

- **Outside tmux:** `clipboard=unnamedplus`, so ordinary `y`, `d`, `c`, `p`, and `P` use the desktop clipboard by default.
- **Inside tmux:** ordinary edits use Neovim's unnamed register to avoid an OSC 52 write on every delete. Use the explicit `+` register to copy to the desktop clipboard: `"+y`, `"+yy`, or `"+y{motion}`.
- **Pasting external clipboard text inside tmux:** enter Insert mode and press `Ctrl+Shift+v` so Kitty performs the paste. OSC 52 cannot read the desktop clipboard, so `"+p` falls back to Neovim's unnamed register in this setup.

The `"` key chooses a register for the next operation. It is a prefix, so `"+yy` means press `"`, then `+`, then `y`, then `y`.

| Register sequence | Action |
|---|---|
| `"+y{motion}` / `"+yy` | Copy to the desktop clipboard explicitly |
| `"+p` / `"+P` | Paste from the desktop clipboard outside tmux |
| `"0p` | Paste the most recently yanked text, ignoring later deletes |
| `"ayy` / `"ap` | Copy a line into named register `a`/paste register `a` |
| `"_d{motion}` | Delete into the black-hole register without replacing copied text |
| `:registers` | Display register contents |
| `Leader+fr` | Search registers with Telescope |

### Undo, Repeat, and Search

| Key | Action |
|---|---|
| `u` | Undo the last change |
| `Ctrl+r` | Redo the last undone change |
| `.` | Repeat the last change |
| `/text`, then `Enter` | Search forward for `text` |
| `?text`, then `Enter` | Search backward for `text` |
| `n` / `N` | Go to the next/previous match |
| `*` / `#` | Search forward/backward for the word under the cursor |
| `Enter` | Clear search highlighting in Normal mode |
| `:%s/old/new/g` | Replace every `old` with `new` in the file |
| `:%s/old/new/gc` | Replace throughout the file and confirm each match |
| `:'<,'>s/old/new/g` | Replace within the current Visual selection |

Use `:earlier 5m` to return to the file state from five minutes ago and `:later 5m` to move forward again. Persistent undo is enabled, so undo history survives reopening a file.

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

Yazi has a three-column manager: the parent directory is on the left, the current directory is in the center, and the hovered file's preview or child directory is on the right. The cursor **hovers** one entry; operations apply to the selected entries when a selection exists, otherwise they apply to the hovered entry.

Use `j/k` to move, `h/l` to leave or enter a directory, and `Enter` to open a file. `Space` builds a non-contiguous selection one file at a time. `v` starts continuous selection mode, while `Escape` clears the selection or cancels the current operation. Press `F1` or `~` in any Yazi view to inspect the effective bindings for the installed version.

### Common Workflows

| Goal | Sequence |
|---|---|
| Open the hovered directory or file | `l` or `Enter` |
| Choose which application opens a file | `O` or `Shift+Enter` |
| Select several separate files | Hover each file and press `Space` |
| Select a continuous range | `v`, move with `j/k`, then `Escape` when finished |
| Copy files into another directory | Select files, press `y`, navigate to the destination, then press `p` |
| Move files into another directory | Select files, press `x`, navigate to the destination, then press `p` |
| Copy a file path as text | Hover the file, then press `cc` |
| Copy files to the desktop clipboard | Select files, then press `Ctrl+y` |
| Create a directory | Press `a`, type a name ending in `/`, then press `Enter` |
| Rename a file without replacing its extension | Press `r`, edit the name, then press `Enter` |
| Trash files | Select files, press `d`, then confirm with `y` or `Enter` |
| Permanently delete files | Select files, press `D`, then confirm with `y` or `Enter` |
| Search names below the current directory | Press `s`, type a query, then press `Enter` |
| Search file contents | Press `S`, type a query, then press `Enter` |
| Narrow only the current directory listing | Press `f` and type; submit with `Enter` or cancel with `Escape` |
| Jump anywhere with fzf or zoxide | Press `z` for files/directories or `Z` for directories |
| Inspect metadata without opening a file | Press `Tab`; use `j/k` and close with `Tab` or `Escape` |
| Open a second directory in another tab | Press `t`, navigate there, then switch with `[` / `]` |

Yazi's file yank is not text copying: `y` records files for a later `p`, and `x` records them as a move. Use `cc`, `cf`, `cn`, or `cd` to copy path text. Use `Ctrl+y` when another desktop application needs the selected files through the system clipboard.

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

Zathura is a Vim-like document viewer. It opens documents in best-fit mode, recolors them for the configured dark theme, and copies mouse-selected text to the desktop clipboard. Normal mode handles reading; the index, fullscreen, presentation, command-line, search, and link-hint interfaces temporarily change what keys do.

### Common Workflows

| Goal | Sequence |
|---|---|
| Read page by page | `J` / `K` for the next/previous page |
| Scroll within a page | `h/j/k/l`, arrows, or `Ctrl+d` / `Ctrl+u` |
| Fit the whole page or page width | `a` for best fit; `s` for width |
| Jump to a page | Type the page number, then `G` |
| Search the document | `/`, type text, press `Enter`, then use `n` / `N` |
| Follow a link without the mouse | `f`, type the displayed link label, then press `Enter` |
| Copy document text | Left-drag to select; the text is copied to the desktop clipboard |
| Open the table of contents | `Space`; choose with `j/k` and `Enter`; `Space` again closes it |
| Remember and revisit a position | `m`, then a letter/number; later press `'`, then the same key |
| Present the document | `F5`; use `Space` / `Shift+Space`; press `F5` to leave |
| Toggle fullscreen reading | `Ctrl+v` or `F11`; press `F11` to leave |
| Restore after an accidental command | `Escape` or `Ctrl+c` |

### Repository Bindings

| Key | Action |
|---|---|
| `Space` | Toggle the document index |
| `p` | Print |
| `w` | Toggle recoloring |
| `k` / `j` | Scroll up/down |
| `Ctrl+v` | Toggle fullscreen |

These mappings replace any upstream action on the same key. In particular, upstream Zathura uses `Space` to scroll a full page down; in this setup use `Ctrl+f` for that action. The alternate theme files additionally map `K` / `J` to zoom in/out, but only when one of those files is explicitly loaded as the configuration.

### Normal-Mode Navigation

| Key | Action |
|---|---|
| `h/j/k/l` or arrows | Scroll left/down/up/right |
| `Ctrl+t` / `Ctrl+y` | Scroll half a page left/right |
| `Ctrl+d` / `Ctrl+u` | Scroll half a page down/up |
| `t` / `y` | Scroll a full page left/right |
| `Ctrl+f` / `Ctrl+b` | Scroll a full page down/up |
| `Shift+Space` | Scroll a full page up |
| `J` / `K` or `Page Down` / `Page Up` | Go to the next/previous page |
| `gg` / `G` | Go to the first/last page |
| `{number}G` | Go to a numbered page |
| `P` | Snap the viewport to the current page |
| `H` / `L` | Go to the top/bottom of the current page |
| `Ctrl+o` / `Ctrl+i` | Move backward/forward through the jump list |
| `Ctrl+j` / `Ctrl+k` | Bisect forward/backward between the last two jump points |
| `Escape` or `Ctrl+c` | Abort the current operation and return to Normal mode |

### Search, Links, Marks, and Files

| Key | Action |
|---|---|
| `/text` / `?text` | Search forward/backward |
| `n` / `N` | Go to the next/previous search result |
| `f` | Label links, then follow the selected link |
| `F` | Label links and display the selected link target |
| `c` | Label links and copy the selected link target to the clipboard |
| `o` / `O` | Open a document through the input bar |
| `m{letter or number}` | Set a quickmark at the current position |
| `'{letter or number}` | Jump to a quickmark |
| `:` | Enter a Zathura command |
| `R` | Reload the document |
| `r` | Rotate clockwise by 90 degrees |
| `p` | Open the print dialog; repository binding |
| `q` | Quit Zathura |

Useful command-line commands include `:open`, `:write` or `:save`, `:print`, `:info`, `:bmark`, `:bdelete`, `:blist`, `:bjump`, `:delmarks`, `:jumplist`, `:source`, and `:quit`. Press `Tab` / `Shift+Tab` to move through command or path completions and `Escape` to cancel the input bar.

### View, Zoom, and Interface

| Key | Action |
|---|---|
| `a` / `s` | Fit the whole page / fit page width |
| `+` / `-` / `=` | Zoom in/out/reset to the original size |
| `zI` / `zO` / `z0` | Zoom in/out/reset to the original size |
| `{number}=` | Set zoom to an exact percentage |
| `w` or `Ctrl+r` | Toggle recoloring |
| `d` | Toggle single/dual-page view |
| `D` | Cycle which column contains the first page in multi-page view |
| `Space` | Toggle the document index; repository override |
| `Tab` | Show the document index and enter Index mode |
| `Ctrl+v` | Toggle fullscreen; repository binding |
| `F11` | Toggle fullscreen |
| `F5` | Enter Presentation mode |
| `Ctrl+m` | Toggle the input bar |
| `Ctrl+n` | Toggle the status bar |

### Index Mode

| Key | Action |
|---|---|
| `j` / `k` | Move to the next/previous index entry |
| `l` / `h` | Expand/collapse the current entry |
| `L` / `H` | Expand/collapse every entry |
| `Space` or `Enter` | Open the selected entry |
| `Escape` or `Ctrl+c` | Return to Normal mode |

### Fullscreen and Presentation Modes

| Key | Mode | Action |
|---|---|---|
| `J` / `K` | Fullscreen | Go to the next/previous page |
| `Space` / `Shift+Space` | Fullscreen, Presentation | Scroll a full page down/up |
| `gg` / `G` / `{number}G` | Fullscreen | Go to the first/last/numbered page |
| `+` / `-` / `=` | Fullscreen | Zoom in/out/reset |
| `zI` / `zO` / `z0` | Fullscreen | Zoom in/out/reset |
| `{number}=` | Fullscreen | Set an exact zoom percentage |
| `F11` | Fullscreen | Return to Normal mode |
| `F5` | Presentation | Return to Normal mode |
| `Escape` or `Ctrl+c` | Either | Abort the current operation |
| `q` | Either | Quit Zathura |

### Mouse and Clipboard

| Gesture | Action |
|---|---|
| Scroll wheel | Scroll up/down |
| `Ctrl`+scroll wheel | Zoom in/out |
| Middle-button drag | Pan the document |
| Left click | Follow a link |
| Left drag | Select text and copy it to the desktop clipboard |
| `Shift`+left drag | Highlight a rectangular region |
| `Ctrl`+left click | Run backward SyncTeX and open the source position in Neovim |
| Right click an exportable image | Open the image copy/save menu |

The clipboard behavior comes from `selection-clipboard clipboard`; paste the selected text in another application with that application's normal clipboard key, such as Kitty's `Ctrl+Shift+v`.

## sxiv Image Viewer

Sources: [`scripts/.local/bin/sxiv-tabbed`](scripts/.local/bin/sxiv-tabbed) and [`x11/.Xresources`](x11/.Xresources)

`sxiv-tabbed` is the default handler for common image files. It opens each requested image in the workspace's dedicated tabbed i3 container, then launches `sxiv` with its built-in controls; the wrapper does not remap viewer keys. `Super+w` can restore a tabbed i3 layout around image windows, and `Super+q` closes the focused viewer.

The tables below are the complete sxiv 26 defaults. The wrapper can fall back to `nsxiv` when sxiv is unavailable, but nsxiv has diverged and its runtime keys may differ; use `man nsxiv` on such a machine. Neither viewer was installed on the inspected machine, so the sxiv map is grounded in its v26 source rather than a local runtime.

### Common Workflows

| Goal | Sequence |
|---|---|
| View the next/previous image | `n` or `Space` / `p` or `Backspace` |
| Browse thumbnails | `Enter`, move with `h/j/k/l`, then `Enter` |
| Fit an image to the window | `W`; use `w` to avoid enlarging small images |
| Zoom and pan | `+` / `-`, then `h/j/k/l` |
| Rotate an image for viewing | `<` / `>` for 90 degrees; `?` for 180 degrees |
| Mark several images | Press `m` on each image; revisit them with `N` / `P` |
| Remove an image from the browsing list | `D`; this does not delete the file |
| Start a slideshow | `s`; use a count such as `5s` to set five seconds |
| Toggle fullscreen or the info bar | `f` / `b` |
| Close the viewer | `q`, or `Super+q` through i3 |

A number typed before a supported command is a count. For example, `5n` advances five images, `3]` advances 30 images, `50=` sets 50% zoom, and `8s` starts a slideshow with an eight-second delay.

### Global Controls

| Key | Action |
|---|---|
| `0` ... `9` | Build a numeric count for the next command |
| `q` | Quit sxiv |
| `Enter` | Switch between Image and Thumbnail modes; in Thumbnail mode, open the selected image |
| `f` | Toggle fullscreen |
| `b` | Toggle the information bar |
| `g` / `G` | Go to the first/last image; `{count}G` goes to a numbered image |
| `r` | Reload the current image |
| `D` | Remove the current image from sxiv's file list and advance; the file remains on disk |
| `Ctrl+h/j/k/l` or `Ctrl+Left/Down/Up/Right` | Scroll the viewport one screen left/down/up/right |
| `+` or keypad `+` / `-` or keypad `-` | Zoom in/out |
| `m` | Toggle the mark on the current image |
| `M` | Apply the last mark action to the range from the previous mark position to the current image |
| `Ctrl+m` | Reverse every image mark |
| `Ctrl+u` | Clear every image mark |
| `N` / `P` | Go to the next/previous marked image; accepts a count |
| `{` / `}` | Decrease/increase image gamma; accepts a count |
| `Ctrl+g` | Reset image gamma |
| `Ctrl+x`, then a key | Send that key and the current/marked file paths to sxiv's external key handler, when one is installed |
| `Escape` after `Ctrl+x` | Cancel the pending external-handler key |

### Image Mode

| Key | Action |
|---|---|
| `n` or `Space` | Go forward by one image or by the typed count |
| `p` or `Backspace` | Go backward by one image or by the typed count |
| `]` / `[` | Move forward/backward by ten times the typed count |
| `Ctrl+6` | Switch to the previously viewed image |
| `h/j/k/l` or arrows | Pan left/down/up/right; a count pans by that many pixels |
| `H/J/K/L` | Pan to the left/bottom/top/right edge |
| `=` | Set zoom to 100%; a count sets an exact percentage |
| `w` | Scale down to fit the window without enlarging small images |
| `W` | Fit the image to the window |
| `e` / `E` | Fit image width/height to the window |
| `<` / `>` / `?` | Rotate 90 degrees counterclockwise / 90 degrees clockwise / 180 degrees |
| vertical bar / `_` | Flip horizontally/vertically |
| `a` | Toggle antialiasing |
| `A` | Toggle the transparency checkerboard |
| `s` | Toggle slideshow mode; a count sets the delay in seconds |

### Animated and Multi-Frame Images

| Key | Action |
|---|---|
| `Ctrl+Space` | Start/stop animation |
| `Ctrl+n` | Go forward by one frame or by the count while animation is stopped |
| `Ctrl+p` | Go backward by one frame or by the count while animation is stopped |

### Thumbnail Mode

| Key | Action |
|---|---|
| `h/j/k/l` or arrows | Select the thumbnail left/down/up/right; accepts a count |
| `Enter` | Open the selected thumbnail in Image mode |
| `R` | Reload all thumbnails |
| `m`, `M`, `Ctrl+m`, `Ctrl+u` | Toggle, range-apply, invert, or clear marks as described above |
| `N` / `P` | Select the next/previous marked image |

### Mouse

| Gesture | Action |
|---|---|
| Left click in the left third of an image | Go to the previous image |
| Left click in the middle third | Keep the current image |
| Left click in the right third | Go to the next image |
| Hold middle button and drag | Pan the image |
| Right click | Switch to Thumbnail mode |
| Scroll up/down | Zoom in/out |

The default mouse actions require no modifier. The i3 tabbed wrapper only groups windows and adjusts their titles; it does not change any action in these tables.

## btop

Source: [`btop/.config/btop/btop.conf`](btop/.config/btop/btop.conf)

btop is a terminal resource monitor with CPU, memory/disk, network, process, and optional GPU boxes. This repository enables `vim_keys = True`, so lists use `h/j/k/l/g/G`; the two displaced lowercase actions become `H` for Help and `K` for Kill. All other keys below are retained btop defaults and can vary with the distribution's installed version. Open `F1`, `?`, or `H` for the authoritative runtime table.

### Common Workflows

| Goal | Sequence |
|---|---|
| Inspect a process | Move with `j/k`, then press `Enter` |
| Find a process | Press `/` or `f`, type a filter, then press `Enter` |
| Follow a process as the list changes | Select it and press `F` |
| Stop a process politely | Select it and press `t` to send `SIGTERM` |
| Force-stop a process | Select it and press `K` to send `SIGKILL` |
| Choose another signal | Select a process, press `s`, choose a signal, then press `Enter` |
| Change process sort column | Press `h/l` or `Left` / `Right` |
| Pause the changing process list | Press `u`; repeat to resume |
| Change the dashboard layout | Press `p` / `Shift+p` to cycle presets |
| Configure btop | Press `F2` or `o` |

### Global, Layout, and Display

| Key | Action |
|---|---|
| `Escape` or `m` | Toggle the main menu |
| `F1`, `?`, or `H` | Open Help |
| `F2` or `o` | Open Options |
| `q` or `Ctrl+c` | Quit btop |
| `Ctrl+z` | Suspend btop and put it in the background |
| `Ctrl+r` | Reload the configuration from disk |
| `p` / `Shift+p` | Cycle view presets forward/backward |
| `1` / `2` / `3` / `4` | Toggle the CPU/memory/network/process box |
| `5` ... `0` | Toggle available GPU boxes; only active in GPU-enabled builds with those devices |
| `d` | Toggle the disks area in the memory box |
| `+` / `-` | Add/subtract 100 ms from the update interval |

### Process List

| Key | Action |
|---|---|
| `j` / `k` or `Down` / `Up` | Select the next/previous process |
| `Page Down` / `Page Up` | Move one page down/up |
| `g` / `G` or `Home` / `End` | Go to the first/last process |
| `h` / `l` or `Left` / `Right` | Select the previous/next sorting column |
| `Enter` | Show or close detailed information for the selected process |
| `Space` | Expand/collapse the selected process in tree view |
| `C` | Expand/collapse the selected process's children |
| `f` or `/` | Enter a process filter; begin with `!` for a regular expression |
| `Delete` | Clear the process filter |
| `F` | Follow/unfollow the selected process |
| `u` | Pause/resume process-list updates |
| `c` | Toggle per-core process CPU percentages |
| `r` | Reverse process sorting |
| `e` | Toggle process tree view |
| `E` | Expand/collapse every process in tree view |
| `%` | Toggle process memory between bytes and percentage |
| `+` / `-` on a selected tree process | Expand/collapse that process |
| `t` on a selected process | Send `SIGTERM` (15) |
| `K` on a selected process | Send `SIGKILL` (9) |
| `s` on a selected process | Choose or enter another signal to send |
| `N` on a selected process | Choose a new nice value |

### Network and Disk Controls

| Key | Action |
|---|---|
| `b` / `n` | Select the previous/next network interface |
| `z` | Reset totals for the current network interface |
| `a` | Toggle automatic network graph scaling |
| `y` | Toggle synchronized download/upload graph scaling |
| `i` | Toggle large disk I/O graphs |

### Menus and Mouse

| Key or gesture | Action |
|---|---|
| `j/k` or arrows | Move through menu entries or help pages |
| `h/l` or `Left` / `Right` | Change the selected option |
| `Tab` / `Shift+Tab` | Move to the next/previous menu choice |
| `Enter` or `Space` | Activate the selected menu choice |
| `Escape`, `Backspace`, or `q` | Close or cancel a menu |
| `y` / `n` | Confirm/decline a yes-no dialog |
| Arrows or `h/j/k/l` in the signal chooser | Choose a signal |
| `0` ... `9` in the signal chooser | Enter a signal number manually |
| Left click | Activate a visible button or select a process |
| Mouse wheel | Scroll the list, help, or menu under the pointer |

## qutebrowser

Source: [`qutebrowser/.config/qutebrowser/config.py`](qutebrowser/.config/qutebrowser/config.py)

qutebrowser is a modal, keyboard-driven browser. This repository changes its theme and hides the tab bar, but calls `config.load_autoconfig()` and defines no tracked bindings. The tables below are the retained upstream defaults; machine-local changes in autoconfig and differences between releases are not visible in this repository. Run `:bind` with no arguments for the complete effective map, `:bind {key}` for one key, `:help` for help, and `:version` for the installed version.

Normal mode controls the browser. Insert mode passes text to a web form, Hint mode labels clickable elements, Caret mode selects page text, Passthrough mode gives nearly every key to the page, and Command mode begins with `:`. Number prefixes repeat or target many commands: `5j` scrolls five steps and `3gt` selects tab 3.

### Common Workflows

| Goal | Sequence |
|---|---|
| Open a URL or search in the current tab | `o`, type, then `Enter` |
| Open a URL or search in a new tab | `O`, type, then `Enter` |
| Open a visible link | `f`, type its hint label |
| Open a visible link in a new tab | `F`, type its hint label |
| Move through history | `H` back; `L` forward |
| Move between tabs | `J` next; `K` previous |
| Close and restore a tab | `d`; restore with `u` |
| Search the page | `/`, type text, `Enter`, then `n` / `N` |
| Type in a form | `i`, or click the field; leave with `Escape` |
| Give all keys to a web app | `Ctrl+v`; leave with `Shift+Escape` |
| Copy the current URL | `yy`; use `pp` later to open the clipboard URL |
| Select and copy page text | `v`, move with Caret keys, press `Space` to select, then `y` |
| Discover a key | Type `:bind ` followed by the key, or run `:bind` for all keys |

### Scrolling, Search, and Zoom

| Key | Action |
|---|---|
| `h/j/k/l` | Scroll left/down/up/right |
| `Ctrl+d` / `Ctrl+u` | Scroll half a page down/up |
| `Ctrl+f` / `Ctrl+b` | Scroll one page down/up |
| `gg` / `G` | Scroll to the top/bottom; a count before `G` scrolls to that percentage |
| `/text` / `?text` | Search forward/backward |
| `n` / `N` | Go to the next/previous search match |
| `Escape` | Clear a key chain/search and leave page fullscreen |
| `+` / `-` / `=` | Zoom in/out/reset |
| `{number}=` | Set an exact zoom percentage |
| `F5` / `Ctrl+F5` / `r` / `R` | Reload / force reload |
| `Ctrl+s` | Stop loading |
| `F11` | Toggle fullscreen |
| `.` | Repeat the last repeatable command |

### Opening and Navigation

| Key | Action |
|---|---|
| `o` / `O` | Open a URL/search in the current/new tab |
| `go` / `gO` | Edit the current URL in the current/new tab |
| `xo` / `xO` | Open a URL/edit the current URL in a background tab |
| `wo` / `wO` | Open a URL/edit the current URL in a new window |
| `ga` or `Ctrl+t` | Open a new tab |
| `Ctrl+n` / `Ctrl+Shift+n` | Open a new normal/private window |
| `H` / `L` or mouse Back/Forward | Go backward/forward in tab history |
| `th` / `tl` | Open the previous/next history entry in a new tab |
| `wh` / `wl` | Open the previous/next history entry in a new window |
| `gu` / `gU` | Go up one URL level in the current/new tab |
| `[[` / `]]` | Follow the page's detected previous/next link |
| `{{` / `}}` | Open the detected previous/next link in a new tab |
| `Ctrl+a` / `Ctrl+x` | Increment/decrement the last number in the URL |
| `Ctrl+h` | Open the home page |
| `gf` | View page source |
| `Ctrl+Alt+p` | Print the page |

### Hints

After starting a hint command, type a displayed label. `Escape` cancels; `Enter` follows the selected hint. In active Hint mode, `Ctrl+f` relabels normal links, `Ctrl+b` relabels for background tabs, and `Ctrl+r` enables rapid background-tab hints.

| Key | Hint action |
|---|---|
| `f` | Open a clickable element normally |
| `F` | Open a clickable element in a new tab |
| `;f` / `;b` | Open in a foreground/background tab |
| `;r` / `;R` | Rapidly open multiple links in background tabs/new windows |
| `wf` | Open in a new window |
| `;o` / `;O` | Put the selected link into an `:open` command/current or new tab command |
| `;t` or `gi` | Focus an input; `gi` chooses the first input directly when possible |
| `;h` | Hover an element |
| `;i` / `;I` | Open an image in the current/new tab |
| `;d` | Download a link |
| `;y` / `;Y` | Copy a link to the clipboard/primary selection |

### Tabs, Windows, and Sessions

The configured tab bar is always hidden, but all tab commands remain active.

| Key | Action |
|---|---|
| `J` / `K` or `Ctrl+Page Down` / `Ctrl+Page Up` | Select the next/previous tab |
| `Ctrl+Tab`, `Ctrl+^`, or `Ctrl+6` | Switch to the previously focused tab |
| `g0` or `g^` / `g$` | Select the first/last tab |
| `Alt+1` ... `Alt+8` / `Alt+9` | Select tab 1 ... 8 / the last tab |
| `{number}gt` | Select a numbered tab; plain `gt` opens tab selection |
| `T` | Select a tab by title or URL |
| `d`, `Ctrl+w`, or `Ctrl+Shift+w` | Close the current tab/window context |
| `D` | Close every other tab, selecting in the opposite configured direction |
| `co` | Close every tab except the current tab |
| `u` / `U` or `Ctrl+Shift+t` | Reopen a closed tab / reopen a closed window |
| `gJ` / `gK` | Move the current tab right/left |
| `gm` | Move the current tab to a prompted position |
| `gC` | Clone the current tab |
| `gD` | Detach/give the current tab to a window |
| `Ctrl+p` | Pin/unpin the current tab |
| `Alt+m` | Mute/unmute the current tab |
| `ZQ` / `Ctrl+q` | Quit without explicitly saving a session |
| `ZZ` | Save the session and quit |

### Quickmarks, Bookmarks, Marks, and Macros

| Key | Action |
|---|---|
| `m` / `b` | Save/load a quickmark in the current tab |
| `B` / `wb` | Load a quickmark in a new tab/window |
| `M` | Add the current page as a bookmark |
| `gb` / `gB` / `wB` | Load a bookmark in the current tab/new tab/new window |
| `Sb` / `Sq` | Show bookmarks and jump to them / show the bookmark list |
| `Sh` | Show browsing history |
| backtick, then a key | Set a local mark; uppercase keys create global marks |
| `'`, then a key | Jump to a local/global mark |
| `q`, then a register | Start/stop recording a macro |
| `@`, then a register | Replay a macro |

### Clipboard, Downloads, and Files

Lowercase yank suffixes use the desktop clipboard; uppercase suffixes use the X11 primary selection.

| Key | Action |
|---|---|
| `yy` / `yY` | Copy the current URL to the clipboard/primary selection |
| `yp` / `yP` | Copy the decoded, human-readable URL |
| `yt` / `yT` | Copy the page title |
| `yd` / `yD` | Copy the page domain |
| `ym` / `yM` | Copy a Markdown link containing the title and URL |
| `pp` / `pP` | Open the clipboard/primary-selection URL in the current tab |
| `Pp` / `PP` | Open the clipboard/primary-selection URL in a new tab |
| `gd` | Download the current page |
| `ad` | Cancel a download |
| `cd` | Clear finished downloads |
| `sf` | Save the current page |

### Settings and Developer Tools

| Key | Action |
|---|---|
| `ss` / `sl` | Set a persistent/temporary option |
| `sk` | Enter a `:bind` command |
| `t{feature}{scope}` | Persistently toggle a site feature and reload |
| `tc{feature}{scope}` | Temporarily toggle a site feature and reload |
| `wi` | Toggle developer tools |
| `wIh/wIj/wIk/wIl` | Dock developer tools left/bottom/top/right |
| `wIw` / `wIf` | Move developer tools to a window / focus developer tools |

For the site-toggle sequences, `{feature}` is `C`/`c` for cookies, `I`/`i` for images, `P`/`p` for plugins, or `S`/`s` for JavaScript. `{scope}` is `u` for the exact URL, `h` for the host, or `H` for the host and subdomains. Thus `tSh` persistently toggles JavaScript for the host, while `tcSu` temporarily toggles it for the exact URL.

### Caret Mode: Selecting Page Text

Enter Caret mode with `v`, or enter line-selection Caret mode with `V`.

| Key in Caret mode | Action |
|---|---|
| `h/j/k/l` | Move one character/line left/down/up/right |
| `b` / `w` / `e` | Move to the previous word/next word/end of word |
| `0` / `$` | Move to the start/end of the line |
| `gg` / `G` | Move to the start/end of the document |
| `[` / `]` | Move to the start of the previous/next block |
| `{` / `}` | Move to the end of the previous/next block |
| `Space` / `V` | Toggle character/line selection |
| `Ctrl+Space` | Drop the selection while remaining in selection mode |
| `o` | Swap the moving and stationary ends of the selection |
| `y` / `Y` | Copy the selection to the clipboard/primary selection |
| `Enter` | Follow the selected text as a link |
| `H/J/K/L` | Scroll the page left/down/up/right without moving the caret |
| `c` or `Escape` | Return to Normal mode |

### Insert, Hint, and Passthrough Modes

| Key | Mode | Action |
|---|---|---|
| `Escape` | Insert, Hint | Return to Normal mode |
| `Ctrl+e` | Insert | Edit the focused form field in an external editor |
| `Shift+Escape` | Insert | Send a literal `Escape` to the page |
| `Shift+Insert` | Insert | Insert the X11 primary selection |
| `Ctrl+f` / `Ctrl+b` | Hint | Restart hints for normal/background-tab links |
| `Ctrl+r` | Hint | Restart rapid background-tab hints |
| `Enter` | Hint | Follow the selected hint |
| `Shift+Escape` | Passthrough | Return to Normal mode; other keys go to the page |

### Command Line and Prompts

Press `:` to enter a browser command, `/` or `?` to search, or use a key such as `o` that pre-fills a command. The editing bindings below apply to Command mode and, except where noted, file/download prompts.

| Key | Action |
|---|---|
| `Ctrl+a` / `Ctrl+e` | Move to the start/end of the line |
| `Ctrl+b` / `Ctrl+f` | Move one character left/right |
| `Alt+b` / `Alt+f` | Move one word left/right |
| `Ctrl+h` | Delete the previous character |
| `Ctrl+?` | Delete the next character |
| `Alt+Backspace` / `Alt+d` | Delete the previous/next word |
| `Ctrl+u` / `Ctrl+k` | Delete to the start/end of the line |
| `Ctrl+w` / `Ctrl+Shift+w` | Delete the previous space-delimited word/path component |
| `Ctrl+y` | Paste the most recently deleted command-line text |
| `Up` / `Down` or `Ctrl+p` / `Ctrl+n` | Move through completions and command history |
| `Tab` / `Shift+Tab` | Select the next/previous completion |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Select the next/previous completion category |
| `Page Down` / `Page Up` | Move one completion page down/up |
| `Enter` | Accept the command or prompt |
| `Ctrl+Enter` | Accept a command and keep rapid command mode active |
| `Ctrl+c` / `Ctrl+Shift+c` | Copy the completion item to the clipboard/primary selection; Command mode |
| `Ctrl+d`, `Shift+Delete` | Delete the current completion/history item; Command mode |
| `Alt+e` | Open the external file selector; Prompt mode |
| `Alt+y` / `Alt+Shift+y` | Copy the prompt URL to clipboard/primary selection |
| `Ctrl+x` / `Ctrl+p` | Open a prompted download externally / in PDF.js |
| `Escape` | Cancel and return to Normal mode |

At yes/no prompts, use `y` / `n` for a one-time answer, `Y` / `N` to answer and save that decision, `Enter` to accept the selected answer, or `Escape` to cancel. qutebrowser globally treats `Ctrl+[`, `Ctrl+j`, `Ctrl+m`, keypad Enter, and shifted Enter as equivalents of `Escape` or `Enter` where appropriate.

## Lazygit

Source: [`lazygit/.config/lazygit/config.yml`](lazygit/.config/lazygit/config.yml)

Lazygit divides Git state into panels for status, files, branches, commits, stash entries, and a large main diff view. Keys are context-sensitive: for example, `d` discards a file, drops a commit or stash, deletes a branch, or removes a remote depending on the focused panel. The repository changes only colors and behavior outside repositories, so these are upstream defaults. The installer can track newer Lazygit releases; press `?` at any time for the exact keys and menu actions available in the focused panel.

### Common Workflows

| Goal | Sequence |
|---|---|
| Stage and commit files | Focus Files, select with `j/k`, press `Space`, then `c` |
| Stage only part of a file | In Files press `Enter`, select a hunk/line, then press `Space` |
| Unstage a file or hunk | Select it in the staged view and press `Space` |
| Discard working-tree changes | Select the file/hunk and press `d`, then confirm |
| Create and check out a branch | Focus Local Branches, press `n`, name it, then `Enter` |
| Switch branches | Focus Local Branches, select one, then press `Space` |
| Amend the latest commit | Stage changes, then press `A` in Files |
| Reword an older commit | Focus Commits, select it, then press `r` |
| Cherry-pick commits | In Commits press `C` to copy; on the target branch press `V` |
| Resolve a merge conflict | Select the conflicted file, press `Enter`, then use `h/l`, `j/k`, and `Space` |
| Undo/redo the last Git command | `z` / `Z` |
| Discover context-specific actions | Press `?` |

### Global and Panel Navigation

| Key | Action |
|---|---|
| `j/k` or `Down` / `Up` | Select the next/previous item |
| `1` ... `5` | Focus Status, Files, Branches, Commits, or Stash |
| `Tab` / `Shift+Tab` | Move between panels or alternate views |
| `[` / `]` | Select the previous/next tab within a panel |
| `Page Up`, `K`, or `Ctrl+u` | Scroll the main window up |
| `Page Down`, `J`, or `Ctrl+d` | Scroll the main window down |
| `H` / `L` | Scroll the current view left/right |
| `,` / `.` | Move to the previous/next list page |
| `<` or `Home` / `>` or `End` | Go to the top/bottom of a list |
| `/` | Filter or search the focused view |
| `v` | Start/stop range selection |
| `Shift+Down` / `Shift+Up` | Extend range selection down/up |
| `0` | Focus the main view from a side panel |
| `Escape` | Cancel the current operation or return to the side panel |
| `?` | Show the effective keybinding menu |

### Global Git and Display Actions

| Key | Action |
|---|---|
| `Ctrl+r` | Switch to a recent repository |
| `p` / `P` | Pull from / push to the upstream branch |
| `R` | Refresh Git state without fetching |
| `m` | Show merge/rebase continue, skip, and abort actions |
| `Ctrl+s` | Show commit-log filter options |
| `W` or `Ctrl+e` | Show diff-against-reference options |
| `Ctrl+p` | Show custom patch options |
| `:` | Run a shell command |
| `@` | Show command-log options |
| `z` / `Z` | Undo/redo the last supported Git command through reflog |
| `Ctrl+w` | Toggle whitespace changes in diffs |
| `}` / `{` | Increase/decrease diff context |
| `)` / `(` | Increase/decrease rename-similarity threshold |
| `+` / `_` | Select the next/previous screen mode |
| vertical bar / backslash | Cycle diff renderers forward/backward |
| `Alt+Shift+c` | Edit the Lazygit configuration externally |
| `q` or `Ctrl+c` | Quit |
| `Ctrl+z` | Suspend Lazygit |

### Files Panel

| Key | Action |
|---|---|
| `Space` | Stage/unstage the selected file |
| `a` | Stage/unstage every working-tree file |
| `Enter` | Open file staging, or collapse/expand a directory |
| `c` / `C` | Commit using the Lazygit prompt / configured Git editor |
| `w` | Commit without running pre-commit hooks |
| `A` | Amend the last commit with staged changes |
| `Ctrl+f` | Find the likely base commit for a fixup |
| `e` / `o` | Edit the file externally / open it with the default application |
| `Ctrl+o` | Copy the file path to the clipboard |
| `y` | Open file copy actions |
| `i` | Add the file to ignore/exclude rules |
| `r` | Refresh files |
| `s` / `S` | Stash all changes / show stash variants |
| `d` | Show discard actions for the selected file |
| `D` | Show working-tree reset actions |
| `g` | Show upstream reset actions |
| `M` | Show merge-conflict actions |
| `f` | Fetch remotes |
| backtick | Toggle flat/file-tree layout |
| `-` / `=` | Collapse/expand every directory |
| `Ctrl+b` | Filter files by status |
| `Ctrl+t` | Open the selected file in the external diff tool |

### Main Diff and Staging Views

| Key | Context | Action |
|---|---|---|
| `Tab` | Normal, staging | Switch staged/unstaged or alternate diff view |
| `Escape` | Any main view | Return to the side panel or leave the current operation |
| `h/l` or `Left` / `Right` | Staging, patch, merging | Select previous/next hunk or conflict |
| `j/k` or `Down` / `Up` | Merging | Select the next/previous hunk |
| `v` | Staging, patch | Toggle range selection |
| `a` | Staging, patch | Toggle hunk-level versus line-level selection |
| `Space` | Staging | Stage/unstage selected lines or hunks |
| `Space` | Patch builder | Include/exclude selected lines from the patch |
| `Space` | Merge view | Pick the selected hunk |
| `b` | Merge view | Pick both conflict hunks |
| `d` | Staging | Discard an unstaged hunk or unstage a staged hunk |
| `d` | Patch builder | Remove selected lines from the commit through rebase |
| `E` | Staging | Edit the selected hunk externally |
| `e` / `o` | Staging, patch, merging | Edit/open the current file externally |
| `Ctrl+o` | Staging, patch | Copy selected text |
| `c` / `C` / `w` | Staging | Commit normally / in Git editor / without hooks |
| `Ctrl+f` | Staging | Find the base commit for a fixup |
| `z` | Merge view | Undo the last conflict resolution |
| `M` | Merge view | Show conflict-resolution options |

### Commits

| Key | Action |
|---|---|
| `Enter` | View the files in the selected commit |
| `Ctrl+o` | Copy the abbreviated commit hash |
| `y` | Choose a commit attribute to copy |
| `s` / `f` | Squash/fixup the commit into the one below |
| `c` | Set the fixup commit-message option |
| `r` / `R` | Reword using the prompt/external editor |
| `d` | Drop the commit through interactive rebase |
| `e` | Mark for edit or start rebase from this commit |
| `i` | Start interactive rebase for the current branch |
| `p` | Mark the commit as pick during a rebase |
| `F` | Create a `fixup!` commit for the selected commit |
| `S` | Autosquash fixup commits |
| `Ctrl+j` or `Alt+Down` | Move the commit down |
| `Ctrl+k` or `Alt+Up` | Move the commit up |
| `A` | Amend the selected commit with staged changes |
| `a` | Change author/co-author attributes |
| `t` | Create a revert commit |
| `T` | Create a tag at the selected commit |
| `b` | Show bisect actions |
| `B` | Mark this as the base commit for the next rebase |
| `g` | Show soft/mixed/hard reset actions |
| `C` / `V` | Copy / cherry-pick copied commits |
| `Ctrl+r` | Clear the copied-commit selection |
| `*` | Select commits belonging to the current branch |
| `Space` | Check out the commit as detached HEAD |
| `n` | Create a branch from the commit |
| `N` | Move unpushed commits to a new branch |
| `w` | Create a worktree from the commit |
| `G` / `o` | Open the pull request / selected commit in a browser |
| `Ctrl+l` | Show commit-log display and sort options |
| `Ctrl+t` | Open the external diff tool |

### Files Inside a Commit

| Key | Action |
|---|---|
| `Enter` | Enter a file for line-level patching or collapse/expand a directory |
| `Space` | Include/exclude the file in the custom patch |
| `a` | Include/exclude all files in the custom patch |
| `c` | Check out this file's version from the commit |
| `d` | Remove this file's changes from the commit through rebase |
| `e` / `o` | Edit/open the file externally |
| `Ctrl+o` / `y` | Copy the path / open copy actions |
| `Ctrl+t` | Open the external diff tool |
| backtick | Toggle flat/file-tree layout |
| `-` / `=` | Collapse/expand every directory |

### Local and Remote Branches

| Key | Local-branch action |
|---|---|
| `Space` | Check out the selected branch |
| `n` | Create a branch |
| `c` / `-` | Check out by name / check out the previous branch |
| `F` | Force checkout, discarding local working-tree changes |
| `d` | Show local/remote branch deletion actions |
| `r` / `M` / `f` | Rebase onto / merge / fast-forward from the selected branch |
| `N` | Move unpushed commits to a new branch |
| `R` | Rename the branch |
| `u` | Configure, unset, or reset to upstream |
| `g` | Show reset actions |
| `s` | Change branch sort order |
| `i` | Show git-flow actions |
| `T` | Create a tag |
| `o` / `O` | Create a pull request / show pull-request creation options |
| `G` | Open the pull request in a browser |
| `Ctrl+y` | Copy the pull-request URL |
| `w` | Create a worktree |
| `Enter` | View branch commits |
| `Ctrl+o` | Copy the branch name |
| `Ctrl+t` | Open the external diff tool |

| Key | Remote-branch action |
|---|---|
| `Space` | Create/check out a local branch or detached remote HEAD |
| `n` / `w` | Create a branch / worktree |
| `M` / `r` | Merge / rebase using the remote branch |
| `d` | Delete the remote branch |
| `u` | Set it as the current branch's upstream |
| `s` | Change sort order |
| `g` | Show reset actions |
| `Enter` | View commits |
| `Ctrl+o` | Copy the branch name |
| `Ctrl+t` | Open the external diff tool |

### Stash, Tags, Remotes, Submodules, and Worktrees

| Context | Key | Action |
|---|---|---|
| Stash | `Space` / `g` | Apply / pop the stash |
| Stash | `d` / `r` | Drop / rename the stash |
| Stash | `n` / `w` | Create a branch / worktree from the stash |
| Stash | `Enter` | View stashed files |
| Tags | `Space` | Check out the tag as detached HEAD |
| Tags | `n` / `d` / `P` | Create / delete / push a tag |
| Tags | `g` / `w` | Reset to the tag / create a worktree |
| Tags | `Enter` | View commits from the tag |
| Remotes | `Enter` | View the remote's branches |
| Remotes | `n` / `d` / `e` | Add / remove / edit a remote |
| Remotes | `f` / `F` | Fetch / add a fork remote |
| Submodules | `Enter` | Enter the submodule; `Escape` returns to the parent repository |
| Submodules | `n` / `d` / `e` | Add / remove / change the URL |
| Submodules | `i` / `u` / `b` | Initialize / update / show bulk actions |
| Worktrees | `n` / `Space` | Create / switch to a worktree |
| Worktrees | `o` / `d` | Open in the editor / remove the worktree |

Every list above also uses `/` to filter and the global list-navigation keys. Most item types use `Ctrl+o` to copy their path, name, tag, branch, or abbreviated hash.

### Reflog, Status, and Dialogs

Reflog and sub-commit views retain the applicable commit actions: `Space` checks out, `y` copies attributes, `o` opens in a browser, `n` creates a branch, `N` moves commits, `w` creates a worktree, `g` resets, `C` copies for cherry-pick, `Ctrl+r` clears copied commits, `Ctrl+t` opens the diff tool, `*` selects the current branch's commits, and `Enter` opens commits/files.

| Context | Key | Action |
|---|---|---|
| Status | `Enter` | Switch to a recent repository |
| Status | `e` / `u` | Edit configuration / check for updates |
| Status | `a` / `A` | Cycle all-branch logs forward/backward |
| Menu | `Enter` / `Escape` | Execute / cancel |
| Confirmation | `Enter` / `Escape` | Confirm / cancel |
| Confirmation | `Ctrl+o` | Copy the confirmation text |
| Input prompt | `Enter` / `Escape` | Submit / cancel |

## OpenCode TUI

Source: [`opencode/.config/opencode/opencode.json`](opencode/.config/opencode/opencode.json)

OpenCode is a terminal AI workspace organized around sessions, messages, agents, models, and a multiline prompt. The tracked configuration defines providers, a usage plugin, permissions, and an MCP server but no TUI key overrides, so OpenCode's installed defaults apply. The installer can track moving releases; use `Ctrl+Alt+k` for the built-in which-key view and `Ctrl+p` for the command list after an upgrade.

The default `Leader` is `Ctrl+x`. Leader actions are sequences: press and release `Ctrl+x`, then press the final key within the default two-second timeout. For example, `Leader+n` means `Ctrl+x`, then `n`.

### Common Workflows

| Goal | Sequence |
|---|---|
| Start a clean session | `Leader+n` |
| Switch to another session | `Leader+l` |
| Inspect the session timeline | `Leader+g` |
| Choose an agent | `Leader+a`; cycle agents directly with `Tab` / `Shift+Tab` |
| Choose a model | `Leader+m`; cycle recent models with `F2` / `Shift+F2` |
| Write a multiline prompt | `Shift+Enter`, `Ctrl+Enter`, `Alt+Enter`, or `Ctrl+j` |
| Submit a prompt | `Enter` |
| Stop a running response | `Escape` |
| Copy the selected/displayed message | `Leader+y` |
| Undo/redo message changes | `Leader+u` / `Leader+r` |
| Compact a long session | `Leader+c` |
| Edit the prompt in an external editor | `Leader+e` |
| Discover commands and keys | `Ctrl+p` for commands; `Ctrl+Alt+k` for which-key |

### Application and Session

| Key | Action |
|---|---|
| `Ctrl+c`, `Ctrl+d`, or `Leader+q` | Exit when the current input context does not consume the key |
| `Ctrl+p` | Open the command list |
| `Leader+e` | Open the prompt in an external editor |
| `Leader+t` | Select a theme |
| `Leader+b` | Toggle the sidebar |
| `Leader+s` | Open the status view |
| `Leader+x` | Export the current session |
| `Leader+n` | Create a session |
| `Leader+l` | List/select sessions |
| `Leader+g` | Open the session timeline |
| `Ctrl+r` | Rename the current session in its session context |
| `Ctrl+d` | Delete the selected session or stash entry in the relevant dialog |
| `Escape` | Interrupt the running session/response |
| `Leader+c` | Compact the current session |
| `Leader+Down` | Open the first child/subagent session |
| `Right` / `Left` | Cycle child sessions forward/backward |
| `Up` | Return to the parent session |

### Models, Agents, and Variants

| Key | Action |
|---|---|
| `Leader+m` | Open the model list |
| `F2` / `Shift+F2` | Cycle recent models forward/backward |
| `Ctrl+a` | Open the provider list in model selection |
| `Ctrl+f` | Toggle the selected model as a favorite |
| `Leader+a` | Open the agent list |
| `Tab` / `Shift+Tab` | Cycle agents forward/backward |
| `Ctrl+t` | Cycle model variants |

### Messages and Conversation

| Key | Action |
|---|---|
| `Page Up` or `Ctrl+Alt+b` | Scroll messages one page up |
| `Page Down` or `Ctrl+Alt+f` | Scroll messages one page down |
| `Ctrl+Alt+y` / `Ctrl+Alt+e` | Scroll messages one line up/down |
| `Ctrl+Alt+u` / `Ctrl+Alt+d` | Scroll messages half a page up/down |
| `Ctrl+g` or `Home` | Go to the first message |
| `Ctrl+Alt+g` or `End` | Go to the latest message |
| `Leader+y` | Copy the current message |
| `Leader+u` / `Leader+r` | Undo/redo message changes |
| `Leader+h` | Toggle concealed message content; outside that context, toggle tips |

### Prompt Editing and Submission

| Key | Action |
|---|---|
| `Enter` | Submit the prompt |
| `Shift+Enter`, `Ctrl+Enter`, `Alt+Enter`, or `Ctrl+j` | Insert a newline |
| `Ctrl+c` | Clear the prompt; on an empty prompt it may exit |
| `Ctrl+v` | Paste through OpenCode's input handler |
| `Left` / `Ctrl+b` | Move left one character |
| `Right` / `Ctrl+f` | Move right one character |
| `Up` / `Down` | Move vertically; at the prompt boundary, browse history |
| `Shift+Left/Right/Up/Down` | Extend the selection in that direction |
| `Ctrl+a` / `Ctrl+e` | Move to the start/end of the current line |
| `Ctrl+Shift+a` / `Ctrl+Shift+e` | Select to the start/end of the current line |
| `Alt+a` / `Alt+e` | Move to the visual start/end of a wrapped line |
| `Alt+Shift+a` / `Alt+Shift+e` | Select to the visual start/end of a wrapped line |
| `Home` / `End` | Move to the start/end of the whole prompt buffer |
| `Shift+Home` / `Shift+End` | Select to the start/end of the whole prompt buffer |
| `Alt+b`, `Alt+Left`, or `Ctrl+Left` | Move one word backward |
| `Alt+f`, `Alt+Right`, or `Ctrl+Right` | Move one word forward |
| `Alt+Shift+b` or `Alt+Shift+Left` | Select one word backward |
| `Alt+Shift+f` or `Alt+Shift+Right` | Select one word forward |
| `Backspace` or `Shift+Backspace` | Delete backward |
| `Ctrl+d`, `Delete`, or `Shift+Delete` | Delete forward |
| `Ctrl+Shift+d` | Delete the current line |
| `Ctrl+k` / `Ctrl+u` | Delete to the end/start of the current line |
| `Alt+d`, `Alt+Delete`, or `Ctrl+Delete` | Delete the next word |
| `Ctrl+w`, `Ctrl+Backspace`, or `Alt+Backspace` | Delete the previous word |
| `Ctrl+-` or `Super+z` | Undo prompt editing |
| `Ctrl+.` or `Super+Shift+z` | Redo prompt editing |
| `Super+a` | Select the entire prompt |

Kitty's `Ctrl+Shift+v` is still the most reliable way to paste the desktop clipboard into the terminal. OpenCode's plain `Ctrl+v` binding is also retained and is allowed to fall through to the terminal input system.

### Selection, Autocomplete, Permissions, and Plugins

| Key | Context | Action |
|---|---|---|
| `Up` or `Ctrl+p` | Selection dialog, autocomplete | Select the previous item |
| `Down` or `Ctrl+n` | Selection dialog, autocomplete | Select the next item |
| `Page Up` / `Page Down` | Selection dialog | Move one page up/down |
| `Home` / `End` | Selection dialog | Select the first/last item |
| `Enter` | Dialog or autocomplete | Submit/select the current item |
| `Escape` | Autocomplete | Hide autocomplete |
| `Tab` | Autocomplete | Complete the current item |
| `Space` | MCP dialog | Enable/disable the selected MCP server |
| `Ctrl+f` | Permission prompt | Toggle the prompt fullscreen |
| `Space` | Plugin dialog | Enable/disable the selected plugin |
| `Shift+i` | Plugin dialog | Install the selected plugin |

Because this repository sets edit permission to `ask`, permission prompts are part of the normal editing workflow; use the visible dialog choices and `Enter`, with `Ctrl+f` when the detail needs more room.

### Terminal and Which-Key

| Key | Action |
|---|---|
| `Ctrl+z` | Suspend OpenCode on POSIX terminals |
| `Ctrl+Alt+k` | Toggle the which-key reference |
| `Ctrl+Alt+Shift+k` | Change which-key layout |
| `Ctrl+Alt+Shift+p` | Toggle pending sequences in which-key |
| `Ctrl+Alt+Left` or `Ctrl+Alt+[` | Select the previous which-key group |
| `Ctrl+Alt+Right` or `Ctrl+Alt+]` | Select the next which-key group |
| `Ctrl+Alt+Up` or `Ctrl+Alt+p` | Scroll which-key up |
| `Ctrl+Alt+Down` or `Ctrl+Alt+n` | Scroll which-key down |
| `Ctrl+Alt+Page Up` / `Ctrl+Alt+Page Down` | Move one which-key page up/down |
| `Ctrl+Alt+Home` / `Ctrl+Alt+End` | Go to the start/end of which-key |

Several supported actions intentionally default to no key, including debug/console controls, help/docs, theme-mode locking, scrollbar toggling, session fork/share/unshare and optional session displays, tool details, thinking display, model favorites cycling, variant/provider/MCP lists, prompt stash/skill controls, terminal-title toggling, and plugin-manager commands. Open them through `Ctrl+p` when the installed release exposes them, or define them in OpenCode's current TUI keybinding configuration.

## Zen Browser

Source: [`zen/.config/zen/chrome/`](zen/.config/zen/chrome/)

Zen is the daily graphical browser in this workstation. It is launched from i3 with `Super+z` and combines Firefox's browsing engine with vertical tabs, workspaces, Compact Mode, Glance, and split views. This repository installs only Zen's user-interface CSS and image assets; it does not track the browser profile where shortcuts are customized.

The tables therefore describe Zen's current Linux defaults and the stable Mozilla shortcuts Zen retains. Open **Settings > Keyboard Shortcuts** for the authoritative effective map in the active profile. That pane can search, edit, clear, and reset shortcuts, and the profile stores its choices in `zen-keyboard-shortcuts.json`. An unbound action shown there has no active key until one is assigned.

### Common Workflows

| Goal | Sequence |
|---|---|
| Launch or focus Zen | `Super+z` from i3 |
| Open a site or search | `Ctrl+l`, type, then `Enter` |
| Open a new tab | `Ctrl+t` |
| Move between tabs | `Ctrl+Tab` / `Ctrl+Shift+Tab` |
| Restore a closed tab | `Ctrl+Shift+t` |
| Move between Zen workspaces | `Ctrl+Alt+Right` / `Ctrl+Alt+Left` |
| Hide or restore the browser chrome | `Ctrl+s` to toggle Compact Mode |
| Temporarily reveal the Compact Mode sidebar | `Ctrl+Alt+s` |
| Put tabs into a split view | Select the tabs, then use `Ctrl+Alt+g`, `Ctrl+Alt+v`, or `Ctrl+Alt+h` |
| Leave a split view | `Ctrl+Alt+u` |
| Expand a Glance preview into a tab | `Ctrl+o` |
| Pin or unpin the current tab | `Ctrl+Shift+d` |
| Copy the current URL | `Ctrl+Shift+c` |
| Find text in the page | `Ctrl+f`, type text, then `Enter`; repeat with `Ctrl+g` |
| Save the current page | `Ctrl+Alt+Shift+s`; Zen reserves plain `Ctrl+s` for Compact Mode |
| Inspect or change a shortcut | Open **Settings > Keyboard Shortcuts** |

### Zen Features

On Linux, `Accel` in Zen's upstream definitions means `Ctrl`.

| Key | Action |
|---|---|
| `Ctrl+s` | Toggle Compact Mode |
| `Ctrl+Alt+s` | Toggle/reveal the floating sidebar while using Compact Mode |
| `Ctrl+Alt+Right` / `Ctrl+Alt+Left` | Switch to the next/previous Zen workspace |
| `Ctrl+Alt+g` | Arrange selected tabs as a grid split |
| `Ctrl+Alt+v` | Arrange selected tabs as a vertical split |
| `Ctrl+Alt+h` | Arrange selected tabs as a horizontal split |
| `Ctrl+Alt+u` | Unsplit the current split view |
| `Ctrl+Shift+*` | Create a new empty split |
| `Ctrl+o` | Expand the current Glance preview into a normal tab |
| `Ctrl+Shift+d` | Pin/unpin the current tab |
| `Ctrl+Shift+k` | Close every unpinned tab |
| `Ctrl+Shift+c` | Copy the current URL |
| `Ctrl+Alt+Shift+c` | Copy the current page as a Markdown link |
| `Ctrl+Shift+n` | Open a new unsynced Zen window |

The actions for switching directly to workspaces 1 through 10, creating a workspace, toggling the Zen sidebar, resetting a pinned tab, and duplicating a tab are present in the shortcut editor but unbound by default on Linux. Direct workspace numbers default only on macOS; do not assume `Ctrl+1` ... `Ctrl+0` selects a Zen workspace on this machine. Those standard Firefox keys select browser tabs instead.

### Page and History Navigation

| Key | Action |
|---|---|
| `Ctrl+l` or `F6` | Focus and select the address bar |
| `Alt+Left` / `Alt+Right` | Go back/forward in page history |
| `Alt+Home` | Open the configured home page |
| `Ctrl+r` or `F5` | Reload the page |
| `Ctrl+Shift+r` or `Ctrl+F5` | Reload while bypassing the cache |
| `Up` / `Down` | Scroll up/down |
| `Space` / `Shift+Space` | Scroll one screen down/up |
| `Page Down` / `Page Up` | Scroll one screen down/up |
| `Home` / `End` | Go to the top/bottom of the page |
| `Ctrl+h` | Toggle the history sidebar |
| `Ctrl+Shift+h` | Open the full history library |
| `Ctrl+j` | Open downloads |
| `Ctrl+Shift+Delete` | Open the clear-browsing-data dialog |

### Tabs and Windows

| Key | Action |
|---|---|
| `Ctrl+t` | Open a new tab |
| `Ctrl+w` or `Ctrl+F4` | Close the current tab |
| `Ctrl+Shift+t` | Restore the most recently closed tab or session item |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | Select the next/previous tab |
| `Ctrl+Page Down` / `Ctrl+Page Up` | Select the next/previous tab |
| `Ctrl+1` ... `Ctrl+8` / `Ctrl+9` | Select tab 1 ... 8 / the last tab |
| `Alt+Enter` from the address bar | Open the typed address or search in a new tab |
| `Ctrl+Shift+Page Up` / `Ctrl+Shift+Page Down` | Move the current tab left/right |
| `Ctrl+m` | Mute/unmute the current tab |
| `Ctrl+n` | Open a new normal window |
| `Ctrl+Shift+p` | Open a private window |
| `Ctrl+Shift+n` | Open an unsynced Zen window |
| `Alt+F4` | Close the current window |

Zen disables Firefox's separate restore-closed-window shortcut by default because it conflicts with Zen's window actions. Use `Ctrl+Shift+t` or the History menu for recovery.

### Find, Search, and Address Bar

| Key | Action |
|---|---|
| `Ctrl+f` | Find text in the current page |
| `Ctrl+g` or `F3` | Find the next match |
| `Ctrl+Shift+g` or `Shift+F3` | Find the previous match |
| `/` | Start Quick Find in page text when the page does not consume the key |
| `'` | Start Quick Find for links only when the page does not consume the key |
| `Escape` | Close Quick Find/find, address-bar suggestions, or the current transient panel |
| `Down` / `Up` in the address bar | Select the next/previous suggestion |
| `Enter` | Open the selected address-bar result |
| `Shift+Enter` | Open the selected address-bar result in a new window |
| `Alt+Enter` | Open the selected address-bar result in a new tab |

### Bookmarks, Files, and Page Actions

| Key | Action |
|---|---|
| `Ctrl+d` | Bookmark the current page |
| `Ctrl+b` | Toggle the bookmarks sidebar |
| `Ctrl+Shift+b` | Toggle the bookmarks toolbar |
| `Ctrl+Shift+o` | Open the bookmarks library |
| `Ctrl+p` | Print the current page |
| `Ctrl+Alt+Shift+s` | Save the current page |
| `Ctrl+Shift+s` | Take a browser screenshot |
| `Ctrl+u` | View the page source |
| `Ctrl+i` | Show page information |
| `F9` | Toggle Reader View when the page supports it |
| `F11` | Toggle browser fullscreen |
| `Escape` | Leave fullscreen or close the current transient interface |

Plain `Ctrl+o` is not Open File in Zen; it expands Glance. The upstream Open File shortcut and Bookmark All Tabs shortcut are deliberately cleared to make room for Zen actions. Use the application menu for Open File, or assign another key in **Settings > Keyboard Shortcuts**.

### Zoom and Media

| Key | Action |
|---|---|
| `Ctrl++` | Zoom in |
| `Ctrl+-` | Zoom out |
| `Ctrl+0` | Reset page zoom |
| `Ctrl+m` | Mute/unmute the current tab |
| `Space` on focused media | Play/pause audio or video |
| `Left` / `Right` on focused media | Seek backward/forward |
| `Up` / `Down` on focused media | Raise/lower volume |
| `Ctrl+Shift+]` | Toggle Picture-in-Picture for compatible video |

Websites can consume unmodified media and navigation keys. Use `Tab` or the mouse to focus the player first; browser-level modified shortcuts still take precedence unless the site or desktop reserves them.

### Editing Text and Forms

These are standard editing keys in the address bar, search fields, and webpage form controls.

| Key | Action |
|---|---|
| `Ctrl+a` | Select all text |
| `Ctrl+c` / `Ctrl+x` | Copy/cut the selection |
| `Ctrl+v` | Paste from the desktop clipboard |
| `Ctrl+Shift+v` | Paste without formatting where the field supports it |
| `Ctrl+z` / `Ctrl+Shift+z` | Undo/redo an edit |
| `Ctrl+Left` / `Ctrl+Right` | Move one word left/right |
| `Ctrl+Shift+Left` / `Ctrl+Shift+Right` | Select one word left/right |
| `Home` / `End` | Move to the start/end of the line |
| `Shift` plus a movement key | Extend the text selection |
| `Backspace` / `Delete` | Delete before/under the cursor |
| `Tab` / `Shift+Tab` | Focus the next/previous page or browser control |

### Developer Tools

| Key | Action |
|---|---|
| `F12` or `Ctrl+Shift+l` | Toggle the Developer Tools toolbox; Zen moves the editable Firefox `Ctrl+Shift+i` binding to `Ctrl+Shift+l` |
| `Ctrl+Shift+c` | Start the element picker when Developer Tools owns the shortcut; otherwise Zen uses it to copy the current URL |
| `Ctrl+Shift+k` | Open the Web Console when Developer Tools owns the shortcut; otherwise Zen uses it to close unpinned tabs |
| `Ctrl+Shift+e` | Open the Network Monitor |
| `Ctrl+Shift+m` | Toggle Responsive Design Mode |
| `Shift+F7` | Open the Style Editor |
| `Shift+F5` | Open the Performance tool |
| `Shift+F9` | Open the Storage Inspector |
| `Ctrl+u` | View the page source outside the toolbox |

Zen exposes Developer Tools keys in the same shortcut editor as browser actions, and current releases detect duplicate assignments there. Because Zen also assigns `Ctrl+Shift+c` and `Ctrl+Shift+k` to browser features, use `F12` first and inspect **Settings > Keyboard Shortcuts** to see which action wins in the active profile and context.

## Dunst Notifications

Source: [`dunst/.config/dunst/dunstrc`](dunst/.config/dunst/dunstrc)

Dunst is a passive notification daemon: it does not take keyboard focus and this repository defines no `dunstctl` keyboard bindings. Notifications expose three tracked mouse actions.

| Gesture | Action |
|---|---|
| Left click a notification | Close that notification |
| Middle click a notification | Run its default action, then close it |
| Right click a notification | Close all visible notifications |

An application decides what its default notification action does; for example, it may focus a window or open the relevant item. i3 explicitly prevents Dunst windows from stealing keyboard focus.

## Polybar

Source: [`polybar/.config/polybar/config.ini`](polybar/.config/polybar/config.ini)

Polybar is the clickable status bar at the top of the i3 session. It defines no keyboard map; workspace and media keyboard controls belong to i3. The explicit click actions below combine with retained defaults of Polybar's internal modules. Because Polybar was not installed on the inspected machine, internal-module defaults are based on modern Polybar 3.6/3.7 behavior and can vary with the distribution build.

| Area | Gesture | Action |
|---|---|---|
| Workspace name | Left click | Switch to that workspace; retained `xworkspaces` default |
| Workspace names | Scroll up/down | Switch to the previous/next workspace; retained `xworkspaces` default |
| Volume | Left click | Mute/unmute output; retained `pulseaudio` default |
| Volume | Scroll up/down | Raise/lower output volume by 5 percentage points; retained `pulseaudio` default |
| Volume | Right click | Open `pavucontrol`; repository action |
| Memory | Left click | Open btop in Kitty; repository action |
| Battery | Left click | Open GNOME Power settings; repository action |
| Connected Wi-Fi | Left click | Open GNOME Wi-Fi settings; repository action |
| Ethernet label | Left click | Open NetworkManager's connection editor; repository action |
| Clock | Left click | Toggle `HH:MM` and the full date/time; retained `date` behavior enabled by `date-alt` |

The global `cursor-click` and `cursor-scroll` settings change the pointer shape over interactive regions; they do not add actions of their own. Disconnected Wi-Fi renders no visible target, and the Ethernet icon sits outside its clickable label.

## Services Without Direct Keymaps

Every Stow package is accounted for below. These packages configure appearance, startup, background services, command-line behavior, or application handoffs and therefore have no independent keyboard map to list.

| Package or service | Keyboard ownership and relevant behavior |
|---|---|
| Starship | Draws the Bash/Fish prompt only. Prompt editing belongs to Bash or Fish. |
| Git | Tracks only `useConfigOnly` and a machine-local include. Git itself is command-driven; interactive Git work in this setup is documented under Lazygit. |
| Picom | Composites windows in the background and never takes keyboard focus. Window opacity, focus, and layout keys belong to i3 or Kitty. |
| Fastfetch | Prints system information and exits. It has no interactive mode or keymap. |
| Fontconfig | Selects font fallbacks and has no user interface. |
| GTK | Sets themes and GTK defaults. Individual GTK applications own their controls. |
| X11 | Establishes French AZERTY, X resources, cursor settings, and `Caps Lock` as `Escape`; that global remap is reflected throughout this guide. |
| systemd user units | Start and preserve tmux and graphical-session services in the background. tmux's interactive map is documented in its own section. |
| xdg-desktop-portal | Routes desktop requests to GTK or the terminal file chooser and has no focused interface of its own. |
| xdg-desktop-portal-termfilechooser | Opens Yazi in Kitty for application Open/Save dialogs. Once open, use the complete Yazi map above; `Enter` opens a file and `Escape`/`q` cancels according to Yazi's current context. |
| LaTeX | Contains bibliography styles only. Editing and compilation controls belong to Neovim and its LaTeX plugins. |
| Wallpapers | Supplies image assets and has no controls. |
| Bash/Fish profiles and environment startup | Export paths and environment variables; their interactive maps are documented under Bash and Fish. |
| Script launchers | Delegate interaction to Rofi, Yazi, sxiv, Zathura, Flameshot, Zen, tmux, i3lock, or another owning application documented above. Maintenance scripts are command-line programs and expose `--help`, not live keymaps. |
| Installer and package lists | Provision the workstation non-interactively apart from ordinary terminal prompts. They do not define runtime bindings. |

Machine-local files can still add controls outside this repository, especially `~/.config/i3/local.conf`, `~/.gitconfig.local`, Zen's profile shortcut file, qutebrowser autoconfig, Readline's `~/.inputrc`, and application databases. Inspect the owning application's runtime help when a local key differs from this reference.