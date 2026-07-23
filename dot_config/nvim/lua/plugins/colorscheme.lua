-- https://github.com/Mofiqul/dracula.nvim
return {
  "Mofiqul/dracula.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("dracula").setup({})
    vim.cmd.colorscheme("dracula")
  end,
}
