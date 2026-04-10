local function get_zen_width()
  return math.max(1, math.min(120, vim.o.columns - 8))
end

local function redraw_tabline()
  local function redraw()
    pcall(vim.cmd.redrawtabline)
  end

  vim.schedule(redraw)
  vim.defer_fn(redraw, 20)
end

local function bufferline_is_visible()
  return package.loaded["bufferline"] ~= nil and vim.o.showtabline > 0
end

local function apply_bufferline_layout(win)
  if not bufferline_is_visible() then
    return
  end

  local view = require("zen-mode.view")

  if not (win and vim.api.nvim_win_is_valid(win)) then
    return
  end

  if not (view.bg_win and vim.api.nvim_win_is_valid(view.bg_win) and view.opts) then
    return
  end

  local layout = view.layout(view.opts)

  vim.api.nvim_win_set_config(win, {
    width = layout.width,
    height = math.max(1, layout.height - 1),
  })

  vim.api.nvim_win_set_config(view.bg_win, {
    relative = "editor",
    row = 1,
    col = 0,
    width = vim.o.columns,
    height = math.max(1, view.height() - 1),
  })
end

local function patch_view_for_bufferline()
  local view = require("zen-mode.view")

  if view._bufferline_patch_applied then
    return
  end

  view._bufferline_patch_applied = true
  local original_fix_layout = view.fix_layout

  view.fix_layout = function(win_resized)
    original_fix_layout(win_resized)
    -- Zen Mode restores its default float sizes on resize, so reapply the
    -- one-row carve-out that keeps the tabline visible.
    if win_resized and view.is_open() then
      apply_bufferline_layout(view.win)
    end
  end
end

return {
  "folke/zen-mode.nvim",
  cmd = "ZenMode",
  opts = {
    window = {
      backdrop = 0.95,
      width = get_zen_width,
      height = 1,
      options = {
        cursorline = false,
        signcolumn = "no",
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = false,
        showcmd = false,
        laststatus = 0,
      },
      gitsigns = { enabled = false },
      tmux = { enabled = false },
    },
    on_open = function(win)
      apply_bufferline_layout(win)
      redraw_tabline()
    end,
    on_close = redraw_tabline,
  },
  config = function(_, opts)
    patch_view_for_bufferline()
    require("zen-mode").setup(opts)
  end,
}
