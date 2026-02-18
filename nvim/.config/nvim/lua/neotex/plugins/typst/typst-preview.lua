-- typst-preview.nvim: live preview for typst files in qutebrowser
-- Uses --temp-basedir for an isolated instance and -C to preserve user config.
-- The preview qutebrowser is killed automatically when nvim exits.

return {
  {
    'chomosuke/typst-preview.nvim',
    lazy = true,
    ft = "typst",
    version = '1.*',
    config = function()
      local mason_tinymist = vim.fn.executable('tinymist') == 1 and 'tinymist' or nil
      local config_py = vim.fn.expand('~/.config/qutebrowser/config.py')

      -- --temp-basedir: spawns a separate qutebrowser instance with a
      --   temporary data directory (auto-cleaned on exit).
      -- -C: loads the user's config.py so themes and settings are preserved.
      -- 2>/dev/null: suppresses harmless startup warnings on stderr.
      local open_cmd = string.format(
        'qutebrowser --temp-basedir -C %s %%s 2>/dev/null',
        vim.fn.shellescape(config_py)
      )

      require('typst-preview').setup({
        open_cmd = open_cmd,
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

      -- Kill typst-preview qutebrowser instances when nvim exits.
      -- Only targets instances launched with --temp-basedir (preview instances),
      -- leaving any regular qutebrowser windows untouched.
      vim.api.nvim_create_autocmd('VimLeavePre', {
        callback = function()
          vim.fn.system({ 'pkill', '-f', 'qutebrowser.*--temp-basedir' })
        end,
      })

      -- keymaps
      vim.keymap.set('n', '<leader>tp', ':TypstPreviewToggle<CR>', { silent = true })
      vim.keymap.set('n', '<leader>to', ':TypstPreview<CR>', { silent = true })
      vim.keymap.set('n', '<leader>ts', ':TypstPreviewStop<CR>', { silent = true })
      vim.keymap.set('n', '<leader>tf', ':TypstPreviewFollowCursorToggle<CR>', { silent = true })
      vim.keymap.set('n', '<leader>tw', ':TypstWatch<CR>', { silent = true })
    end,
  },
}
