# UI Plugins

This directory contains interface-layer plugins.

## Included Specs

- `colorscheme.lua`: Catppuccin theme setup
- `lualine.lua`: statusline
- `bufferline.lua`: buffer/tab line behavior
- `nvim-web-devicons.lua`: icon provider
- `sessions.lua`: session persistence and restore flow

UI plugins should avoid owning core editor logic; keep behavior-oriented workflows in `editor/` or `tools/`.

Note: File navigation is handled by `yazi.nvim` in `tools/` (replaces nvim-tree).
