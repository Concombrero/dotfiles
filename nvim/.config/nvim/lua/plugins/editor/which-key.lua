-- Keep all global `<leader>` mappings in this file so which-key remains the
-- single source of truth. Avoid defining leader bindings inside plugin specs.

local function opencode_call(method)

  return function()
    require("lazy").load({ plugins = { "opencode.nvim" } })
    require("opencode.api")[method]()
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

  if vim.fn.exists(":YankyHistory") == 2 then
    vim.cmd("YankyHistory")
    return
  end

  local telescope_ok, telescope = pcall(require, "telescope")
  if telescope_ok and telescope.extensions and telescope.extensions.yank_history then
    telescope.extensions.yank_history.yank_history()
    return
  end

  vim.notify("Yank history is unavailable", vim.log.levels.WARN)
end

local function get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
    return nil
  end

  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), {
    type = mode,
    exclusive = vim.o.selection == "exclusive",
  })

  local selection = table.concat(lines, " "):gsub("%s+", " ")
  selection = vim.trim(selection)

  if selection == "" then
    return nil
  end

  return selection
end

local function live_grep_word_or_selection()
  require("telescope.builtin").live_grep({
    default_text = get_visual_selection() or vim.fn.expand("<cword>"),
  })
end

local function toggle_diffview()
  local ok, lib = pcall(require, "diffview.lib")
  if ok and lib.get_current_view() then
    vim.cmd("DiffviewClose")
    return
  end

  vim.cmd("DiffviewOpen")
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
      }
    },
    spec = {
      {
        mode = { "n", "v" },
        silent = true,
        nowait = true,
        remap = false,

        { "<leader>L", group = "list" },

        { "<leader>b", build_current_buffer, desc = "build", mode = "n" },
        { "<leader>d", "<cmd>update! | lua Snacks.bufdelete()<CR>", desc = "delete buffer" },
        { "<leader>e", "<cmd>Yazi<CR>", desc = "explorer" },
        { "<leader>g", toggle_diffview, desc = "git diff", mode = "n" },
        { "<leader>h", "<cmd>vert sb<CR>", desc = "horizontal split" },
        { "<leader>a", "<cmd>b#<CR>", desc = "alternate buffer", mode = "n" },
        { "<leader>q", "<cmd>wa! | qa!<CR>", desc = "quit" },
        { "<leader>w", "<cmd>wa!<CR>", desc = "write" },
        { "<leader>z", "<cmd>ZenMode<CR>", desc = "zen mode" },

        {
          "<leader>c",
          group = "copilot",
          { "<leader>cb", function() require("copilot.suggestion").prev() end, desc = "copilot prev" },
          { "<leader>cd", "<cmd>Copilot disable<CR>", desc = "copilot disable" },
          { "<leader>ce", "<cmd>Copilot enable<CR>", desc = "copilot enable" },
          { "<leader>cl", function() require("copilot.suggestion").accept_line() end, desc = "copilot line" },
          { "<leader>cn", function() require("copilot.suggestion").next() end, desc = "copilot next" },
          { "<leader>cp", "<cmd>Copilot panel<CR>", desc = "copilot panel" },
          { "<leader>cs", "<cmd>Copilot status<CR>", desc = "copilot status" },
          { "<leader>cw", function() require("copilot.suggestion").accept_word() end, desc = "copilot word" },
          { "<leader>cx", function() require("copilot.suggestion").dismiss() end, desc = "copilot dismiss" },
        },

        {
          "<leader>f",
          group = "find",
          { "<leader>fa", "<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, search_dirs = { '~/' } })<CR>", desc = "all files" },
          {
            "<leader>fb",
            "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<CR>",
            desc = "buffers",
          },
          { "<leader>fc", "<cmd>Telescope bibtex format_string=\\citet{%s}<CR>", desc = "citations" },
          { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "files" },
          { "<leader>fg", "<cmd>Telescope git_commits<CR>", desc = "git history" },
          { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "help" },
          { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "keymaps" },
          { "<leader>fl", "<cmd>Telescope resume<CR>", desc = "last search" },
          { "<leader>fp", "<cmd>Telescope live_grep <CR>", desc = "project grep" },
          { "<leader>fq", "<cmd>Telescope quickfix<CR>", desc = "quickfix" },
          { "<leader>fr", "<cmd>Telescope registers<CR>", desc = "registers" },
          { "<leader>fs", live_grep_word_or_selection, desc = "word/selection" },
          { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "todos" },
          { "<leader>fu", "<cmd>Telescope undo<CR>", desc = "undo" },
          { "<leader>fy", open_yank_history, desc = "yanks", mode = "n" },
        },

        {
          "<leader>j",
          group = "jupyter",
          { "<leader>jI", "<cmd>lua require('util.jupyter').convert_current_ipynb_to_ju()<CR>", desc = "convert ipynb to ju.py" },
          { "<leader>jR", "<cmd>Neopyter kernel restartRunAll<CR>", desc = "restart and run all" },
          { "<leader>jS", "<cmd>lua require('util.jupyter').save_current_as_ipynb()<CR>", desc = "save ipynb with outputs" },
          { "<leader>ja", "<cmd>Neopyter run all<CR>", desc = "run all cells" },
          { "<leader>jb", "<cmd>Neopyter run allBelow<CR>", desc = "run selected and below" },
          { "<leader>jc", "<cmd>Neopyter connect<CR>", desc = "connect Neopyter" },
          { "<leader>je", "<cmd>Neopyter run current<CR>", desc = "run current cell" },
          { "<leader>ji", "<cmd>Neopyter status<CR>", desc = "Neopyter status" },
          { "<leader>jn", "<cmd>Neopyter execute notebook:run-cell-and-select-next<CR>", desc = "run and select next" },
          { "<leader>jo", "<cmd>lua require('util.jupyter').open_current_notebook()<CR>", desc = "open notebook in browser" },
          { "<leader>jr", "<cmd>Neopyter kernel restart<CR>", desc = "restart kernel" },
          { "<leader>js", "<cmd>Neopyter sync current<CR>", desc = "sync current notebook tab" },
          { "<leader>jv", "<cmd>lua require('util.jupyter').setup_project_venv()<CR>", desc = "bootstrap .venv" },
        },

        {
          "<leader>l",
          group = "lsp",
          { "<leader>lB", "<cmd>LintToggle buffer<CR>", desc = "toggle buffer linting" },
          { "<leader>lD", "<cmd>lua vim.lsp.buf.declaration()<CR>", desc = "declaration" },
          {
            "<leader>lH",
            run_buffer_command(
              "LspClangdSwitchSourceHeader",
              "Clangd source/header switching is only available in a C/C++ buffer"
            ),
            desc = "switch source/header",
          },
          {
            "<leader>lL",
            "<cmd>LintCurrent<CR>",
            desc = "lint file",
          },
          { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<CR>", desc = "rename" },
          {
            "<leader>lS",
            run_buffer_command(
              "LspClangdShowSymbolInfo",
              "Clangd symbol info is only available in a C/C++ buffer"
            ),
            desc = "clangd symbol info",
          },
          {
            "<leader>lb",
            function()
              require("telescope.builtin").diagnostics({
                bufnr = 0,
                severity_limit = vim.diagnostic.severity.WARN,
              })
            end,
            desc = "buffer diagnostics",
          },
          { "<leader>lc", "<cmd>lua vim.lsp.buf.code_action()<CR>", desc = "code action" },
          { "<leader>ld", "<cmd>lua vim.lsp.buf.definition()<CR>", desc = "definition" },
          { "<leader>lf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "format buffer" },
          { "<leader>lg", "<cmd>LintToggle<CR>", desc = "toggle global linting" },
          { "<leader>lh", "<cmd>lua vim.lsp.buf.hover()<CR>", desc = "help" },
          { "<leader>li", "<cmd>Telescope lsp_implementations<CR>", desc = "implementations" },
          { "<leader>lk", "<cmd>lsp stop<CR>", desc = "stop lsp" },
          {
            "<leader>ll",
            function()
              vim.diagnostic.open_float({ severity = { min = vim.diagnostic.severity.WARN } })
            end,
            desc = "line diagnostics",
          },
          {
            "<leader>ln",
            function()
              vim.diagnostic.goto_next({ severity = { min = vim.diagnostic.severity.WARN } })
            end,
            desc = "next diagnostic",
          },
          {
            "<leader>lp",
            function()
              vim.diagnostic.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } })
            end,
            desc = "previous diagnostic",
          },
          { "<leader>lr", "<cmd>Telescope lsp_references<CR>", desc = "references" },
          { "<leader>ls", "<cmd>lsp restart<CR>", desc = "restart lsp" },
          { "<leader>lt", "<cmd>lsp enable<CR>", desc = "start lsp" },
          { "<leader>ly", function() require("util.diagnostics").copy_diagnostics_to_clipboard() end, desc = "copy diagnostics to clipboard" },
        },

        {
          "<leader>m",
          group = "markdown",
          { "<leader>ma", function() require("util.fold").toggle_all_folds() end, desc = "toggle all folds" },
          { "<leader>mf", "za", desc = "toggle fold under cursor" },
          { "<leader>mo", "<cmd>MarkdownPreviewToggle<CR>", desc = "open markdown preview" },
          { "<leader>ms", "<cmd>LecticSubmitSelection<CR>", desc = "submit selection with message" },
          { "<leader>mt", function() require("util.fold").toggle_folding_method() end, desc = "toggle folding method" },
          { "<leader>mu", function() require("util.url").open_url_under_cursor() end, desc = "open URL under cursor" },
        },

        {
          "<leader>o",
          group = "opencode",
          { "<leader>oO", opencode_call("open_input_new_session"), desc = "open input (new session)" },
          { "<leader>oR", opencode_call("rename_session"), desc = "rename session" },
          { "<leader>oT", opencode_call("timeline"), desc = "session timeline" },
          { "<leader>oV", opencode_call("configure_variant"), desc = "configure model variant" },
          { "<leader>o[", opencode_call("diff_prev"), desc = "previous diff" },
          { "<leader>o]", opencode_call("diff_next"), desc = "next diff" },
          { "<leader>oa", opencode_call("quick_chat"), desc = "ask" },
          { "<leader>oc", opencode_call("diff_close"), desc = "close diff view" },
          { "<leader>od", opencode_call("diff_open"), desc = "open diff view" },
          { "<leader>oh", opencode_call("select_history"), desc = "select from history" },
          { "<leader>oo", opencode_call("open_input"), desc = "open input window" },
          { "<leader>oq", opencode_call("close"), desc = "close UI windows" },
          {
            "<leader>or",
            group = "restore/revert",
            { "<leader>orA", opencode_call("diff_revert_all"), desc = "revert all changes" },
            { "<leader>orR", opencode_call("diff_restore_snapshot_all"), desc = "restore all snapshots" },
            { "<leader>orT", opencode_call("diff_revert_this"), desc = "revert this change" },
            { "<leader>ora", opencode_call("diff_revert_all_last_prompt"), desc = "revert all (last prompt)" },
            { "<leader>orr", opencode_call("diff_restore_snapshot_file"), desc = "restore file snapshot" },
            { "<leader>ort", opencode_call("diff_revert_this_last_prompt"), desc = "revert this (last prompt)" },
          },
          { "<leader>os", opencode_call("select_session"), desc = "select session" },
          { "<leader>ov", opencode_call("paste_image"), desc = "paste image from clipboard" },
          { "<leader>ox", opencode_call("swap_position"), desc = "swap window position" },
          { "<leader>oy", opencode_call("add_visual_selection"), desc = "add visual selection to context", mode = "v" },
          { "<leader>oz", opencode_call("toggle_zoom"), desc = "toggle zoom" },
        },

        {
          "<leader>s",
          group = "sessions",
          { "<leader>sd", "<cmd>SessionManager delete_session<CR>", desc = "delete" },
          { "<leader>sl", "<cmd>SessionManager load_session<CR>", desc = "load" },
          { "<leader>ss", "<cmd>SessionManager save_current_session<CR>", desc = "save" },
        },

        {
          "<leader>t",
          group = "typst",
          { "<leader>tf", "<cmd>TypstPreviewFollowCursorToggle<CR>", desc = "toggle cursor follow" },
          { "<leader>to", "<cmd>TypstPreview<CR>", desc = "preview" },
          { "<leader>tp", "<cmd>TypstPreviewToggle<CR>", desc = "toggle preview" },
          { "<leader>ts", "<cmd>TypstPreviewStop<CR>", desc = "stop preview" },
          { "<leader>tw", "<cmd>TypstWatch<CR>", desc = "watch" },
        },

        {
          "<leader>x",
          group = "latex",
          { "<leader>xb", "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", desc = "bib export" },
          { "<leader>xc", "<cmd>:VimtexClearCache All<CR>", desc = "clear vimtex" },
          { "<leader>xe", "<cmd>VimtexErrors<CR>", desc = "error report" },
          { "<leader>xi", "<cmd>VimtexTocOpen<CR>", desc = "index" },
          { "<leader>xk", "<cmd>VimtexClean<CR>", desc = "kill aux" },
          { "<leader>xm", "<plug>(vimtex-context-menu)", desc = "vimtex menu" },
          { "<leader>xv", "<cmd>VimtexView<CR>", desc = "view" },
          { "<leader>xw", "<cmd>VimtexCountWords!<CR>", desc = "word count" },
        },
      },
    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    wk.setup(opts.setup)
    wk.add(opts.spec)
  end,
}
