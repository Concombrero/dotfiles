# Workstation Scavenger Hunt

A guided field exercise for learning this keyboard-first workstation by using it. By the end, you will have practiced the main paths through i3, Rofi, Kitty, Fish, tmux, Yazi, Neovim, Lazygit, Zen, OpenCode, and the desktop file handlers.

## Mission Brief

- **Estimated time:** 60-90 minutes
- **Starting point:** an i3 session, with this dotfiles repository open locally
- **Practice area:** `~/workstation-hunt`; the repository itself does not need to be modified
- **Goal:** complete the final challenge without consulting the hints

Keep [keybinds.md](keybinds.md) nearby, but treat it as your map rather than a page to memorize. Try each clue first, open its hint only when you are stuck, and check a box only after observing the expected result.

> [!IMPORTANT]
> Tasks involving Bitwarden and OpenCode are optional until their machine-local credentials are configured. Never put credentials, tokens, or personal data in the practice files.

## Field Log

Use this scorecard as you go. There are **12 regular artifacts** and **3 final artifacts**.

- [ ] Map found
- [ ] Camp established
- [ ] i3 route completed
- [ ] Kitty route completed
- [ ] Fish tools identified
- [ ] Yazi waypoint visited
- [ ] tmux session recovered
- [ ] Neovim note edited
- [ ] Clipboard bridge crossed
- [ ] Git state inspected
- [ ] Desktop handlers verified
- [ ] Safety exits located
- [ ] Final workspace assembled
- [ ] Final note saved
- [ ] Final screenshot captured

## Prologue: Find the Map

**Clue:** The workstation has a searchable map hidden behind a single i3 shortcut. Find it without opening a terminal, then search for `workspace`, `tmux`, and `clipboard`.

**Proof:** You can explain the difference between `Super`, Kitty's `Ctrl+Space` sequence, tmux's `Prefix`, and Neovim's `Leader`.

- [ ] Mark **Map found** in the field log.

<details>
<summary>Hint</summary>

Press `Super+/`. In this setup, `Super` is the Windows/Command key, tmux's `Prefix` is `Alt+Tab`, and Neovim's `Leader` is `Space`.

</details>

## Chapter 1: Establish Camp

**Clue:** Open a terminal using only the keyboard. From the dotfiles repository root, create a disposable expedition directory and record where the repository lives.

Run these commands in Fish:

```fish
set repo_root (git rev-parse --show-toplevel)
mkdir -p ~/workstation-hunt/{notes,archive}
printf '%s\n' "$repo_root" > ~/workstation-hunt/.dotfiles-root
printf '# Field Notes\n\nStatus: camp established\nToken: solar compass\n' > ~/workstation-hunt/notes/field-notes.md
printf 'portal\nkeyboard\nclipboard\nworkspace\n' > ~/workstation-hunt/clues.txt
cd ~/workstation-hunt
pwd
```

**Proof:** Your prompt reports `~/workstation-hunt`, and `ls -la` reveals `.dotfiles-root`, `archive`, `clues.txt`, and `notes`.

- [ ] Mark **Camp established**.

<details>
<summary>Hint</summary>

`Super+Enter` opens Kitty. If the terminal did not start in the repository, change to the directory where you cloned it before running the commands.

</details>

## Chapter 2: Chart the Window Grid

**Clue:** Build and navigate this temporary i3 layout:

1. Open a second Kitty window.
2. Place the two windows side by side.
3. Move focus between them without using the mouse.
4. Move one terminal to workspace 2 and follow it there.
5. Return to the previously used workspace.
6. Switch the two-terminal container to tabbed layout, then back to a split layout.
7. Toggle one terminal fullscreen and return it to normal.
8. Enter resize mode, change one dimension, and leave resize mode.

**Proof:** You can tell whether the next command will **focus** a window, **move** a window, or **switch** a workspace before pressing it.

- [ ] Mark **i3 route completed**.

<details>
<summary>Hint</summary>

- Open Kitty: `Super+Enter`
- Focus: `Super+h/j/k/l`
- Move a window: `Super+Shift+h/j/k/l`
- Move to workspace 2: `Super+Shift+2`, then switch with `Super+2`
- Previous workspace: `Super+Tab`
- Tabbed layout: `Super+w`
- Split/layout toggle: `Super+s`
- Fullscreen: `Super+f`
- Resize mode: `Super+r`; resize with `h/j/k/l`; leave with `Enter` or `Escape`

</details>

## Chapter 3: Explore Kitty's Hidden Rooms

**Clue:** Inside one Kitty window, produce enough output to leave the screen, inspect that scrollback in Neovim, then create and navigate Kitty tabs.

```fish
seq 1 120
```

Complete all of the following:

- Open the scrollback buffer in Neovim and search for `100`.
- Return to the terminal.
- Create a Kitty tab.
- Move to the previous tab, then the next tab.
- Close only the extra tab.

**Proof:** The original shell and its output are still available after the extra tab is closed.

