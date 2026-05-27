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
      vim.fn["quickmenu#append"]("File Explorer  [<F9>]", "NvimTreeToggle", "Toggle file explorer")
      vim.fn["quickmenu#append"]("File Explorer - current location  [<C-F9>]", "NvimTreeFindFile", "Find current file")
      vim.fn["quickmenu#append"]("Open All Files in HEAD", "OpenFilesInGit", "Open all files in 'git show --name-only'")
      vim.fn["quickmenu#append"]("Open All Files in Diff", "OpenFilesInGitDiff", "Open all files in 'git diff --name-only'")

      vim.fn["quickmenu#append"]("# Vim Preferences", "")
      vim.fn["quickmenu#append"]("Toggle Paste", "set paste!", "Set/Unset PASTE mode")
      vim.fn["quickmenu#append"]("Toggle Cursorcolumn", "set cursorcolumn!", "Show/Hide cursor column")
      vim.fn["quickmenu#append"]("Toggle Word wrap", "set wrap!", "Set/Unset word wrap")

      if vim.env.DEVSETTING_CORP == "1" then
        vim.fn["quickmenu#append"]("# Claude", "")
        vim.fn["quickmenu#append"]("Open Claude (side)  [<leader>c]", "botright vsp | vertical resize 80 | se nonu | terminal claude", "Open Claude in vertical split")
        vim.fn["quickmenu#append"]("Open Claude (fullscreen)", "enew | se nonu | terminal claude", "Open Claude in full screen")
        -- Send literal Esc byte to a claude terminal (interrupt claude without leaving terminal mode - F6)
        vim.api.nvim_create_user_command("ClaudeSendEsc", function()
          local target_job = nil
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(buf) then
              local name = vim.api.nvim_buf_get_name(buf)
              if name:match("claude") and vim.bo[buf].buftype == "terminal" then
                target_job = vim.b[buf].terminal_job_id
                break
              end
            end
          end
          if target_job then
            vim.fn.chansend(target_job, "\27")
          else
            vim.notify("No claude terminal buffer found", vim.log.levels.WARN)
          end
        end, {})
        vim.fn["quickmenu#append"]("Send Esc to Claude  [<F6> in claude buf]", "ClaudeSendEsc", "Interrupt claude (send Esc)")
      end
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
