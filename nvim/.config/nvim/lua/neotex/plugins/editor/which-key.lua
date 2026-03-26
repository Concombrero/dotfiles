-- Keep all global `<leader>` mappings in this file so which-key remains the
-- single source of truth. Avoid defining leader bindings inside plugin specs.

local function opencode_call(method, ...)
  local args = { ... }

  return function()
    require("lazy").load({ plugins = { "opencode.nvim" } })
    require("opencode.api")[method](table.unpack(args))
  end
end

local function run_buffer_command(command_name, missing_message)
  return function()
    local bufnr = vim.api.nvim_get_current_buf()
    local commands = vim.api.nvim_buf_get_commands(bufnr, { builtin = false })

    if commands[command_name] then
      vim.cmd(command_name)
      return
    end

    vim.notify(missing_message, vim.log.levels.WARN)
  end
end

local function build_current_buffer()
  if vim.bo.makeprg == nil or vim.bo.makeprg == "" then
    local target = vim.bo.filetype ~= "" and (vim.bo.filetype .. " buffers") or "this buffer"
    vim.notify("No build command configured for " .. target, vim.log.levels.WARN)
    return
  end

  vim.cmd("update")
  vim.cmd("make")
end

local function open_yank_history()
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    lazy.load({ plugins = { "yanky.nvim" } })
  end

  if type(_G.YankyTelescopeHistory) == "function" then
    _G.YankyTelescopeHistory()
    return
  end

  local telescope_ok, telescope = pcall(require, "telescope")
  if telescope_ok and telescope.extensions and telescope.extensions.yank_history then
    telescope.extensions.yank_history.yank_history()
    return
  end

  vim.notify("Yank history is unavailable", vim.log.levels.WARN)
