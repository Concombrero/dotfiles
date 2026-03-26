-- LuaSnip (Typst-specific configuration)
-- This spec merges with the LuaSnip spec in nvim-cmp.lua.
-- We use opts + config to ensure autosnippets are enabled and
-- the Lua snippet loader picks up ./LuaSnip/ and ./snippets/.
return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  opts = {
    history = true,
    enable_autosnippets = true,
    store_selection_keys = "<Tab>",
  },
  config = function(_, opts)
    local luasnip = require("luasnip")
    luasnip.setup(opts)
    -- Load Lua-format snippets (LuaSnip/*.lua)
    require("luasnip.loaders.from_lua").lazy_load({ paths = { "./LuaSnip" } })
    -- Load snipmate-format snippets (snippets/*.snippets)
    require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "./snippets" } })
  end,
  keys = function()
    return {}
  end,
}
