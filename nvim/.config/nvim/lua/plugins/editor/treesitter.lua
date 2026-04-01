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
  "norg",
}

local highlight_disabled = {
  css = true,
  cls = true,
  latex = true,
  typst = true,
}

local indent_disabled = {
  latex = true,
}

local function get_language(bufnr)
  local filetype = vim.bo[bufnr].filetype
  local ok, language = pcall(vim.treesitter.language.get_lang, filetype)
  return filetype, (ok and language) or filetype
end

local function has_parser(bufnr, language)
  return pcall(vim.treesitter.get_parser, bufnr, language)
end

local function enable_buffer_features(bufnr)
  local filetype, language = get_language(bufnr)

  if filetype == "tex" or filetype == "latex" or language == "latex" then
    vim.bo[bufnr].syntax = "tex"
  end

  if not has_parser(bufnr, language) then
    return
  end

  if not highlight_disabled[filetype] and not highlight_disabled[language] then
    local started = pcall(vim.treesitter.start, bufnr, language)
    if started and (filetype == "python" or language == "python") then
      vim.bo[bufnr].syntax = "python"
    end
  end

  if not indent_disabled[filetype] and not indent_disabled[language] then
    vim.bo[bufnr].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = ensure_installed,
      })

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
