-- Main plugin file for Jupyter notebook workflows
return {
  -- Jupytext for notebook conversion
  -- Must load eagerly: it defines BufReadCmd for *.ipynb.
  -- Lazy-loading on file open can miss the first read and show raw JSON.
  {
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    config = function()
      local function resolve_jupytext_command()
        local mason_dir = vim.fn.stdpath("data") .. "/mason/bin"
        for _, path_dir in ipairs(vim.split(vim.env.PATH or "", ":", { trimempty = true })) do
          if path_dir ~= mason_dir then
            local candidate = path_dir .. "/jupytext"
            if vim.fn.executable(candidate) == 1 then
              return candidate
            end
          end
        end

        local mason_jupytext = mason_dir .. "/jupytext"
        if vim.fn.executable(mason_jupytext) == 1 then
          return mason_jupytext
        end

        return nil
      end

      local function patch_jupytext_command(command)
        local ok, commands = pcall(require, "jupytext.commands")
        if not ok then
          return false
        end

        commands.run_jupytext_command = function(input_file, options)
          local cmd = vim.fn.shellescape(command) .. " " .. input_file .. " "
          for option_name, option_value in pairs(options) do
            if option_value ~= "" then
              cmd = cmd .. option_name .. "=" .. option_value .. " "
            else
              cmd = cmd .. option_name .. " "
            end
          end

          local output = vim.fn.system(cmd)

          if vim.v.shell_error ~= 0 then
            print(output)
            vim.api.nvim_err_writeln(cmd .. ": " .. vim.v.shell_error)
            return
          end
        end

        return true
      end

      local jupytext_cmd = resolve_jupytext_command()
      if not jupytext_cmd then
        vim.notify(
          "jupytext.nvim disabled: no working jupytext CLI found. Reinstall with :MasonUninstall jupytext and :MasonInstall jupytext.",
          vim.log.levels.WARN
        )
        return
      end

      patch_jupytext_command(jupytext_cmd)

      require("jupytext").setup({
        style = "markdown",
        output_extension = "md",
      })
    end,
  },

  -- Neopyter for live JupyterLab sync and execution from Neovim
  {
    "SUSTech-data/neopyter",
    cmd = { "Neopyter" },
    event = { "BufReadPost *.ju.*", "BufNewFile *.ju.*" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "AbaoFromCUG/websocket.nvim",
    },
    config = function()
      local function patch_neopyter_notebook_parser()
        local ok_notebook, notebook = pcall(require, "neopyter.jupyter.notebook")
        if not ok_notebook or type(notebook) ~= "table" or notebook._dotfiles_parser_patched then
          return
        end

        local original_get_parser = notebook.get_parser
        notebook.get_parser = function(self)
          local local_path = self.local_path or ""
          if local_path:match("%.ju%.py$") then
            return require("neopyter").parser.python
          end
          if local_path:match("%.ju%.[Rr]$") then
            return require("neopyter").parser.r
          end

          local parser = require("neopyter").parser.python
          if parser then
            return parser
          end

          if type(original_get_parser) == "function" then
            return original_get_parser(self)
          end

          return require("neopyter").parser.python
        end

        notebook._dotfiles_parser_patched = true
      end

      local function patch_neopyter_direct_disconnect()
        local ok_direct, direct_client = pcall(require, "neopyter.rpc.direct")
        if not ok_direct or type(direct_client) ~= "table" or direct_client._dotfiles_disconnect_patched then
          return
        end

        direct_client.disconnect = function(self)
          if self.single_connection then
            pcall(self.single_connection.close, self.single_connection)
            self.single_connection = nil
          end

          if self.server then
            pcall(self.server.close, self.server)
            self.server = nil
          end

          if type(self.request_pool) == "table" then
            for _, callback in pairs(self.request_pool) do
              if type(callback) == "function" then
                pcall(callback, false, "cancel")
              end
            end
          end
          self.request_pool = {}
        end

        direct_client._dotfiles_disconnect_patched = true
      end

      local ok, neopyter = pcall(require, "neopyter")
      if not ok then
        vim.notify("Failed to load neopyter", vim.log.levels.ERROR)
        return
      end

      local function apply_neopyter_cell_keymaps(buf)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        map("n", "<C-CR>", "<cmd>Neopyter execute notebook:run-cell<CR>", "run cell")
        map("n", "<C-Enter>", "<cmd>Neopyter execute notebook:run-cell<CR>", "run cell")
        map("n", "<S-CR>", "<cmd>Neopyter execute notebook:run-cell-and-select-next<CR>", "run cell and next")
        map("n", "<S-Enter>", "<cmd>Neopyter execute notebook:run-cell-and-select-next<CR>", "run cell and next")
        map("n", "<A-CR>", "<cmd>Neopyter execute notebook:run-cell-and-insert-below<CR>", "run cell and insert below")
        map("n", "<A-Enter>", "<cmd>Neopyter execute notebook:run-cell-and-insert-below<CR>", "run cell and insert below")
      end

      neopyter.setup({
        mode = "direct",
        remote_address = "127.0.0.1:9001",
        file_pattern = { "*.ju.*" },
        auto_attach = true,
        auto_connect = false,
        jupyter = {
          auto_activate_file = true,
          partial_sync = false,
          scroll = {
            enable = true,
            align = "center",
          },
        },
      })

      patch_neopyter_notebook_parser()
      patch_neopyter_direct_disconnect()

      local augroup = vim.api.nvim_create_augroup("dotfiles-neopyter-keymaps", { clear = true })
      vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        pattern = { "*.ju.*" },
        group = augroup,
        callback = function(ev)
          apply_neopyter_cell_keymaps(ev.buf)
        end,
      })
    end,
  },
}
