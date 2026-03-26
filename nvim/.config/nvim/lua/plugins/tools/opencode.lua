return {
  "sudo-tee/opencode.nvim",
  lazy = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "folke/snacks.nvim", opts = { picker = {} } },
  },
  config = function()
    require("opencode").setup({
      default_global_keymaps = false,
    })

    -- Required for opts.events.reload
    vim.o.autoread = true
  end,
}
