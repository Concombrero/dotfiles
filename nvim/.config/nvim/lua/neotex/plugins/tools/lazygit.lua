-- nvim v0.8.0
return {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
        "LazyGit",
        "LazyGitConfig",
        "LazyGitCurrentFile",
        "LazyGitFilter",
        "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    -- Plugin is loaded when <leader>g triggers LazyGit via which-key,
    -- or when any LazyGit command is run directly.
    keys = {
        { "<leader>g", "<cmd>lua vim.schedule(function() require('neotex.plugins.tools.snacks.utils').safe_lazygit() end)<cr>", desc = "lazygit" }
    }
}
