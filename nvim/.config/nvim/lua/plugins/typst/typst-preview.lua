-- typst-preview.nvim: live preview for typst files in qutebrowser

return {
  {
    'chomosuke/typst-preview.nvim',
    lazy = true,
    ft = "typst",
    version = '1.*',
    config = function()
      local mason_tinymist = vim.fn.executable('tinymist') == 1 and 'tinymist' or nil

      require('typst-preview').setup({
        open_cmd = 'qutebrowser "%s" >/dev/null 2>&1',
        get_root = function(path_of_main_file)
          local root = vim.fs.find({ 'typst.toml', '.git' }, { path = path_of_main_file, upward = true })[1]
          if root then
            return vim.fs.dirname(root)
          end
          return vim.fn.getcwd()
        end,
        invert_colors = 'never',
        dependencies_bin = {
          ['tinymist'] = mason_tinymist,
          ['websocat'] = nil,
        },
        debug = false,
      })
    end,
  },
}
