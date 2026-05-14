-- Keymaps (ported from plugin.vim)

local map = vim.keymap.set

-- Helper: close current buffer smartly
local function close_buffer()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs == 1 then
    vim.cmd("bd")
    return
  end
  local alt = vim.fn.bufnr("#")
  local cur = vim.fn.bufnr("%")
  if vim.fn.buflisted(alt) == 1 then
    vim.cmd("b " .. alt .. " | bd " .. cur)
  elseif vim.fn.buflisted(cur) == 1 then
    vim.cmd("bprevious! | bd " .. cur)
  else
    vim.cmd("bprevious!")
  end
end

-- Helper: open FZF from git root if cscope.files exists
local function fzf_with_prj_file()
  local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
  if root and vim.fn.filereadable(root .. "/cscope.files") == 1 then
    vim.cmd("lcd " .. root)
  end
  vim.cmd("FZF")
end

-- Helper: mark current word
local function mark_current_text()
  local word = vim.fn.expand("<cword>")
  vim.cmd("Mark " .. word)
end

-- Helper: async git blame for visual selection
local function async_blame()
  local first = vim.fn.line("'<")
  local last = vim.fn.line("'>")
  vim.cmd("AsyncRun git blame -L " .. first .. "," .. last .. " %")
end

-- Buffer navigation
map("n", "<F2>", "<cmd>b #<CR>", { desc = "Previous opened buffer" })
map("n", "<F3>", "<cmd>bprevious!<CR>", { desc = "Previous buffer" })
map("n", "<F4>", "<cmd>bnext!<CR>", { desc = "Next buffer" })
map("n", "<F5>", close_buffer, { desc = "Close buffer" })
map("n", "<C-n>", "<cmd>enew<CR>", { desc = "New buffer" })

-- FZF file/buffer search
map("n", "<C-o>", fzf_with_prj_file, { desc = "FZF files" })
map("n", "<C-b>", "<cmd>Buffers<CR>", { desc = "FZF buffers" })
map("n", "<C-f>", "<cmd>Lines<CR>", { desc = "FZF lines" })

-- File explorer (nvim-tree)
map("n", "<F9>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<C-F9>", "<cmd>NvimTreeFindFile<CR>", { desc = "Find current file in tree" })

-- Switch .h <-> .cc
map("n", "<F8>", "<cmd>e %:p:s,.h$,.X123X,:s,.cc$,.h,:s,.X123X$,.cc,<CR>", { desc = "Toggle h/cc" })

-- Highlight word with Mark plugin
map("n", "<S-F8>", mark_current_text, { desc = "Mark current word" })

-- ctags override
map("n", "<C-]>", ':ts <C-R>=expand("<cword>")<CR><CR>', { desc = "Tag search" })

-- Copy/Paste (visual mode)
map("v", "<C-c>", '"+yi', { desc = "Copy" })
map("v", "<C-x>", '"+c', { desc = "Cut" })
map("v", "<C-v>", 'c<ESC>"+p', { desc = "Paste" })
map("i", "<C-v>", '<ESC>"+pa', { desc = "Paste (insert)" })

-- Indent
map("n", "<S-Tab>", "<<", { desc = "Unindent" })

-- Window navigation (Alt keys)
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })
map("n", "<A-w>", "<C-w>w", { desc = "Window next" })

-- Terminal mode
vim.g.terminal_scrollback_buffer_size = 100000
map("n", "<A-t>", "<cmd>bel sp | resize 15 | se nonu | terminal<CR>i", { desc = "Open terminal" })

-- Esc in terminal mode: pass through to fzf, otherwise exit terminal mode
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)
    if bufname:match("fzf") then
      -- Let fzf handle Esc natively
      vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<Esc>", { noremap = true, silent = true })
    end
  end,
})
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Note: C-h/j/k/l in terminal mode are handled by vim-tmux-navigator plugin itself

map("t", "<A-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal window left" })
map("t", "<A-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal window down" })
map("t", "<A-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal window up" })
map("t", "<A-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal window right" })
map("t", "<A-w>", [[<C-\><C-n><C-w>w]], { desc = "Terminal window next" })

-- AsyncRun search (ag)
map("n", "<leader>s", ':AsyncRun ag -w <C-R>=expand("<cword>")<CR><CR>', { desc = "Ag search word" })
map("n", "<leader>S", function()
  local ft_map = {
    cpp = "--cpp", c = "--cc", xml = "--xml", yacc = "--yacc",
    lex = '-G "\\.l$"', python = "--python", javascript = "--js", typescript = "--ts",
  }
  local ft_arg = ft_map[vim.bo.filetype] or ("--" .. vim.bo.filetype)
  local word = vim.fn.expand("<cword>")
  vim.cmd("AsyncRun ag -w " .. ft_arg .. " " .. word .. " | ag -iv test")
end, { desc = "Ag search word (filetype, no test)" })

-- AsyncRun git blame (visual)
map("v", "b", async_blame, { desc = "Git blame selection" })

-- Claude terminal
map("n", "<leader>c", "<cmd>botright vsp | vertical resize 80 | se nonu | terminal claude<CR>i", { desc = "Open Claude" })

-- Shell command in buffer
vim.api.nvim_create_user_command("S", function(opts)
  vim.cmd("botright new")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.opt_local.swapfile = false
  vim.opt_local.wrap = false
  vim.fn.setline(1, opts.args)
  vim.cmd("$read !" .. opts.args)
  vim.bo.modifiable = false
end, { nargs = "+", complete = "shellcmd" })

-- Open files from git show/diff
vim.api.nvim_create_user_command("OpenFilesInGit", function(opts)
  local result = vim.fn.system("git show --name-only --oneline " .. opts.args)
  if result:match("fatal: ambiguous argument") then
    vim.notify("[Error] current git doesn't contain commit - " .. opts.args, vim.log.levels.ERROR)
    return
  end
  local lines = vim.split(result, "\n")
  table.remove(lines, 1)
  local files = table.concat(lines, " ")
  if files ~= "" then vim.cmd("args " .. files) end
end, { nargs = "*", complete = "shellcmd" })

vim.api.nvim_create_user_command("OpenFilesInGitDiff", function(opts)
  local result = vim.fn.system("git diff --name-only --oneline " .. opts.args)
  local files = table.concat(vim.split(vim.trim(result), "\n"), " ")
  if files ~= "" then vim.cmd("args " .. files) end
end, { nargs = "*", complete = "shellcmd" })
