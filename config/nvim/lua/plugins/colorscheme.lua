return {
  {
    "rafi/awesome-vim-colorschemes",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("apprentice")
    end,
  },
}
