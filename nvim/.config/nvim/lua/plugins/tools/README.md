# Tool Plugins

This directory hosts integrations and utility plugins that extend core editing.

## Major Areas

- Git: `gitsigns.lua`, `diffview.lua`
- AI: `opencode.lua`, `copilot.lua`
- File navigation helpers: `yazi.lua`
- Text utilities: `mini.lua`, `surround.lua`, `todo-comments.lua`, `yanky.lua`
- UI utility suite: `snacks/`

## Notes

- Diffview handles Git review, file history, and merge conflict views.
- Snacks is used for dashboard/notifier/statuscolumn/input/terminal helpers.
- Keep tool specs small and composable; avoid putting large editor-flow logic here.
