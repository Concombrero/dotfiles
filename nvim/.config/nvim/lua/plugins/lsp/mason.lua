return {
  "williamboman/mason.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
  dependencies = {
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local julia_root_markers = { "Project.toml", "JuliaProject.toml" }

    local function resolve_julia_bin()
      local julia_bin = vim.fn.exepath("julia")
      if julia_bin ~= "" then
        return julia_bin
      end

      local juliaup_bin = vim.fn.expand("~/.juliaup/bin/julia")
      if vim.fn.executable(juliaup_bin) == 1 then
        return juliaup_bin
      end

      return nil
    end

    local function resolve_julia_lsp_env()
      return vim.fn.expand("~/.julia/environments/nvim-lspconfig")
    end

    local function has_julia_lsp_env(env_path)
      return vim.fn.filereadable(vim.fs.joinpath(env_path, "Project.toml")) == 1
    end

    local function get_venv_python(venv_path)
      if not venv_path or venv_path == "" then
        return nil
      end

      local candidates = {
        vim.fs.joinpath(venv_path, "bin", "python"),
        vim.fs.joinpath(venv_path, "bin", "python3"),
        vim.fs.joinpath(venv_path, "Scripts", "python.exe"),
      }

      for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate) == 1 then
          return candidate
        end
      end

      return nil
    end

    local python_root_markers = {
      "pyrightconfig.json",
      "pyproject.toml",
      "setup.py",
      "setup.cfg",
      "requirements.txt",
      "Pipfile",
      ".venv",
      "venv",
      "env",
      ".git",
    }

    local function resolve_python_path(root_dir)
      if root_dir and root_dir ~= "" then
        for _, venv_name in ipairs({ ".venv", "venv", "env" }) do
          local python_path = get_venv_python(vim.fs.joinpath(root_dir, venv_name))
          if python_path then
            return python_path
          end
        end
      end

      local active_python = get_venv_python(vim.env.VIRTUAL_ENV)
        or get_venv_python(vim.env.CONDA_PREFIX)
      if active_python then
        return active_python
      end

      local python3 = vim.fn.exepath("python3")
      if python3 ~= "" then
        return python3
      end

      local python = vim.fn.exepath("python")
      if python ~= "" then
        return python
      end

      return "python"
    end

    local capabilities = cmp_nvim_lsp.default_capabilities()
    local clangd_capabilities = vim.tbl_deep_extend("force", {}, capabilities, {
      offsetEncoding = { "utf-8", "utf-16" },
      textDocument = {
        completion = {
          editsNearCursor = true,
        },
      },
    })

    -- DIAGNOSTICS CONFIGURATION
    local signs = { Error = "󰅜", Warn = "󰀦", Hint = "󰌵", Info = "󰋽" }
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = signs.Error,
          [vim.diagnostic.severity.WARN] = signs.Warn,
          [vim.diagnostic.severity.HINT] = signs.Hint,
          [vim.diagnostic.severity.INFO] = signs.Info,
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- MASON SETUP
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- MASON-LSPCONFIG SETUP
    mason_lspconfig.setup({
      ensure_installed = {
        "clangd",
        -- Disabled for now: Mason's cmake-language-server install requires
        -- Python < 3.14, so this retries and fails on Python 3.14-only systems.
        -- "cmake",
        "pyright",
        "texlab",
        "tinymist",
        "lua_ls",
      },
      automatic_installation = {
        exclude = { "cmake" },
      },
      automatic_enable = {
        exclude = { "julials" },
      },
    })

    vim.lsp.config("pyright", {
      capabilities = capabilities,
      root_markers = python_root_markers,
      before_init = function(_, config)
        config.settings = config.settings or {}
        config.settings.python = config.settings.python or {}
        config.settings.python.pythonPath = resolve_python_path(config.root_dir)
      end,
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "basic",
          },
        },
      },
    })

    vim.lsp.config("clangd", {
      capabilities = clangd_capabilities,
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
      },
    })

    vim.lsp.config("cmake", {
      capabilities = capabilities,
    })

    vim.lsp.config("texlab", {
      capabilities = capabilities,
      settings = {
        texlab = {
          build = {
            onSave = true,
          },
          chktex = {
            onEdit = false,
            onOpenAndSave = false,
          },
          diagnosticsDelay = 300,
        },
      },
    })

    vim.lsp.config("tinymist", {
      capabilities = capabilities,
      single_file_support = true,
    })

    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
        },
      },
    })

    local julia_bin = resolve_julia_bin()
    local julia_lsp_env = resolve_julia_lsp_env()

    if julia_bin then
      vim.lsp.config("julials", {
        capabilities = capabilities,
        single_file_support = true,
        on_new_config = function(_, _)
        end,
        cmd = {
          julia_bin,
          "--startup-file=no",
          "--history-file=no",
          "-e",
          [[
            ls_install_path = joinpath(
              get(DEPOT_PATH, 1, joinpath(homedir(), ".julia")),
              "environments",
              "nvim-lspconfig"
            )
            pushfirst!(LOAD_PATH, ls_install_path)
            using LanguageServer, SymbolServer, StaticLint
            popfirst!(LOAD_PATH)
            depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
            project_path = let
              dirname(something(
              Base.load_path_expand((
                p = get(ENV, "JULIA_PROJECT", nothing);
                p === nothing ? nothing : isempty(p) ? nothing : p
              )),
              Base.current_project(),
              get(Base.load_path(), 1, nothing),
              Base.load_path_expand("@v#.#")
              ))
            end

            @info "Running language server" VERSION pwd() project_path depot_path
            server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
            server.runlinter = true
            run(server)
          ]],
        },
        filetypes = { "julia" },
        root_markers = julia_root_markers,
      })

      if has_julia_lsp_env(julia_lsp_env) then
        vim.lsp.enable("julials")
      else
        vim.schedule(function()
          vim.notify_once(
            "Julia LSP disabled: bootstrap ~/.julia/environments/nvim-lspconfig first.",
            vim.log.levels.WARN
          )
        end)
      end
    else
      vim.schedule(function()
        vim.notify_once("Julia LSP disabled: `julia` is not on PATH.", vim.log.levels.WARN)
      end)
    end

    -- MASON-TOOL-INSTALLER SETUP
    local ensure_installed_tools = {
      -- LSP servers
      "clangd",
      -- Disabled for now: Mason's cmake-language-server install requires
      -- Python < 3.14, so this retries and fails on Python 3.14-only systems.
      -- "cmake-language-server",
      "pyright",
      "texlab",
      "tinymist",
      "lua-language-server",

      -- Formatters
      "stylua",
      "isort",
      "black",
      "prettier",
      "clang-format",
      "shfmt",
      "latexindent",

      -- Linters / diagnostics tools
      "pylint",
      "eslint_d",
      "stylelint",
      "jsonlint",
      "yamllint",
      "markdownlint",
      "shellcheck",
      "selene",
      "htmlhint",
      "cpplint",

      -- Notebook tooling
      "jupytext",
    }

    -- luacheck is installed via luarocks in Mason.
    if vim.fn.executable("luarocks") == 1 then
      table.insert(ensure_installed_tools, "luacheck")
    end

    mason_tool_installer.setup({
      ensure_installed = ensure_installed_tools,
    })

    -- Disable stylua from being enabled as an LSP server (it's a formatter)
    pcall(vim.lsp.disable, "stylua")
  end,
}
