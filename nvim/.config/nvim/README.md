# Neovim Configuration

This is a Lua-first Neovim configuration focused on:

- academic writing (LaTeX, Markdown, Typst)
- Python and notebook workflows
- modern editor UX (LSP, linting, formatting, Telescope, sessions)
- practical AI assistance with OpenCode and Copilot

To get detailed keymaps help, press leader (space) + f (find) + k (keymaps)
## Current Feature Set

- LaTeX: VimTeX workflow (build/view/toc/context/citations)
- Markdown: checkbox helpers, preview support
- Typst: tinymist LSP + typst preview tooling
- Jupyter: jupytext + Neopyter (JupyterLab bridge) workflow
- LSP: pyright, texlab, tinymist, lua-language-server, julials
- Formatting: conform.nvim (`<leader>lf`) with per-filetype formatters; format-on-save stays off by default
- Linting: nvim-lint (`<leader>lL`) with executable-aware setup and auto-lint toggles on `<leader>lg` / `<leader>lB`
- AI: OpenCode actions (`<leader>o`) plus Copilot control from `<leader>c`
- Focus: Zen mode on `<leader>z`

## Bibliography (Zotero)

The bibliography tooling expects the Zotero export at:

- `~/texmf/bibtex/bib/Zotero.bib`

If your bibliography file lives elsewhere, either create a symlink to this path or
adjust your local citation workflow settings.

## Quick Start

1. Open Neovim in this config.
2. Run `:Lazy sync`.
3. Run `:Mason` to inspect tool installs (auto-install is configured).
4. Run `:checkhealth`.

## Daily Commands

- Plugin management:
  - `:Lazy`
  - `:ReloadConfig` to reload config
- Focus:
  - `<leader>z` toggle Zen mode
- Formatting and linting:
  - `<leader>lf` format buffer/selection
  - `<leader>lL` lint now
  - `<leader>lg` / `<leader>lB` toggle auto-linting globally or per buffer
  - `:LintToggle` / `:LintToggle buffer`
- LSP lifecycle:
  - `<leader>lt` start (`:lsp enable`)
  - `<leader>lk` stop (`:lsp stop`)
  - `<leader>ls` restart (`:lsp restart`)

## AI Workflow

AI mappings are split by tool:

- OpenCode:
  - `<leader>o` prefix (provided by opencode.nvim defaults)
- Copilot:
  - `<leader>ce` enable
  - `<leader>cd` disable
  - `<leader>cs` status
  - `<leader>cp` panel
  - `<leader>cn` / `<leader>cb` next/prev suggestion
  - `<leader>cl` / `<leader>cw` accept line/word
  - `<leader>cx` dismiss suggestion

Notes:

- Copilot is lazy-loaded and not started automatically on launch.
- OpenCode is the primary in-editor chat/action workflow.

## Jupyter Workflow

This config uses a two-file notebook model:

- `.ju.py` (or `.ju.*`) is the editable source in Neovim.
- `.ipynb` is the browser/shareable notebook representation.

### Required Tools

- a usable Python interpreter (`python3` preferred, `python` fallback)
- `jupyter lab`
- `jupytext` CLI
- `neopyter` Python package (JupyterLab extension)

`<leader>jv` can bootstrap a project `.venv` with `jupyterlab`, `jupytext`, `ipykernel`, and `neopyter`, then register that environment as a kernel.

Notebook helpers prefer the project `.venv` when it exists, and fall back to `python3` or `python` otherwise.

### Recommended Daily Flow

1. Start from `.ipynb` and convert once with `<leader>jI` (opens `.ju.py`).
2. In `.ju.py`, use `<leader>jo` to open notebook in qutebrowser and sync Neovim to that browser tab.
3. Execute cells from Neovim (Ctrl/Shift/Alt Enter mappings below).
4. Save rich-output notebook with `<leader>jS`.

### `<leader>j` Mappings

- Session and sync:
  - `<leader>jo` open notebook in browser and connect/sync
  - `<leader>jc` connect Neopyter
  - `<leader>js` sync current notebook tab
  - `<leader>ji` Neopyter status
- Execution:
  - `<leader>je` run current cell
  - `<leader>jn` run cell and select next
  - `<leader>ja` run all cells
  - `<leader>jb` run selected and below
  - `<leader>jr` restart kernel
  - `<leader>jR` restart kernel and run all