- [ ] Mark **Kitty route completed**.

<details>
<summary>Hint</summary>

- Scrollback in Neovim: `Ctrl+Shift+h`
- Search in Neovim: `/100`, then `Enter`; quit with `:q`
- Create tab: `Ctrl+Space`, then `c`
- Previous/next tab: `Ctrl+Space`, then `p` or `n`
- Close tab: `Ctrl+Space`, then `k`

</details>

## Chapter 4: Inventory the Toolbelt

**Clue:** Ask Fish which expedition tools are available, filter the clue list interactively, and use directory history rather than typing the full camp path a second time.

```fish
for tool in fish starship zoxide fzf yazi tmux nvim lazygit opencode
    command -q $tool; and printf '%-10s ready\n' $tool; or printf '%-10s missing\n' $tool
end

cat ~/workstation-hunt/clues.txt | fzf
cd ~
z workstation-hunt
```

Select `clipboard` in `fzf`.

**Proof:** Fish reports the installed tools, `fzf` returns `clipboard`, and the prompt returns to the camp through `zoxide`.

- [ ] Mark **Fish tools identified**.

<details>
<summary>Hint</summary>

Type part of `clipboard` in the `fzf` prompt and press `Enter`. If `z workstation-hunt` has not learned the directory yet, visit it once with `cd ~/workstation-hunt`, leave it, and try again.

</details>

## Chapter 5: Visit the File Ranger

**Clue:** Launch Yazi from camp. Without leaving Yazi, discover its help, reveal hidden files, preview `notes/field-notes.md`, and locate `.dotfiles-root`. Return to the same shell when finished.

**Proof:** You can state what `.dotfiles-root` contains and your shell remains in `~/workstation-hunt` after leaving Yazi.

- [ ] Mark **Yazi waypoint visited**.

<details>
<summary>Hint</summary>

Run `yazi`. Use Yazi's built-in help to discover its current bindings rather than assuming them; press `~` to open help and search for `hidden`, `open`, and `quit`.

</details>

## Chapter 6: Build a Persistent Base

**Clue:** Create a named tmux session that can survive its terminal window.

```fish
tmux new -s hunt
```

Inside tmux:

1. Split the current window into two panes.
2. Move focus between those panes with directional keys.
3. Create a second tmux window.
4. Return to the previous tmux window.
5. Type `tmux detach-client` at a shell prompt.
6. Close the now-ordinary Kitty window.
7. Recover the `hunt` session through the workstation's tmux session picker.

**Proof:** Both panes and both tmux windows still exist after recovery.

- [ ] Mark **tmux session recovered**.

<details>
<summary>Hint</summary>

- tmux `Prefix`: `Alt+Tab`
- Split: `Prefix`, then `v`
- Focus panes: `Prefix`, then `h/j/k/l`
- New window: `Prefix`, then `Enter`
- Last window: `Prefix`, then `Tab`
- Workstation session picker: `Super+t`

</details>

## Chapter 7: Decode the Field Note

**Clue:** In one tmux pane, open the field note:

```fish
nvim ~/workstation-hunt/notes/field-notes.md
```

Complete these edits using Neovim commands rather than mouse selection:

1. Change `camp established` to `route mapped` with a change operator and text motion.
2. Duplicate the token line.
3. Change the duplicated token to `Token: keyboard is king`.
4. Undo that last change, then redo it.
5. Open the keymap search and look for `yank history`.
6. Save without quitting, toggle Zen mode twice, then quit.

**Proof:** The note contains both token lines and no unsaved-change warning appears when you quit.

- [ ] Mark **Neovim note edited**.

<details>
<summary>Hint</summary>

- Move with `h/j/k/l`, `w`, and `b`.
- Place the cursor on `camp`, use `c$`, type `route mapped`, then press `Escape`.
- On the token line, use `yyp` to duplicate it.
- Use `ciw` on words or `cc` on the duplicated line, then type the replacement.
- Undo/redo: `u` / `Ctrl+r`
- Search keymaps: `Leader+fk`
- Save: `Leader+w`
- Zen mode: `Leader+z`
- Quit: `:q`

</details>

## Chapter 8: Cross the Clipboard Bridge

**Clue:** This setup deliberately treats clipboard operations differently inside tmux. Copy the line `Token: keyboard is king` from Neovim inside tmux to the desktop clipboard, then paste it into a Fish prompt in a separate Kitty window. Cancel the command instead of running it.

**Proof:** The exact token appears at the other prompt, proving that the copy crossed both Neovim and tmux.

- [ ] Mark **Clipboard bridge crossed**.

<details>
<summary>Hint</summary>

Inside tmux, place the cursor on the line and press `"+yy`. Open another Kitty window with `Super+Enter`, then paste with `Ctrl+Shift+v`. Press `Ctrl+c` to cancel the pasted command.

Ordinary `y` inside tmux uses Neovim's unnamed register; the explicit `+` register sends the text through OSC 52 to the desktop clipboard.

