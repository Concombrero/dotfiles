return {
  "sudo-tee/opencode.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "folke/snacks.nvim", opts = { picker = {} } },
  },
  config = function()
    require("opencode").setup({
      -- Use built-in keymaps under <leader>o
      keymap_prefix = "<leader>o",
    })

    -- Required for opts.events.reload
    vim.o.autoread = true
  end,
}
