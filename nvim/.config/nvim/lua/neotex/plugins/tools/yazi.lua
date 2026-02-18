return {
  "mikavilpas/yazi.nvim",
  lazy = true,
  -- Keybinds are in which-key.lua
  opts = {
    open_for_directories = false,
    open_file_function = function(chosen_file)
      if vim.fn.isdirectory(chosen_file) == 1 then
        vim.cmd({ cmd = "cd", args = { chosen_file } })
        vim.notify('cwd changed to "' .. chosen_file .. '"')
        return
      end

      require("yazi.openers").open_file(chosen_file)
    end,
    keymaps = {
      show_help = '<f1>',
    },
  },
}