end

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  dependencies = {
    'echasnovski/mini.nvim',
  },
  opts = {
    setup = {
      show_help = false,
      show_keys = false, -- show the currently pressed key and its label as a message in the command line
      notify = false,    -- prevent which-key from automatically setting up fields for defined mappings
      triggers = {
        { "<leader>", mode = { "n", "v" } },
      },
      plugins = {
        presets = {
          marks = false,        -- shows a list of your marks on ' and `
          registers = false,    -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          spelling = {
            enabled = false,    -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 10,   -- how many suggestions should be shown in the list?
          },
          operators = false,    -- adds help for operators like d, y, ... and registers them for motion / text object completion
          motions = false,      -- adds help for motions
          text_objects = false, -- help for text objects triggered after entering an operator
          windows = false,      -- default bindings on <c-w>
          nav = false,          -- misc bindings to work with windows
          z = false,            -- bindings for folds, spelling and others prefixed with z
          g = false,            -- bindings for prefixed with g
        },
      },
      win = {
        no_overlap = true,
        -- width = 1,
        -- height = { min = 4, max = 25 },
        -- col = 0,
        -- row = math.huge,
        border = "rounded", -- can be 'none', 'single', 'double', 'shadow', etc.
        padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
        title = false,
        title_pos = "center",
        zindex = 1000,
        -- Additional vim.wo and vim.bo options
        bo = {},
        wo = {
          winblend = 0, -- fully opaque to avoid background bleed artifacts
        },
      },
      -- add operators that will trigger motion and text object completion
      -- to enable native operators, set the preset / operators plugin above
      -- operators = { gc = "Comments" },
      icons = {
        breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
        separator = "➜", -- Separator between key and label
        group = "",
        mappings = false,
        colors = false,
      },
      layout = {
        width = { min = 20, max = 50 }, -- min and max width of the columns
        height = { min = 4, max = 25 }, -- min and max height of the columns
        spacing = 3,                    -- spacing between columns
        align = "left",                 -- align columns left, center or right
      },
      keys = {
        scroll_down = "<c-d>", -- binding to scroll down inside the popup
        scroll_up = "<c-u>",   -- binding to scroll up inside the popup
      },
      sort = { "local", "order", "group", "alphanum", "mod" },
      -- disable the WhichKey popup for certain buf types and file types.
      -- Disabled by default for Telescope
      disable = {
        bt = { "help", "quickfix", "terminal", "prompt" }, -- for example
        ft = { "NvimTree" }                                -- add your explorer's filetype here
      }
    },
    defaults = {
      buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true,  -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true,  -- use `nowait` when creating keymaps
      prefix = "<leader>",
      mode = { "n", "v" },
      b = { build_current_buffer, "build", mode = "n" },
      h = { "<cmd>vert sb<CR>", "create split" },
      d = { "<cmd>update! | lua Snacks.bufdelete()<CR>", "delete buffer" },
      e = { "<cmd>Yazi<CR>", "explorer" },
      g = { "<cmd>lua vim.schedule(function() require('neotex.plugins.tools.snacks.utils').safe_lazygit() end)<cr>", "lazygit" },
      p = { "<cmd>b#<CR>", "alternate buffer", mode = "n" },
      q = { "<cmd>wa! | qa!<CR>", "quit" },
      w = { "<cmd>wa!<CR>", "write" },
      x = {
        name = "latex",
        b = { "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", "bib export" },
        c = { "<cmd>:VimtexClearCache All<CR>", "clear vimtex" },
        e = { "<cmd>VimtexErrors<CR>", "error report" },
        i = { "<cmd>VimtexTocOpen<CR>", "index" },
        k = { "<cmd>VimtexClean<CR>", "kill aux" },
        m = { "<plug>(vimtex-context-menu)", "vimtex menu" },
        v = { "<cmd>VimtexView<CR>", "view" },
        w = { "<cmd>VimtexCountWords!<CR>", "word count" },
      },
      f = {
        name = "find",
        a = { "<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, search_dirs = { '~/' } })<CR>", "all files" },
        b = {
          "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<CR>",
          "buffers",
        },
        c = { "<cmd>Telescope bibtex format_string=\\citet{%s}<CR>", "citations" },
        f = { "<cmd>Telescope find_files<CR>", "files" },
        l = { "<cmd>Telescope resume<CR>", "last search" },
        p = { "<cmd>Telescope live_grep theme=ivy<CR>", "project grep" },
        q = { "<cmd>Telescope quickfix<CR>", "quickfix" },
        g = { "<cmd>Telescope git_commits<CR>", "git history" },
        h = { "<cmd>Telescope help_tags<CR>", "help" },
        k = { "<cmd>Telescope keymaps<CR>", "keymaps" },
        r = { "<cmd>Telescope registers<CR>", "registers" },
        t = { "<cmd>TodoTelescope<CR>", "todos" },
        u = { "<cmd>Telescope undo<CR>", "undo" },
        s = { "<cmd>Telescope grep_string<CR>", "string" },
        w = { "<cmd>lua SearchWordUnderCursor()<CR>", "word" },
        y = { open_yank_history, "yanks", mode = "n" },
      },
      g = { "<cmd>lua vim.schedule(function() require('neotex.plugins.tools.snacks.utils').safe_lazygit() end)<cr>", "lazygit" },
      c = {
        name = "copilot",
        e = { "<cmd>Copilot enable<CR>", "copilot enable" },
        d = { "<cmd>Copilot disable<CR>", "copilot disable" },
        s = { "<cmd>Copilot status<CR>", "copilot status" },
        p = { "<cmd>Copilot panel<CR>", "copilot panel" },
        n = { function() require("copilot.suggestion").next() end, "copilot next" },
        b = { function() require("copilot.suggestion").prev() end, "copilot prev" },
        l = { function() require("copilot.suggestion").accept_line() end, "copilot line" },
        w = { function() require("copilot.suggestion").accept_word() end, "copilot word" },
        x = { function() require("copilot.suggestion").dismiss() end, "copilot dismiss" },
      },
      o = {
        name = "opencode",
        a = { opencode_call("quick_chat"), "ask" },
        ["["] = { opencode_call("diff_prev"), "previous diff" },
        ["]"] = { opencode_call("diff_next"), "next diff" },
        I = { opencode_call("open_input_new_session"), "open input (new session)" },
        R = { opencode_call("rename_session"), "rename session" },
        T = { opencode_call("timeline"), "session timeline" },
        V = { opencode_call("configure_variant"), "configure model variant" },
        c = { opencode_call("diff_close"), "close diff view" },
        d = { opencode_call("diff_open"), "open diff view" },
        g = { opencode_call("toggle"), "toggle opencode window" },
        h = { opencode_call("select_history"), "select from history" },
        i = { opencode_call("open_input"), "open input window" },
        o = { opencode_call("open_output"), "open output window" },
        p = { opencode_call("configure_provider"), "configure provider" },
        q = { opencode_call("close"), "close opencode window" },
        r = {
          name = "restore/revert",
          a = { opencode_call("diff_revert_all_last_prompt"), "revert all (last prompt)" },
          A = { opencode_call("diff_revert_all"), "revert all changes" },
          r = { opencode_call("diff_restore_snapshot_file"), "restore file snapshot" },
          R = { opencode_call("diff_restore_snapshot_all"), "restore all snapshots" },
          t = { opencode_call("diff_revert_this_last_prompt"), "revert this (last prompt)" },
          T = { opencode_call("diff_revert_this"), "revert this change" },
        },
        s = { opencode_call("select_session"), "select session" },
        t = { opencode_call("toggle_focus"), "toggle focus" },
        v = { opencode_call("paste_image"), "paste image from clipboard" },
        x = { opencode_call("swap_position"), "swap window position" },
        y = { opencode_call("add_visual_selection"), "add visual selection to context", mode = "v" },
        z = { opencode_call("toggle_zoom"), "toggle zoom" },
        tr = { opencode_call("toggle_reasoning_output"), "toggle reasoning output" },
        tt = { opencode_call("toggle_tool_output"), "toggle tool output" },
      },
      -- LIST MAPPINGS
      j = {
        name = "jupyter",
        c = { "<cmd>Neopyter connect<CR>", "connect Neopyter" },
        i = { "<cmd>Neopyter status<CR>", "Neopyter status" },
        I = { "<cmd>lua require('neotex.util.jupyter').convert_current_ipynb_to_ju()<CR>", "convert ipynb to ju.py" },
        s = { "<cmd>Neopyter sync current<CR>", "sync current notebook tab" },
        e = { "<cmd>Neopyter run current<CR>", "run current cell" },
        n = { "<cmd>Neopyter execute notebook:run-cell-and-select-next<CR>", "run and select next" },
        o = { "<cmd>lua require('neotex.util.jupyter').open_current_notebook()<CR>", "open notebook in browser" },
        a = { "<cmd>Neopyter run all<CR>", "run all cells" },
        b = { "<cmd>Neopyter run allBelow<CR>", "run selected and below" },
        r = { "<cmd>Neopyter kernel restart<CR>", "restart kernel" },
        R = { "<cmd>Neopyter kernel restartRunAll<CR>", "restart and run all" },
        v = { "<cmd>lua require('neotex.util.jupyter').setup_project_venv()<CR>", "bootstrap .venv (py3.12)" },
        S = { "<cmd>lua require('neotex.util.jupyter').save_current_as_ipynb()<CR>", "save ipynb with outputs" },
      },
      L = {
        name = "list",
      },
      l = {
        name = "lsp",
        -- LSP operations
        b = { "<cmd>Telescope diagnostics bufnr=0<CR>", "buffer diagnostics" },
        c = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "code action" },
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "definition" },
        D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
        H = {
          run_buffer_command(
            "LspClangdSwitchSourceHeader",
            "Clangd source/header switching is only available in a C/C++ buffer"
          ),
          "switch source/header",
        },
        f = { function() require("conform").format({ async = true, lsp_fallback = true }) end, "format buffer" },
        h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "help" },
        i = { "<cmd>Telescope lsp_implementations<CR>", "implementations" },
        k = { "<cmd>lsp stop<CR>", "stop lsp" },
        l = { "<cmd>lua vim.diagnostic.open_float()<CR>", "line diagnostics" },
        n = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "next diagnostic" },
        p = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "previous diagnostic" },
        r = { "<cmd>Telescope lsp_references<CR>", "references" },
        s = { "<cmd>lsp restart<CR>", "restart lsp" },
        S = {
          run_buffer_command(
            "LspClangdShowSymbolInfo",
            "Clangd symbol info is only available in a C/C++ buffer"
          ),
          "clangd symbol info",
        },
        t = { "<cmd>lsp enable<CR>", "start lsp" },
        y = { "<cmd>lua CopyDiagnosticsToClipboard()<CR>", "copy diagnostics to clipboard" },
        R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
        -- T = { "<cmd>Telescope lsp_type_definitions<CR>", "type definition" },

        -- Linting operations
        L = {
          function()
            if _G.lint_try_lint then
              _G.lint_try_lint()
              return
            end

            require("lint").try_lint()
          end,
          "lint file",
        },
        g = { "<cmd>LintToggle<CR>", "toggle global linting" },
        B = { "<cmd>LintToggle buffer<CR>", "toggle buffer linting" },
      },
      -- MARKDOWN MAPPINGS
      m = {
        name = "markdown",
        s = { "<cmd>LecticSubmitSelection<CR>", "submit selection with message" },

        -- MARKDOWN/PREVIEW
        o = { "<cmd>MarkdownPreviewToggle<CR>", "open markdown preview" },
        u = { "<cmd>lua OpenUrlUnderCursor()<CR>", "open URL under cursor" },

        -- FOLDING
        a = { "<cmd>lua ToggleAllFolds()<CR>", "toggle all folds" },
        f = { "za", "toggle fold under cursor" },
        t = { "<cmd>lua ToggleFoldingMethod()<CR>", "toggle folding method" },
      },
      s = {
        name = "sessions",
        s = { "<cmd>SessionManager save_current_session<CR>", "save" },
        d = { "<cmd>SessionManager delete_session<CR>", "delete" },
        l = { "<cmd>SessionManager load_session<CR>", "load" },
      },



      t = {
        name = "typst",
        o = { "<cmd>TypstPreview<CR>", "preview" },
        p = { "<cmd>TypstPreviewToggle<CR>", "toggle preview" },
        s = { "<cmd>TypstPreviewStop<CR>", "stop preview" },
        f = { "<cmd>TypstPreviewFollowCursorToggle<CR>", "toggle cursor follow" },
        w = { "<cmd>TypstWatch<CR>", "watch" },
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    wk.setup(opts.setup)
    wk.register(opts.defaults)
  end,
}
