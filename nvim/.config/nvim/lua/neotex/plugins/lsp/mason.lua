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
        "cmake",
        "pyright",
        "texlab",
        "tinymist",
        "lua_ls",
      },
      automatic_installation = true,
      automatic_enable = {
        exclude = { "julials" },
      },
    })

    vim.lsp.config("pyright", {
      capabilities = capabilities,
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

    vim.lsp.config("julials", {
      capabilities = capabilities,
      single_file_support = true,
      on_new_config = function(_, _)
      end,
      cmd = {
        resolve_julia_bin() or "julia",
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

    vim.lsp.enable("julials")

    -- MASON-TOOL-INSTALLER SETUP
    local ensure_installed_tools = {
      -- LSP servers
      "clangd",
      "cmake-language-server",
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
