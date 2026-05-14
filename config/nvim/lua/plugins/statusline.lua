return {
  -- Use vim-airline as before
  {
    "vim-airline/vim-airline",
    dependencies = { "vim-airline/vim-airline-themes" },
    init = function()
      -- Must be set BEFORE plugin loads
      vim.g.airline_theme = "angr"
      vim.g["airline#extensions#tabline#enabled"] = 1
      vim.g["airline#extensions#tabline#fnamemod"] = ":t"
      vim.g["airline#extensions#tabline#buffer_nr_show"] = 1
      vim.g["airline#extensions#tabline#buffer_nr_format"] = "%s:"
      vim.g["airline#extensions#tabline#buffer_idx_mode"] = 1
      vim.g.airline_powerline_fonts = 1
      -- Show terminal buffers in tabline (default pattern excludes term://)
      vim.g["airline#extensions#tabline#ignore_bufadd_pat"] = "!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler"
    end,
  },
}
