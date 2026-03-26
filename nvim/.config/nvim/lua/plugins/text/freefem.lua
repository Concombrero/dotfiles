return {
  "holomorph/vim-freefem",
  lazy = true,
  ft = { "freefem" },
  init = function()
    vim.filetype.add({
      extension = {
        edp = "freefem",
        idp = "freefem",
      },
    })
  end,
}