</details>

## Chapter 9: Inspect the Expedition History

**Clue:** Turn camp into a small Git repository without creating a commit, then inspect its state in Lazygit.

```fish
cd ~/workstation-hunt
git init
git add notes/field-notes.md clues.txt
git status --short
```

From the same shell, run `lazygit`, find the staged files, unstage one, stage it again, and quit Lazygit.

**Proof:** `git status --short` shows both practice files staged after you leave Lazygit.

- [ ] Mark **Git state inspected**.

<details>
<summary>Hint</summary>

In Lazygit, use `Tab` or the number keys to move between panels, `Space` to stage or unstage the selected file, and `q` to quit. The global `Super+g` shortcut also launches Lazygit in a fresh Kitty window, but running it from this shell keeps the exercise rooted in the practice repository.

</details>

## Chapter 10: Test the Desktop Portals

**Clue:** Use the desktop's configured handlers rather than launching applications by name. From Fish, open the profile image, one wallpaper, and the repository website.

```fish
set repo_root (cat ~/workstation-hunt/.dotfiles-root)
set wallpaper (find "$repo_root/wallpapers/Pictures/Wallpapers" -type f | head -n 1)
xdg-open "$repo_root/assets/pp.jpg"
xdg-open "$wallpaper"
xdg-open https://github.com/Malik-Hacini/dotfiles
```

Observe how image windows are grouped on the current workspace. Use i3 focus and tab controls to inspect both, then close them.

**Proof:** Images open through the configured image handler, the URL opens in Zen, and no application picker is required.

- [ ] Mark **Desktop handlers verified**.

<details>
<summary>Hint</summary>

The image handler is configured as `sxiv-tabbed.desktop`; web URLs use `zen.desktop`. Use `Super+w` if you need to restore a tabbed i3 layout and `Super+q` to close the focused window.

</details>

## Chapter 11: Locate the Safety Exits

**Clue:** Find and safely test the controls that help when the desktop configuration changes or a menu opens unexpectedly.

1. Reload the i3 configuration without ending the session.
2. Open the power menu and cancel it without choosing an action.
3. Take a screenshot and cancel or save it somewhere outside the repository.
4. Open the Bitwarden picker and cancel it, if Bitwarden is configured.
5. Open OpenCode and ask it to summarize `notes/field-notes.md`, if a provider is configured.

**Proof:** You can distinguish **reload i3**, **restart i3**, and **log out**, and you know how to cancel Rofi menus.

- [ ] Mark **Safety exits located**.

<details>
<summary>Hint</summary>

- Reload i3: `Super+Shift+c`
- Restart i3 in place: `Super+Shift+r` (recognize it; no need to test it)
- Power menu: `Super+p`; cancel with `Escape`
- Screenshot: `Print`
- Bitwarden: `Super+b`; cancel with `Escape`
- OpenCode: `Super+o`

</details>

## Final Challenge: The Working Loop

Complete this chapter without opening any hints above. The aim is not speed; it is being able to recover when focus or context changes.

1. Go to workspace 4.
2. Recover the `hunt` tmux session.
3. Arrange two panes with Neovim editing the field note in one and Yazi browsing camp in the other.
4. Add this final line to the note and save it:

   ```text
   Status: workstation route complete
   ```

5. Open Zen on another workspace, then return to workspace 4 using the previous-workspace shortcut.
6. Use Rofi's window mode to find one of your open Kitty windows.
7. Toggle the focused Kitty window fullscreen and back.
8. Capture a screenshot showing the restored tmux workspace. Save it outside the dotfiles repository.
9. Detach from tmux, then recover the session one final time.

**Completion evidence:**

```fish
grep 'workstation route complete' ~/workstation-hunt/notes/field-notes.md
tmux has-session -t hunt; and echo 'tmux session recovered'
git -C ~/workstation-hunt status --short
```

- [ ] Mark **Final workspace assembled**.
- [ ] Mark **Final note saved**.
- [ ] Mark **Final screenshot captured**.

## Debrief

You are comfortable with the setup when you can answer these without looking them up:

1. How do you launch an application when you do not know its shortcut?
2. How do you recover a terminal task after closing its Kitty window?
3. What is the difference between a Kitty tab, a tmux window, and an i3 workspace?
4. How do you copy from Neovim inside tmux to a graphical application?
5. How do you inspect a file without leaving the terminal workflow?
6. How do you reload i3 after changing its configuration?
7. Where should machine-specific settings and secrets live?
8. Which files in this repository are the source of truth: the package paths or their links under `$HOME`?

Return to [README.md](README.md) for setup details or [keybinds.md](keybinds.md) for the complete controls.

## Optional Cleanup

Keep the camp for later practice, or remove only the disposable directory and tmux session:

```fish
tmux kill-session -t hunt 2>/dev/null
rm -rf ~/workstation-hunt
```

Do not run the cleanup until you have saved any screenshot or note you want to keep.