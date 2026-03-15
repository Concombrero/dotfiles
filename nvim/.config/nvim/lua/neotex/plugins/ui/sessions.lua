return {
  "Shatur/neovim-session-manager",
  event = "VimEnter",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
  },
  config = function()
    local Path = require('plenary.path')
    local config = require('session_manager.config')
    local sessions_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'sessions')

    vim.fn.mkdir(sessions_dir, 'p')

    require('session_manager').setup({
      -- stdpath('data') is machine-local and keeps existing sessions intact.
      sessions_dir = Path:new(sessions_dir),
      -- The character to which the path separator will be replaced for session files
      -- path_replacer = '__',
      -- The character to which the colon symbol will be replaced for session files
      -- colon_replacer = '++',
      -- Define what to do when Neovim is started without arguments
      autoload_mode = config.AutoloadMode.Disabled,
      -- Automatically save last session on exit and on session switch
      autosave_last_session = true,
      -- Plugin will not save a session when no buffers are opened, or all of them aren't writable or listed
      autosave_ignore_not_normal = true,
      -- A list of directories where the session will not be autosaved
      autosave_ignore_dirs = {},
      -- All buffers of these file types will be closed before the session is saved
      autosave_ignore_filetypes = {
        'gitcommit',
        'gitrebase',
        'qf',           -- Quickfix lists
        'help',         -- Help buffers
        'TelescopePrompt', -- Telescope
        'NvimTree',     -- File explorer
        'fugitive',     -- Git UI
        'gitcommit',    -- Git commit message
        'diff',         -- Diff view
        'undotree',     -- Undo tree
        'toggleterm',   -- Terminal
        'trouble',      -- Diagnostic lists
        'nofile',       -- Non-file buffers
      },
      -- All buffers of these buffer types will be closed before the session is saved
      autosave_ignore_buftypes = { 
        'terminal',
        'quickfix',    -- Quickfix lists
        'nofile',      -- General non-file buffers
        'nowrite',     -- Buffers that can't be written
        'acwrite',     -- Auto-command written buffers
        'prompt',      -- Prompt buffers
        'popup',       -- Popup windows
        'help',        -- Help pages
      },
      -- Always autosaves session. If true, only autosaves after a session is active
      autosave_only_in_session = true,
      -- Shorten the display path if length exceeds this threshold. Use 0 if don't want to shorten the path at all
      max_path_length = 80,
    })
  end,
}
