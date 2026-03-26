-----------------------------------------------------------
-- Nvim-lint Integration
-- 
-- This module configures nvim-lint for code linting:
-- - Provides filetype-specific linters
-- - Configures key mappings for linting
-- - Supports lint-on-save functionality
-- - Integrates with quickfix and diagnostics
--
-- Nvim-lint is an asynchronous linter plugin for Neovim that works
-- with a variety of linters to maintain code quality.
-----------------------------------------------------------

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Helper function to check if a command is available
    local function is_executable(command)
      return vim.fn.executable(command) == 1
    end

    local python_root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".git",
    }

    local function get_python_project_root()
      local buffer_path = vim.api.nvim_buf_get_name(0)
      if buffer_path == "" then
        return vim.fn.getcwd()
      end

      return vim.fs.root(buffer_path, python_root_markers) or vim.fn.getcwd()
    end

    local function has_project_pylint_config(root_dir)
      if not root_dir or root_dir == "" then
        return false
      end

      for _, config_name in ipairs({ ".pylintrc", "pylintrc", "pyproject.toml", "setup.cfg", "tox.ini" }) do
        if vim.fn.filereadable(vim.fs.joinpath(root_dir, config_name)) == 1 then
          return true
        end
      end

      return false
    end

    local function find_home_pylintrc()
      for _, pylintrc_path in ipairs({
        vim.fn.expand("$HOME/.pylintrc"),
        vim.fn.expand("$HOME/.config/nvim/.pylintrc"),
      }) do
        if vim.fn.filereadable(pylintrc_path) == 1 then
          return pylintrc_path
        end
      end

      return nil
    end

    -- Initialize linters by filetype
    lint.linters_by_ft = {}

    -- Only configure linters that are actually available on the system
    -- Web development
    if is_executable("eslint") then
      lint.linters_by_ft.javascript = { "eslint" }
      lint.linters_by_ft.typescript = { "eslint" }
      lint.linters_by_ft.javascriptreact = { "eslint" }
      lint.linters_by_ft.typescriptreact = { "eslint" }
      lint.linters_by_ft.vue = { "eslint" }
    elseif is_executable("eslint_d") then
      lint.linters_by_ft.javascript = { "eslint_d" }
      lint.linters_by_ft.typescript = { "eslint_d" }
      lint.linters_by_ft.javascriptreact = { "eslint_d" }
      lint.linters_by_ft.typescriptreact = { "eslint_d" }
      lint.linters_by_ft.vue = { "eslint_d" }
    end

    if is_executable("stylelint") then
      lint.linters_by_ft.css = { "stylelint" }
    end

    if is_executable("tidy") then
      lint.linters_by_ft.html = { "tidy" }
    elseif is_executable("htmlhint") then
      lint.linters_by_ft.html = { "htmlhint" }
    end

    if is_executable("jsonlint") then
      lint.linters_by_ft.json = { "jsonlint" }
    end

    if is_executable("yamllint") then
      lint.linters_by_ft.yaml = { "yamllint" }
    end

    -- Python
    if is_executable("pylint") then
      lint.linters_by_ft.python = { "pylint" }
    end

    -- Lua
    if is_executable("luacheck") then
      lint.linters_by_ft.lua = { "luacheck" }
    elseif is_executable("selene") then
      lint.linters_by_ft.lua = { "selene" }
    end

    -- Shell scripting
    if is_executable("shellcheck") then
      lint.linters_by_ft.sh = { "shellcheck" }
      lint.linters_by_ft.bash = { "shellcheck" }
    end

    -- Markdown
    if is_executable("markdownlint") then
      lint.linters_by_ft.markdown = { "markdownlint" }
    end

    -- LaTeX - Disabled grammar checking for LaTeX
    -- if is_executable("chktex") then
    --   lint.linters_by_ft.tex = { "chktex" }
    -- end

    -- C/C++
    if is_executable("cppcheck") then
      lint.linters_by_ft.c = { "cppcheck" }
      lint.linters_by_ft.cpp = { "cppcheck" }
    elseif is_executable("cpplint") then
      lint.linters_by_ft.c = { "cpplint" }
      lint.linters_by_ft.cpp = { "cpplint" }
    end

    -- Configure linter options only for available linters
    if is_executable("flake8") then
      lint.linters.flake8 = lint.linters.flake8 or {}
      lint.linters.flake8.args = {
        "--max-line-length=88",
        "--extend-ignore=E203",
      }
    end

    if is_executable("pylint") then
      local default_pylint = lint.linters.pylint

      lint.linters.pylint = function()
        local root_dir = get_python_project_root()
        local pylint = vim.deepcopy(default_pylint)
        local custom_args = {
          "--disable=C0103,C0111,C0114,C0115,C0116,C0301,C0302,W0105,R0903,R0913,R0914,E0401,E0611,W0611,W0612",
          "--max-line-length=88",
        }

        if not has_project_pylint_config(root_dir) then
          local home_pylintrc = find_home_pylintrc()
          if home_pylintrc then
            table.insert(custom_args, "--rcfile=" .. home_pylintrc)
          end
        end

        local default_args = vim.deepcopy(pylint.args or {})
        pylint.args = vim.list_extend(custom_args, default_args)
        pylint.cwd = root_dir

        return pylint
      end
    end

    if is_executable("luacheck") then
      lint.linters.luacheck = lint.linters.luacheck or {}
      lint.linters.luacheck.args = {
        "--globals=vim",
        "--no-max-line-length",
      }
    end
    
    -- Helper function to run linters
    _G.lint_try_lint = function()
      local filetype = vim.bo.filetype

      if filetype == "python" then
        lint.try_lint("pylint", { cwd = get_python_project_root() })
        return
      end

      -- Try to detect if we're in a Git repository with ESLint configuration
      local is_git_repo = vim.fn.system("git rev-parse --is-inside-work-tree 2>/dev/null"):match("true")

      if is_git_repo and vim.fn.glob(".eslintrc*") ~= "" then
        -- Use ESLint for all JavaScript-like files in this repository
        if filetype:match("javascript") or filetype:match("typescript") then
          if is_executable("eslint") then
            lint.try_lint("eslint")
            return
          end

          if is_executable("eslint_d") then
            lint.try_lint("eslint_d")
            return
          end

          return
        end
      end

      -- Otherwise, use the regular linting logic
      lint.try_lint()
    end

    -- Set up autocommands for running linters
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
      callback = function()
        -- Get a list of filetypes that should be automatically linted
        local auto_lint_filetypes = {
          "c",
          "cpp",
          "python",
          "lua",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          -- "tex" -- Disabled for LaTeX files
        }

        -- Check if auto-linting is disabled
        if vim.g.disable_autolint == true then
          return
        end

        -- Check if auto-linting is disabled for this buffer
        if vim.b.disable_autolint == true then
          return
        end

        -- Check if the current buffer's filetype should be auto-linted
        local filetype = vim.bo.filetype
        if vim.tbl_contains(auto_lint_filetypes, filetype) then
          _G.lint_try_lint()
        end
      end,
    })
    
    -- Add user commands for controlling linting
    vim.api.nvim_create_user_command("LintToggle", function(args)
      local is_enabled = false
      if args.args == "buffer" then
        -- Toggle for current buffer
        if vim.b.disable_autolint == true then
          vim.b.disable_autolint = false
          is_enabled = true
        else
          vim.b.disable_autolint = true
          is_enabled = false
        end

        vim.notify(
          string.format("Auto-linting %s for this buffer", is_enabled and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      else
        -- Toggle globally
        if vim.g.disable_autolint == true then
          vim.g.disable_autolint = false
          is_enabled = true
        else
          vim.g.disable_autolint = true
          is_enabled = false
        end

        vim.notify(
          string.format("Auto-linting %s globally", is_enabled and "enabled" or "disabled"),
          vim.log.levels.INFO
        )
      end
    end, {
      nargs = "?",
      complete = function()
        return { "buffer" }
      end,
      desc = "Toggle auto-linting",
    })
    
    -- Note: vim.diagnostic.config() is set in mason.lua
  end,
}
