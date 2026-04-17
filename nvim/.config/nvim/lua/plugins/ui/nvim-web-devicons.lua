return {
  "nvim-tree/nvim-web-devicons",
  lazy = true,
  opts = {
    -- This nvim-web-devicons version does not ship a Typst icon.
    override_by_extension = {
      typ = {
        icon = "",
        color = "#0DBCC0",
        cterm_color = "37",
        name = "Typst",
      },
    },
  },
  config = function(_, opts)
    local devicons = require("nvim-web-devicons")
    devicons.setup(opts)
    devicons.set_icon_by_filetype({ typst = "typ" })
  end,
}
