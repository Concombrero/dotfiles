-- Main plugin file for Jupyter notebook functionality and styling
return {
  -- Jupytext for notebook conversion
  -- Must load eagerly: registers BufReadCmd autocmd to intercept .ipynb opens
  {
    "GCBallesteros/jupytext.nvim",
    version = "*",
    lazy = false,
    config = function()
      local jupytext_cmd = "jupytext"
      local mason_jupytext = vim.fn.stdpath("data") .. "/mason/bin/jupytext"
      if vim.fn.executable(jupytext_cmd) ~= 1 and vim.fn.executable(mason_jupytext) == 1 then
        jupytext_cmd = mason_jupytext
      end

      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
        command = jupytext_cmd,
      })
    end,
  },

  -- NotebookNavigator for cell navigation and execution
  {
    "GCBallesteros/NotebookNavigator.nvim",
    version = "*",
    lazy = true,
    ft = { "ipynb", "python", "markdown" },
    dependencies = {
      "echasnovski/mini.comment",
      "Vigemus/iron.nvim",
      "echasnovski/mini.hipatterns",
    },
    config = function()
      local nn = require("notebook-navigator")

      nn.setup({
        activate_mapping = "",
        cell_markers = {
          python = "```python",
          markdown = "```",
        },
        syntax_highlight = true,
        use_hipatterns = true,
        cell_highlight_group = "JupyterCellSeparator",
        repl_provider = "iron",
        mappings = {},
      })

      -- Load autocommands for FileType detection
      vim.defer_fn(function()
        local ok, autocommands = pcall(require, "neotex.plugins.text.jupyter.autocommands")
        if ok and type(autocommands) == "table" and autocommands.setup then
          autocommands.setup()
        end
      end, 50)

      -- Only load styling for open ipynb files
      vim.defer_fn(function()
        local any_ipynb = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local bufname = vim.api.nvim_buf_get_name(buf)
          if bufname:match("%.ipynb$") then
            any_ipynb = true
            break
          end
        end

        if any_ipynb then
          local ok, styling = pcall(require, "neotex.plugins.text.jupyter.styling")
          if ok and type(styling) == "table" and styling.setup then
            styling.setup()
          end
        end
      end, 100)
    end,
  },

  -- Iron.nvim for REPL integration
  {
    "Vigemus/iron.nvim",
    version = "*",
    lazy = true,
    main = "iron.core",
    ft = { "python", "julia", "r", "lua" },
    config = function()
      local iron = require("iron.core")

      local success, err = pcall(function()
        iron.setup({
          config = {
            scratch_repl = true,
            repl_definition = {
              python = {
                command = { "ipython" },
                block_dividers = { "# %%", "#%%" },
              },
            },
            repl_open_cmd = "vertical botright split",
            close_on_exit = true,
            highlight_last = false,
            should_map_plug = false,
          },
          keymaps = {},
        })
      end)

      if not success then
        vim.notify("Error setting up iron.nvim: " .. tostring(err), vim.log.levels.WARN)
      end
    end,
  },

  -- mini.hipatterns for cell styling (loaded as NotebookNavigator dependency)
  {
    "echasnovski/mini.hipatterns",
    version = "*",
    lazy = true,
  },
}
