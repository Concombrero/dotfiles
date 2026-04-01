local M = {}
local config_readme = vim.fs.joinpath(vim.fn.stdpath("config"), "README.md")

local function telescope_pick(cmd, opts)
  local builtin = require("telescope.builtin")
  local method = cmd == "files" and "find_files" or cmd
  return builtin[method](opts or {})
end

M.preset = {
  pick = telescope_pick,
  keys = {
    { icon = "󰦛 ", key = "s", desc = "Restore Session", action = ":SessionManager load_session" },
    { icon = "󰥔 ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
    { icon = "󰙅 ", key = "e", desc = "Explorer", action = ":Yazi toggle" },
    { icon = "󰈞 ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
    { icon = "󰱼 ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
    { icon = "󰈔 ", key = "n", desc = "New File", action = ":ene | startinsert" },
    { icon = "󰒓 ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
    { icon = "󰋽 ", key = "i", desc = "Info", action = ":execute 'edit ' .. fnameescape('" .. config_readme .. "')" },
    { icon = "󰏗 ", key = "m", desc = "Manage Plugins", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
    { icon = "󰓙 ", key = "h", desc = "Checkhealth", action = ":checkhealth" },
    { icon = "󰩈 ", key = "q", desc = "Quit", action = ":qa!" },
  },
}

M.sections = {
  { section = "keys", gap = 0, padding = 1 },
  { section = 'startup' },
}

return M
