--[[ WHICH-KEY MAP REFERENCE (source-aligned)
-----------------------------------------------------------
This reference mirrors mappings defined in the following files:
- this file: `lua/neotex/plugins/editor/which-key.lua` (`opts.defaults`)
- `lua/neotex/plugins/editor/formatting.lua` (`<leader>mp`)
- `lua/neotex/plugins/text/markdown-preview.lua` (`<leader>mo`)
- `lua/neotex/plugins/tools/yanky.lua` (`<leader>fy`, `<leader>yh`)
- `lua/neotex/plugins/tools/opencode.lua` (`<leader>o` prefix; sub-keys from plugin defaults)

TOP-LEVEL (<leader>)                            | LABEL
-----------------------------------------------------------
<leader>b                                       | build
<leader>d                                       | delete buffer
<leader>e                                       | EXPLORER
<leader>g                                       | lazygit
<leader>h                                       | create split
<leader>i                                       | index
<leader>q                                       | quit
<leader>u                                       | undo
<leader>v                                       | view
<leader>w                                       | write
<leader>y                                       | yank history

ACTIONS (<leader>a)                             | LABEL
-----------------------------------------------------------
<leader>ab                                      | bib export
<leader>ac                                      | clear vimtex
<leader>ae                                      | error report
<leader>af                                      | format
<leader>ak                                      | kill aux
<leader>at                                      | tex format
<leader>av                                      | vimtex menu
<leader>aw                                      | word count

COPILOT (<leader>c)                             | LABEL
-----------------------------------------------------------
<leader>ce                                      | copilot enable
<leader>cd                                      | copilot disable
<leader>cs                                      | copilot status
<leader>cp                                      | copilot panel
<leader>cn                                      | copilot next
<leader>cb                                      | copilot prev
<leader>cl                                      | copilot line
<leader>cw                                      | copilot word
<leader>cx                                      | copilot dismiss

EXPLORER (<leader>e)                            | LABEL
-----------------------------------------------------------
<leader>e                                       | yazi here

FIND (<leader>f)                                | LABEL
-----------------------------------------------------------
<leader>fa                                      | all files
<leader>fb                                      | buffers
<leader>fc                                      | citations
<leader>ff                                      | files
<leader>fg                                      | git history
<leader>fh                                      | help
<leader>fk                                      | keymaps
<leader>fl                                      | last search
<leader>fp                                      | project grep
<leader>fq                                      | quickfix
<leader>fr                                      | registers
<leader>fs                                      | string
<leader>ft                                      | todos
<leader>fw                                      | word
<leader>fy                                      | yanks (from yanky.lua)

JUPYTER (<leader>j)                             | LABEL
-----------------------------------------------------------
<leader>ja                                      | run all cells
<leader>jb                                      | run selected and below
<leader>jc                                      | connect Neopyter
<leader>je                                      | run current cell
<leader>ji                                      | Neopyter status
<leader>jI                                      | convert ipynb to ju.py
<leader>jn                                      | run and select next
<leader>jo                                      | open notebook in browser
<leader>jr                                      | restart kernel
<leader>jR                                      | restart and run all
<leader>js                                      | sync current notebook tab
<leader>jS                                      | save ipynb with outputs
<leader>jv                                      | bootstrap .venv (py3.12)

LSP & LINT (<leader>l)                          | LABEL
-----------------------------------------------------------
<leader>lB                                      | toggle buffer linting
<leader>lD                                      | declaration
<leader>lL                                      | lint file
<leader>lR                                      | rename
<leader>lb                                      | buffer diagnostics
<leader>lc                                      | code action
<leader>ld                                      | definition
<leader>lf                                      | format buffer
<leader>lg                                      | toggle global linting
<leader>lh                                      | help
<leader>li                                      | implementations
<leader>lk                                      | kill lsp
<leader>ll                                      | line diagnostics
<leader>ln                                      | next diagnostic
<leader>lp                                      | previous diagnostic
<leader>lr                                      | references
<leader>ls                                      | restart lsp
<leader>lt                                      | start lsp
<leader>ly                                      | copy diagnostics to clipboard

MARKDOWN (<leader>m)                            | LABEL
-----------------------------------------------------------
<leader>ma                                      | toggle all folds
<leader>mf                                      | toggle fold under cursor
<leader>mo                                      | open markdown preview (from markdown-preview.lua)
<leader>mp                                      | Format code (from formatting.lua)
<leader>ms                                      | submit selection with message
<leader>mt                                      | toggle folding method
<leader>mu                                      | open URL under cursor

SESSIONS (<leader>s)                            | LABEL
-----------------------------------------------------------
<leader>sd                                      | delete
<leader>sl                                      | load
<leader>ss                                      | save

TYPST (<leader>t)                               | LABEL
-----------------------------------------------------------
<leader>tb                                      | build (update | make)
<leader>tf                                      | toggle cursor follow
<leader>to                                      | preview
<leader>tp                                      | toggle preview
<leader>ts                                      | stop preview
<leader>tw                                      | watch

YANK (<leader>y)                                | LABEL
-----------------------------------------------------------
<leader>y                                       | yank history
<leader>yh                                      | history (from yanky.lua)

OPENCODE (<leader>o)
-----------------------------------------------------------
`<leader>o` is a prefix owned by opencode.nvim. Sub-key bindings are provided
by the plugin defaults (configured via `keymap_prefix = "<leader>o"`).

RESERVED GROUPS
-----------------------------------------------------------
<leader>L                                       | LIST (group name only in this file)
]]

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
        group = "+", -- The symbol prepended to a group
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
      b = { "<cmd>VimtexCompile<CR>", "build" },
      h = { "<cmd>vert sb<CR>", "create split" },
      d = { "<cmd>update! | lua Snacks.bufdelete()<CR>", "delete buffer" },
      e = { "<cmd>Yazi<CR>", "yazi here" },
      g = { "<cmd>lua vim.schedule(function() require('neotex.plugins.tools.snacks.utils').safe_lazygit() end)<cr>", "lazygit" },
      i = { "<cmd>VimtexTocOpen<CR>", "index" },
      q = { "<cmd>wa! | qa!<CR>", "quit" },
      u = { "<cmd>Telescope undo<CR>", "undo" },
      v = { "<cmd>VimtexView<CR>", "view" },
      w = { "<cmd>wa!<CR>", "write" },
      a = {
        name = "ACTIONS",
        b = { "<cmd>terminal bibexport -o %:p:r.bib %:p:r.aux<CR>", "bib export" },
        c = { "<cmd>:VimtexClearCache All<CR>", "clear vimtex" },
        e = { "<cmd>VimtexErrors<CR>", "error report" },
        f = { "<cmd>lua vim.lsp.buf.format()<CR>", "format" },
        k = { "<cmd>VimtexClean<CR>", "kill aux" },
        t = { "<cmd>terminal latexindent -w %:p:r.tex<CR>", "tex format" },
        v = { "<plug>(vimtex-context-menu)", "vimtex menu" },
        w = { "<cmd>VimtexCountWords!<CR>", "word count" },
      },
        f = {
        name = "FIND",
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
        s = { "<cmd>Telescope grep_string<CR>", "string" },
        w = { "<cmd>lua SearchWordUnderCursor()<CR>", "word" },
      },
      g = { "<cmd>lua vim.schedule(function() require('neotex.plugins.tools.snacks.utils').safe_lazygit() end)<cr>", "lazygit" },
      c = {
        name = "COPILOT",
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
      o = { name = "OPENCODE" },
      -- LIST MAPPINGS
      j = {
        name = "JUPYTER",
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
        name = "LIST",
      },
      l = {
        name = "LSP & LINT",
        -- LSP operations
        b = { "<cmd>Telescope diagnostics bufnr=0<CR>", "buffer diagnostics" },
        c = { "<cmd>lua vim.lsp.buf.code_action()<CR>", "code action" },
        d = { "<cmd>lua vim.lsp.buf.definition()<CR>", "definition" },
        D = { "<cmd>lua vim.lsp.buf.declaration()<CR>", "declaration" },
        f = { function() require("conform").format({ async = true, lsp_fallback = true }) end, "format buffer" },
        h = { "<cmd>lua vim.lsp.buf.hover()<CR>", "help" },
        i = { "<cmd>Telescope lsp_implementations<CR>", "implementations" },
        k = { "<cmd>LspStop<CR>", "kill lsp" },
        l = { "<cmd>lua vim.diagnostic.open_float()<CR>", "line diagnostics" },
        n = { "<cmd>lua vim.diagnostic.goto_next()<CR>", "next diagnostic" },
        p = { "<cmd>lua vim.diagnostic.goto_prev()<CR>", "previous diagnostic" },
        r = { "<cmd>Telescope lsp_references<CR>", "references" },
        s = { "<cmd>LspRestart<CR>", "restart lsp" },
        t = { "<cmd>LspStart<CR>", "start lsp" },
        y = { "<cmd>lua CopyDiagnosticsToClipboard()<CR>", "copy diagnostics to clipboard" },
        R = { "<cmd>lua vim.lsp.buf.rename()<CR>", "rename" },
        -- T = { "<cmd>Telescope lsp_type_definitions<CR>", "type definition" },

        -- Linting operations
        L = { function() require("lint").try_lint() end, "lint file" },
        g = { "<cmd>LintToggle<CR>", "toggle global linting" },
        B = { "<cmd>LintToggle buffer<CR>", "toggle buffer linting" },
      },
      -- MARKDOWN MAPPINGS
      m = {
        name = "MARKDOWN",
        s = { "<cmd>LecticSubmitSelection<CR>", "submit selection with message" },

        -- MARKDOWN/PREVIEW
        -- o = markdown preview (keymap defined in markdown-preview.lua via lazy keys)
        u = { "<cmd>lua OpenUrlUnderCursor()<CR>", "open URL under cursor" },

        -- FOLDING
        a = { "<cmd>lua ToggleAllFolds()<CR>", "toggle all folds" },
        f = { "za", "toggle fold under cursor" },
        t = { "<cmd>lua ToggleFoldingMethod()<CR>", "toggle folding method" },
      },
      s = {
        name = "SESSIONS",
        s = { "<cmd>SessionManager save_current_session<CR>", "save" },
        d = { "<cmd>SessionManager delete_session<CR>", "delete" },
        l = { "<cmd>SessionManager load_session<CR>", "load" },
      },



      t = {
        name = "TYPST",
        b = { "<cmd>update | make<CR>", "build" },
        o = { "<cmd>TypstPreview<CR>", "preview" },
        p = { "<cmd>TypstPreviewToggle<CR>", "toggle preview" },
        s = { "<cmd>TypstPreviewStop<CR>", "stop preview" },
        f = { "<cmd>TypstPreviewFollowCursorToggle<CR>", "toggle cursor follow" },
        w = { "<cmd>TypstWatch<CR>", "watch" },
      },
      y = { function() require("telescope").extensions.yank_history.yank_history() end, "yank history" },

    },
  },
  config = function(_, opts)
    local wk = require("which-key")

    -- Set up the base configuration
    wk.setup(opts.setup)

    -- Define our icon map with explicit spacing to position them right after the separator arrow
    local icons = {
      -- Top level command icons
      b = "󰖷 ", -- build
      d = "󰩺 ", -- delete buffer
      e = "󰙅 ", -- explorer
      g = "󰊢 ", -- lazygit
      h = "󰁪 ", -- create split
      i = "󰋽 ", -- index
      q = "󰗼 ", -- quit
      u = "󰕌 ", -- undo
      v = "󰛓 ", -- view
      w = "󰆓 ", -- write

      -- Group icons
      ["ACTIONS"] = "󰌵 ",
      ["COPILOT"] = "󰚩 ",
      ["FIND"] = "󰍉 ",
      ["JUPYTER"] = "󰌠 ",
      ["LIST"] = "󰔱 ",
      ["LSP & LINT"] = "󰒕 ",
      ["MARKDOWN"] = "󱀈 ",
      ["OPENCODE"] = " ",
      ["SESSIONS"] = "󰆔 ",
      ["TYPST"] = "󰈭 ",
      ["TEXT"] = "󰊪 ",
      ["YANK"] = "󰆏 ",
    }

    -- Monkey patch the which-key view module to insert icons at exactly the right place
    -- We replace the separator symbol with our custom icon
    local which_key_separator = opts.setup.icons.separator

    -- Store the original item function from the view module
    local view_ok, view = pcall(require, "which-key.view")
    if not view_ok then
      vim.notify("Failed to load which-key view module", vim.log.levels.WARN)
      wk.register(opts.defaults)
      return
    end

    -- Save the original function
    local orig_item = view.item

    -- Replace with our custom version that adds icons
    view.item = function(key, item, label)
      -- Get the standard formatting
      local columns = orig_item(key, item, label)

      -- Check if we need to add an icon after the separator
      local icon_to_add = nil

      -- Case 1: Single-character top-level commands (like b, c, d, etc.)
      if type(key) == "string" and #key == 1 and icons[key] then
        icon_to_add = icons[key]
      end

      -- Case 2: Group items with name property
      if type(item) == "table" and item.name and icons[item.name] then
        icon_to_add = icons[item.name]
      end

      -- Case 3: Default icons for common commands based on description
      if not icon_to_add and type(item) == "table" and #item >= 2 and type(item[2]) == "string" then
        local desc = item[2]:lower()

        -- Map common descriptions to icons if not already assigned
        if desc == "build" then
          icon_to_add = "󰖷 "
        elseif desc == "create split" then
          icon_to_add = "󰁪 "
        elseif desc == "delete buffer" then
          icon_to_add = "󰩺 "
        elseif desc == "explorer" then
          icon_to_add = "󰙅 "
        elseif desc == "lazygit" then
          icon_to_add = "󰊢 "
        elseif desc == "index" then
          icon_to_add = "󰋽 "
        elseif desc == "quit" then
          icon_to_add = "󰗼 "
        elseif desc == "undo" then
          icon_to_add = "󰕌 "
        elseif desc == "view" then
          icon_to_add = "󰛓 "
        elseif desc == "write" then
          icon_to_add = "󰆓 "
        elseif desc == "write all" then
          icon_to_add = "󰆓 "
        elseif desc:match("format") then
          icon_to_add = "󰉣 "
        elseif desc:match("search") or desc:match("find") then
          icon_to_add = "󰍉 "
        elseif desc:match("file") then
          icon_to_add = "󰈙 "
        elseif desc:match("todo") or desc:match("todos") then
          icon_to_add = "󰄬 "
        end
      end

      -- If we have an icon to add, add it after the separator
      if icon_to_add then
        for i, col in ipairs(columns) do
          if col == which_key_separator then
            columns[i] = which_key_separator .. icon_to_add
            break
          end
        end
      end

      return columns
    end

    -- Register the defaults
    wk.register(opts.defaults)
  end,
}
