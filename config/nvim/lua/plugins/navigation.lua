return {
  -- File explorer (replaces NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        renderer = {
          icons = { show = { git = true } },
        },
        filters = {
          git_ignored = false,
        },
      })
    end,
  },
}
