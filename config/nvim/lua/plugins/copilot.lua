-- Gated behind SAP_COPILOT=1 environment variable
if vim.env.SAP_COPILOT ~= "1" then
  return {}
end

return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Use nvm node if available, otherwise system node
      local nvm_node = vim.fn.expand("~/.config/nvm/versions/node/v20.15.0/bin/node")
      if vim.fn.filereadable(nvm_node) == 1 then
        vim.g.copilot_node_command = nvm_node
      end
    end,
  },
}
