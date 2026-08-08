-- CATPPUCCIN (light theme aligned with the Solarized workspace)
return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    require("catppuccin").setup({
      flavour = "latte",
      transparent_background = true,
      background = {
        light = "latte",
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        mason = true,
        which_key = true,
        -- Add any other plugins you use
      },
      highlight_overrides = {
        latte = function(latte)
          return {
            Normal = { fg = "#000000" },
            NormalNC = { fg = "#000000" },
            Comment = { fg = "#586e75" },
            LineNr = { fg = "#839496" },
            CursorLineNr = { fg = "#268bd2" },
            NormalFloat = { fg = "#000000", bg = latte.base },
            FloatBorder = { fg = latte.blue, bg = latte.base },
            FloatTitle = { fg = "#000000", bg = latte.base },
          }
        end,
      },
    })
    require("catppuccin").load("latte")
  end,
}

-- -- MONOKAI
-- return {
--   "tanvirtin/monokai.nvim",  -- Monokai theme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("monokai").setup {
--       -- palette = require("monokai").pro,  -- Use Monokai Pro palette
--     }
--   vim.cmd("colorscheme monokai")
--   end
-- }

-- -- KANAGAWA
-- return {
--   "rebelot/kanagawa.nvim",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require('kanagawa').setup({
--       compile = false,  -- enable compiling the colorscheme
--       undercurl = true, -- enable undercurls
--       commentStyle = { italic = true },
--       functionStyle = {},
--       keywordStyle = { italic = true },
--       statementStyle = { bold = true },
--       typeStyle = {},
--       transparent = false,   -- do not set background color
--       dimInactive = false,   -- dim inactive window `:h hl-NormalNC`
--       terminalColors = true, -- define vim.g.terminal_color_{0,17}
--       colors = {
--         -- add/modify theme and palette colors
--         palette = {},
--         theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
--       },
--       overrides = function(colors) -- add/modify highlights
--         return {}
--       end,
--       theme = "wave", -- Load "wave" theme when 'background' option is not set
--       background = {
--         -- map the value of 'background' option to a theme
--         dark = "wave", -- try "dragon" !
--         light = "lotus"
--       },
--     })
--     vim.cmd("colorscheme kanagawa") -- setup must be called before loading
--   end,
-- }



-- -- NIGHTFLY
-- return {
--   "bluz71/vim-nightfly-guicolors",
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     -- load the colorscheme here
--     vim.cmd("colorscheme nightfly")
--   end,
-- }


-- OTHER
-- "luisiacc/gruvbox-baby"
-- "folke/tokyonight.nvim"
-- "lunarvim/darkplus.nvim"
-- "navarasu/onedark.nvim"
-- "savq/melange"
-- "EdenEast/nightfox.nvim"
