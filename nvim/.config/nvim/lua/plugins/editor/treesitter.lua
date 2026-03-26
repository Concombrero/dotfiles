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

local function sync_parsers()
  if vim.fn.executable("tree-sitter") ~= 1 then
    vim.notify_once("Skipping nvim-treesitter install/update: tree-sitter CLI not found", vim.log.levels.WARN)
    return
  end

  local treesitter = require("nvim-treesitter")
  treesitter.install(ensure_installed, { summary = true }):wait(300000)
  treesitter.update(nil, { summary = true }):wait(300000)
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
    branch = "main",
    lazy = false,
    build = sync_parsers,
    config = function()
      require("nvim-treesitter").setup()

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
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("ts_context_commentstring").setup({})
    end,
  },
}
