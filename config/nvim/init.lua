-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

-- Core config
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- Plugin manager
require("lazy").setup("plugins", {
  defaults = { lazy = false },
  install = { colorscheme = { "apprentice" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})

-- Local overrides (machine-specific, not tracked in git)
pcall(require, "local")
