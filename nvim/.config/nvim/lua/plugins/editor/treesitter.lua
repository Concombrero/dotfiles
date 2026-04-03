local api = vim.api

local ensure_installed = {
  "lua",
  "vim",
  "vimdoc",
  "query",
  "markdown",
  "markdown_inline",
  "julia",
  "python",
  "bash",
  "bibtex",
  "nix",
  "json",
  "yaml",
  "toml",
  "gitignore",
  "c",
  "cpp",
  "cmake",
  "haskell",
  "typst",
}

local highlight_disabled = {
  css = true,
  cls = true,
  latex = true,
}

local indent_disabled = {
  latex = true,
}

local function enable_syntax_fallback(bufnr, filetype, language)
  local syntax = filetype ~= "" and filetype or language

  if syntax ~= "" then
    vim.bo[bufnr].syntax = syntax
  end
end

local function get_language(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local ok, language = pcall(vim.treesitter.language.get_lang, filetype)
  return filetype, (ok and language) or filetype
end

local function has_parser(bufnr, language)
  return pcall(vim.treesitter.get_parser, bufnr, language)
end

local function has_highlight_query(language)
  local ok, query = pcall(vim.treesitter.query.get, language, "highlights")
  return ok and query ~= nil
end

local function enable_buffer_features(bufnr)
  local filetype, language = get_language(bufnr)

  if filetype == "tex" or filetype == "latex" or language == "latex" then
    enable_syntax_fallback(bufnr, "tex", language)
  end

  local highlight_enabled = not highlight_disabled[filetype] and not highlight_disabled[language]

  if not highlight_enabled then
    enable_syntax_fallback(bufnr, filetype, language)
  elseif not has_parser(bufnr, language) or not has_highlight_query(language) then
    enable_syntax_fallback(bufnr, filetype, language)
  elseif not pcall(vim.treesitter.start, bufnr, language) then
    enable_syntax_fallback(bufnr, filetype, language)
  end

  if not has_parser(bufnr, language) then
    return
  end

  if not indent_disabled[filetype] and not indent_disabled[language] then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup()
      treesitter.install(ensure_installed)

      local group = api.nvim_create_augroup("DotfilesTreesitter", { clear = true })
      api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "*",
        callback = function(event)
          enable_buffer_features(event.buf)
        end,
      })
    end,
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    init = function()
      vim.g.loaded_ts_context_commentstring = 1
    end,
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
    end,
  },
}
