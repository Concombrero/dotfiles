-----------------------------------------------------------
-- NeoVim Configuration Entry Point
-- Author: Malik Hacini 
-- 
-- This is the main entry point for NeoVim configuration.
-- It sets the leader key and loads the configuration modules.
-- The loading process includes fallbacks to ensure NeoVim 
-- starts properly even if there are errors in the configuration.
--
-- Structure:
-- - neotex/bootstrap.lua: Handles plugin and feature initialization
-- - neotex/config/: Core configuration modules
-- - neotex/util/: Utility functions
-- - neotex/plugins/: Plugin specification and configuration
-----------------------------------------------------------

-- Set notification level to show only important messages
vim.notify_level = vim.log.levels.INFO

-- Set leader key BEFORE loading lazy or any other plugins
-- This is critical and must happen first
vim.g.mapleader = " " -- Space as leader key

-- Disable selected built-in runtime plugins early so startup can skip sourcing them.
-- This must happen before any plugin/bootstrap logic.
local disabled_builtin_plugins = {
  loaded_matchit = 1,
  loaded_matchparen = 1,
  loaded_tutor_mode_plugin = 1,
  loaded_2html_plugin = 1,
  loaded_zipPlugin = 1,
  loaded_tarPlugin = 1,
  loaded_gzip = 1,
  loaded_netrw = 1,
  loaded_netrwPlugin = 1,
  loaded_netrwSettings = 1,
  loaded_netrwFileHandlers = 1,
  loaded_spellfile_plugin = 1,
}

for plugin_name, disabled in pairs(disabled_builtin_plugins) do
  vim.g[plugin_name] = disabled
end

-- Ensure legacy netrw augroup exists to avoid noisy startup errors
-- from plugins that clear `FileExplorer` autocmds conditionally.
pcall(vim.api.nvim_create_augroup, "FileExplorer", { clear = true })

-- Ensure essential tool directories are on PATH regardless of how Neovim
-- was launched (desktop entry, session restore, etc.).  Only directories
-- that actually exist are prepended, and duplicates are skipped.
local function prepend_to_path(dir)
  dir = vim.fn.expand(dir)
  if vim.fn.isdirectory(dir) == 1 and not vim.env.PATH:find(vim.pesc(dir), 1, true) then
    vim.env.PATH = dir .. ":" .. vim.env.PATH
  end
end

prepend_to_path(vim.fn.stdpath("data") .. "/mason/bin") -- Mason-installed LSP/tools
prepend_to_path("~/.local/bin")                         -- pipx, zoxide, user scripts
prepend_to_path("~/.juliaup/bin")                      -- Julia and juliaup-managed tools
prepend_to_path("~/.fzf/bin")                           -- fzf (used by yazi, telescope, etc.)
prepend_to_path("~/.opencode/bin")                      -- opencode CLI
prepend_to_path("~/typst-x86_64-unknown-linux-musl")    -- typst binary

-- Load configuration with improved error handling
local config_ok, config = pcall(require, "neotex.config")
local bootstrap_ok, bootstrap = pcall(require, "neotex.bootstrap")

-- Make sure bootstrap exists before trying to use it
if bootstrap_ok and type(bootstrap) == "table" and type(bootstrap.init) == "function" then
  bootstrap.init()
end

-- If the new config structure fails, set up minimal fallback
if not config_ok then
  vim.notify("Error loading config structure: " .. tostring(config) .. ". Using minimal fallback.", vim.log.levels.WARN)
  -- Minimal fallback options without depending on deprecated modules
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.wrap = true
  vim.opt.breakindent = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.mouse = "a"
else
  -- Load the new configuration
  pcall(config.setup)
end

-- If bootstrap fails, set up minimal fallback
if not bootstrap_ok then
  vim.notify("Error loading bootstrap: " .. tostring(bootstrap) .. ". Using minimal fallback.", vim.log.levels.WARN)
  -- Ensure minimal plugin management functionality
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if vim.loop.fs_stat(lazypath) then
    vim.opt.rtp:prepend(lazypath)
    pcall(require, "lazy")
  end
end
