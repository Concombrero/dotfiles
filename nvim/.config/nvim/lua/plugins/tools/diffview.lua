return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    view = {
      merge_tool = {
        disable_diagnostics = true,
        winbar_info = true,
      },
    },
  },
}
