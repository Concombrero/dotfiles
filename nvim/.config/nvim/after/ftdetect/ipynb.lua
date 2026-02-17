-- Fallback filetype detection for Jupyter Notebook files
-- When jupytext.nvim is loaded, it intercepts BufReadCmd and sets the filetype
-- directly (to the notebook's language). This only fires if jupytext is absent.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.ipynb" },
  callback = function()
    vim.bo.filetype = "ipynb"
  end,
})
