-- Autocommands (ported from plugin.vim / .vimrc)

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Whitespace highlight
augroup("ExtraWhitespace", { clear = true })
autocmd({ "BufWinEnter", "InsertLeave" }, {
  group = "ExtraWhitespace",
  pattern = "*",
  callback = function()
    vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
  end,
})
autocmd("ColorScheme", {
  group = "ExtraWhitespace",
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "red" })
  end,
})

-- Dim inactive windows (replaces vim-diminactive)
-- Uses winhighlight to set background on inactive windows uniformly,
-- including empty lines and terminal buffers.
augroup("DimInactive", { clear = true })
autocmd("ColorScheme", {
  group = "DimInactive",
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
    vim.api.nvim_set_hl(0, "NormalInactive", { ctermbg = 236 })
  end,
})
autocmd("WinLeave", {
  group = "DimInactive",
  pattern = "*",
  callback = function()
    vim.wo.winhl = "Normal:NormalInactive"
  end,
})
autocmd("WinEnter", {
  group = "DimInactive",
  pattern = "*",
  callback = function()
    vim.wo.winhl = ""
  end,
})

-- Tmux window rename
augroup("TmuxRename", { clear = true })
local current_shell = vim.fn.system("echo $(basename $SHELL)"):gsub("%s+$", "")
local tmux_window = vim.fn.system("tmux display-message -p '#W'"):gsub("%s+$", "")
if tmux_window == current_shell then
  autocmd({ "BufReadPost", "FileReadPost", "BufNewFile" }, {
    group = "TmuxRename",
    pattern = "*",
    callback = function()
      vim.fn.system("tmux rename-window " .. vim.fn.expand("%:t"))
    end,
  })
  autocmd("VimLeave", {
    group = "TmuxRename",
    pattern = "*",
    callback = function()
      vim.fn.system("tmux rename-window " .. current_shell)
    end,
  })
end

-- List terminal buffers in airline tabline
augroup("TerminalBuflisted", { clear = true })
autocmd("TermOpen", {
  group = "TerminalBuflisted",
  pattern = "*",
  callback = function()
    vim.bo.buflisted = true
  end,
})

-- ctags location from git root
local function init_ctag_location()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if root then
    local tags_path = root .. "/tags"
    if vim.fn.filereadable(tags_path) == 1 then
      vim.opt.tags = tags_path
    end
  end
end
init_ctag_location()
