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
      local config_dir = vim.fn.resolve(vim.fn.stdpath('config'))
      local repo_root = vim.fn.fnamemodify(config_dir, ':h:h:h')
      local wrapper_candidates = {
        vim.fn.expand('~/.local/bin/qutebrowser-typst-preview'),
        repo_root .. '/scripts/.local/bin/qutebrowser-typst-preview',
        'qutebrowser-typst-preview',
      }

      local wrapper
      for _, candidate in ipairs(wrapper_candidates) do
        if vim.fn.executable(candidate) == 1 then
          wrapper = candidate
          break
        end
      end

      local open_cmd

      if wrapper then
        open_cmd = string.format('%s "%%s" >/dev/null 2>&1', vim.fn.shellescape(wrapper))
      else
        local config_py = vim.fn.expand('~/.config/qutebrowser/config.py')
        open_cmd = string.format(
          'qutebrowser --temp-basedir -C %s "%%s" >/dev/null 2>&1',
          vim.fn.shellescape(config_py)
        )
      end

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
