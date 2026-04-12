# Plugin Layout

Plugin specs are organized by domain and loaded through lazy.nvim category imports.

## Categories

- `editor/`: core editing workflow
  - `which-key.lua`, `formatting.lua`, `linting.lua`, `telescope.lua`, `toggleterm.lua`, `treesitter.lua`
- `lsp/`: LSP/completion and external tool management
  - `lspconfig.lua`, `mason.lua`, `nvim-cmp.lua`, `vimtex-cmp.lua`
- `tools/`: utility and integration plugins
  - git (`gitsigns.lua`, `diffview.lua`), AI (`opencode.lua`, `copilot.lua`), file tools (`yazi.lua`), editor helpers (`mini.lua`, `surround.lua`, `todo-comments.lua`, `yanky.lua`, `snacks/`)
- `text/`: writing-focused plugins
  - `vimtex.lua`, `markdown-preview.lua`, `jupyter/`
- `ui/`: visual shell around editing
  - `colorscheme.lua`, `lualine.lua`, `bufferline.lua`, `nvim-web-devicons.lua`, `sessions.lua`, `zen_mode.lua`
- `typst/`: Typst support
  - `typst-preview.lua`, `typst-vim.lua`, `luasnip.lua`

## Loading Model

- Each category has an `init.lua` aggregator.
- `lua/bootstrap.lua` imports category modules into `lazy.setup(...)`.
- `lua/plugins/init.lua` remains a compatibility shim returning `{}`.

## Notes

- `diffview.nvim` is the main Git review/history/merge UI.
- `yazi.nvim` handles file navigation (replaces nvim-tree).
