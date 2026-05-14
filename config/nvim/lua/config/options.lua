-- Options (ported from .vimrc)

-- Encoding
vim.opt.encoding = "utf-8"
vim.opt.fileencodings = { "utf-8", "cp949" }
vim.scriptencoding = "utf-8"

-- Indent & Tab
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.cinoptions = "g0,:0"
vim.opt.cinkeys:remove("0#")
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.wrap = false

-- Search
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.incsearch = true

-- Display
vim.opt.title = true
vim.opt.titlestring = "%t%( %M%)%( (%{expand(\"%:p:h\")})%)%( %a%) - %{v:servername}"
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.number = true
vim.opt.ruler = true
vim.opt.showmatch = true
vim.opt.laststatus = 2
vim.opt.mouse = "a"

-- Buffer
vim.opt.hidden = true
vim.opt.autoread = true
vim.opt.swapfile = false
vim.opt.visualbell = false
vim.opt.backspace = { "indent", "eol", "start" }

-- Appearance
vim.opt.background = "dark"
vim.opt.list = true
vim.opt.listchars = { tab = "»·", trail = "·", extends = "$", nbsp = "=" }

-- Fold
vim.opt.foldmethod = "manual"
vim.opt.foldlevel = 20
vim.opt.foldlevelstart = 20

-- Undo
local undodir = vim.fn.stdpath("data") .. "/undodir"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
vim.opt.undodir = undodir
vim.opt.undofile = true

-- Python3 host
local python3 = vim.fn.exepath("python3")
if python3 ~= "" then
  vim.g.python3_host_prog = python3
end
