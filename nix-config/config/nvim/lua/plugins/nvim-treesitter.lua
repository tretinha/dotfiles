return {
  { "tpope/vim-sleuth" }, -- detects indentation of the file for tabs, helping treesitter's indent
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "c", "lua", "vimdoc", "cue", "terraform", "yaml", "gotmpl", "helm" }, -- Specify parsers to install
        highlight = { enable = false }, -- Not particularly a fan
        indent = { enable = true },
      })
    end,
  },
}
