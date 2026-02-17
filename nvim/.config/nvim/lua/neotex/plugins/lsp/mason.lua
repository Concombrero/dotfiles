return {
  "williamboman/mason.nvim",
  event = { "BufReadPre", "BufNewFile" },
  cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },

  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- Get default capabilities for LSP clients
    local capabilities = cmp_nvim_lsp.default_capabilities()

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

    -- LSP SERVER HANDLERS
    local handlers = {}

    -- PYRIGHT
    handlers["pyright"] = function()
      require("lspconfig").pyright.setup({
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
            },
          },
        },
      })
    end

    -- TEXLAB (LaTeX)
    handlers["texlab"] = function()
      require("lspconfig").texlab.setup({
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
    end

    -- TINYMIST (Typst)
    handlers["tinymist"] = function()
      require("lspconfig").tinymist.setup({
        capabilities = capabilities,
        single_file_support = true,
      })
    end

    -- LUA_LS
    handlers["lua_ls"] = function()
      require("lspconfig").lua_ls.setup({
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
    end

    -- MASON-LSPCONFIG SETUP
    mason_lspconfig.setup({
      ensure_installed = {
        "pyright",
        "texlab",
        "tinymist",
        "lua_ls",
      },
      automatic_installation = true,
      handlers = handlers,
    })

    -- MASON-TOOL-INSTALLER SETUP
    mason_tool_installer.setup({
      ensure_installed = {
        -- LSP servers
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
        "luacheck",
        "htmlhint",
        "cpplint",
        "tidy",

        -- Notebook tooling
        "jupytext",
      },
    })

    -- Disable stylua from being enabled as an LSP server (it's a formatter)
    pcall(vim.lsp.disable, "stylua")
  end,
}
