-- Filetype detection for Neopyter Jupyter text notebooks.
-- Ensure filetype is set before Neopyter BufWinEnter hooks run.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.ju.py" },
  callback = function()
    vim.bo.filetype = "python"
  end,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.ju.r", "*.ju.R" },
  callback = function()
    vim.bo.filetype = "r"
  end,
})
