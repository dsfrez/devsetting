return {
  -- Indent guides (replaces indentLine)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = { "|", "¦", "┆", "┊" } },
    },
  },
  -- Highlight words
  { "vim-scripts/Mark--Karkat" },
  -- Seamless tmux navigation
  { "christoomey/vim-tmux-navigator" },
  -- Text alignment
  { "godlygeek/tabular", cmd = "Tabularize" },
  -- PlantUML syntax
  { "aklt/plantuml-syntax", ft = "plantuml" },
}
