-----------------------------------------------------------
-- NeoVim Plugin Specification Loader
-- 
-- This module organizes and loads plugin specifications by category.
-- It provides a structured way to manage plugins while maintaining
-- backward compatibility with the previous organization.
--
-- This is the new version that is designed to work with the restructured
-- plugin directory organization where plugins are grouped by category.
--
-- Plugin Categories:
-- - editor: Core editor capabilities (formatting, linting, telescope, etc.)
-- - lsp: Language server integration and configuration
-- - tools: External tool integration (git, AI, file navigation, etc.)
-- - text: Writing-focused plugins (vimtex, markdown, jupyter)
-- - ui: User interface components (theme, statusline, bufferline, etc.)
-- - typst: Typst support (preview, vim-typst, LuaSnip config)
--
-- Each plugin category has its own directory and init.lua file.
-- This module no longer tries to load plugins from the root plugins directory,
-- avoiding conflicts with the legacy structure.
-----------------------------------------------------------

-- This file simply returns an empty table
-- The new plugin system relies on bootstrap.lua directly importing
-- plugins from each category directory (ui, tools, editor, etc.)
-- 
-- This avoids trying to load the legacy plugins from the flat structure.

return {}