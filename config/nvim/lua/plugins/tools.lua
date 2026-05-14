return {
  -- Async run
  {
    "skywind3000/asyncrun.vim",
    config = function()
      vim.g.asyncrun_open = 12
      vim.g.asyncrun_bell = 1
    end,
  },
  -- Quick menu (F1)
  {
    "skywind3000/quickmenu.vim",
    keys = { { "<F1>", "<cmd>call quickmenu#toggle(0)<CR>", desc = "Toggle quick menu" } },
    config = function()
      vim.g.quickmenu_options = "HL"
      vim.fn["quickmenu#reset"]()

      vim.fn["quickmenu#append"]("# Navigation", "")
      vim.fn["quickmenu#append"]("File Explorer", "NvimTreeToggle", "Toggle file explorer - F9")
      vim.fn["quickmenu#append"]("File Explorer - current location", "NvimTreeFindFile", "Find current file - Ctrl-F9")
      vim.fn["quickmenu#append"]("Open All Files in HEAD", "OpenFilesInGit", "Open all files in 'git show --name-only'")
      vim.fn["quickmenu#append"]("Open All Files in Diff", "OpenFilesInGitDiff", "Open all files in 'git diff --name-only'")

      vim.fn["quickmenu#append"]("# Vim Preferences", "")
      vim.fn["quickmenu#append"]("Toggle Paste", "set paste!", "Set/Unset PASTE mode")
      vim.fn["quickmenu#append"]("Toggle Cursorcolumn", "set cursorcolumn!", "Show/Hide cursor column")
      vim.fn["quickmenu#append"]("Toggle Word wrap", "set wrap!", "Set/Unset word wrap")

      vim.fn["quickmenu#append"]("# Claude", "")
      vim.fn["quickmenu#append"]("Open Claude (side)", "botright vsp | vertical resize 80 | se nonu | terminal claude", "Open Claude in vertical split - <leader>c")
      vim.fn["quickmenu#append"]("Open Claude (fullscreen)", "enew | se nonu | terminal claude", "Open Claude in full screen")
    end,
  },
  -- Tagbar
  {
    "preservim/tagbar",
    keys = { { "<F12>", "<cmd>TagbarToggle<CR>", desc = "Toggle tagbar" } },
  },
  -- Source Explorer (on-demand)
  {
    "wesleyche/srcexpl",
    keys = { { "<F11>", "<cmd>SrcExplToggle<CR>", desc = "Toggle source explorer" } },
    config = function()
      vim.g.SrcExpl_winHeight = 12
      vim.g.SrcExpl_jumpKey = "<ENTER>"
      vim.g.SrcExpl_gobackKey = "<SPACE>"
      vim.g.SrcExpl_isUpdateTags = 0
      vim.g.SrcExpl_pluginList = {
        "__Tag_List__", "_NERD_tree_", "Source_Explorer", "bash",
      }
    end,
  },
  -- cscope autoload
  { "vim-scripts/autoload_cscope.vim" },
}
