# Notes

Working notes for NeoTex maintenance and demos.

## Demo Flow (Current)

1. Open dashboard and restore a session.
2. Show LaTeX workflow: compile (`<leader>b`), view (`<leader>v`), toc (`<leader>i`).
3. Show Markdown workflow: checkbox + formatting (`<leader>mp`).
4. Show Git workflow: LazyGit (`<leader>g`).
5. Show AI workflow:
   - OpenCode (`<leader>o`)
   - Copilot (`<leader>c`): enable/status/disable
6. Show Jupyter workflow from `<leader>j` (run cell, run all, REPL send).

## Maintenance Notes

- Keep `README.md` and `lua/neotex/plugins/editor/which-key.lua` header aligned.
- Prefer concise docs over exhaustive key tables to reduce drift.
- When behavior changes, update these first:
  - `README.md`
  - `AGENTS.md`
  - module README files under `lua/neotex/**/README.md`