- File operations:
  - `<leader>jI` convert current `.ipynb` to `.ju.py` and open it
  - `<leader>jS` save `.ipynb` with outputs
  - `<leader>jv` bootstrap project `.venv`, install notebook tooling, and register kernel

### Cell Execution Shortcuts (`*.ju.*` buffers)

- `<C-Enter>` / `<C-CR>` run current cell
- `<S-Enter>` / `<S-CR>` run current cell and select next
- `<A-Enter>` / `<A-CR>` run current cell and insert below

### Notes

- `.ipynb` opened directly in Neovim is handled by `jupytext.nvim` and shown as language text (usually Python), not raw JSON.
- Neopyter direct mode uses a single local address (`127.0.0.1:9001`): multiple Neovim sessions can be open, but only one can own the active Neopyter bridge at a time.

## Tooling Model

The config prepends Mason binaries to Neovim PATH at startup, so editor tools are resolved inside Neovim even if your shell PATH differs.

### LSP Servers

- `clangd` (C/C++)
- `cmake` (CMake)
- `pyright` (Python)
- `texlab` (LaTeX)
- `tinymist` (Typst)
- `lua_ls` (Lua)
- `julials` (Julia)

For C/C++ projects, `clangd` works best when the project exposes `compile_commands.json`
or `compile_flags.txt` near the source root or build directory.

### Julia LSP Notes

Julia support uses `vim.lsp.config(...)` for `julials`, while Mason still manages the other
servers normally. `julials` is excluded from Mason auto-enable because the packaged
`julia-lsp` wrapper can break on newer Julia releases.

Requirements:

- `julia` must be on PATH inside Neovim (this config prepends `~/.juliaup/bin` when present)
- Treesitter parser `julia` is auto-installed by `nvim-treesitter`
- a local Julia LSP environment must exist at `~/.julia/environments/nvim-lspconfig`

Bootstrap that environment once on any machine with Julia installed:

```sh
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add("LanguageServer"); Pkg.add("SymbolServer"); Pkg.add("StaticLint"); Pkg.instantiate()'
```

If Julia 1.12+ shows SymbolServer/world-age failures with released packages, update to the
newer upstream branches:

```sh
julia --startup-file=no --history-file=no --project="$HOME/.julia/environments/nvim-lspconfig" -e 'using Pkg; Pkg.add(PackageSpec(name="LanguageServer", rev="main")); Pkg.add(PackageSpec(name="SymbolServer", rev="master")); Pkg.add(PackageSpec(name="StaticLint", rev="master")); Pkg.instantiate(); Pkg.precompile()'
```

Project usage:

- open Neovim from a Julia project directory when possible
- ensure project dependencies are installed with:

```sh
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### Formatters

- Lua: `stylua`
- Python: `isort`, `black`
- JS/TS/CSS/HTML/JSON/YAML/Markdown: `prettier`
- C/C++: `clang-format`
- Shell: `shfmt`
- TeX: `latexindent`

### Linters (dynamic by executable)

- Python: `pylint`
- Lua: `luacheck` or fallback `selene`
- JS/TS: `eslint` or fallback `eslint_d`
- CSS: `stylelint`
- HTML: `tidy` or fallback `htmlhint`
- JSON: `jsonlint`
- YAML: `yamllint`
- Shell: `shellcheck`
- Markdown: `markdownlint`
- C/C++: `cppcheck` or fallback `cpplint`

## Directory Map

- `init.lua`: entry point
- `lua/config/`: options, keymaps, autocmds
- `lua/plugins/`: lazy.nvim plugin specs by domain
- `lua/util/`: reusable helper modules and user commands
- `after/ftplugin/`, `after/ftdetect/`: filetype-specific behavior
- `templates/`, `snippets/`, `LuaSnip/`: writing support assets

## Performance and Health

- `:AnalyzeStartup`
- `:ProfilePlugins`
- `:OptimizationReport`
- `:SuggestLazyLoading`
- `:checkhealth`

## Related Docs

- `AGENTS.md`: machine-readable project context and conventions
- `OPTIMIZATION.md`: optimization strategy and workflow
- `lua/plugins/README.md`: plugin category layout
- `lua/config/README.md`: core config module notes
- `lua/util/README.md`: utility modules and user commands
