return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    -- Optional: Configure Treesitter modules and parsers
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "c", "lua", "vimdoc", "cue", "terraform", "yaml", "gotmpl", "helm" }, -- Specify parsers to install
        highlight = { enable = false }, -- Enable highlighting
        indent = { enable = false }, -- Enable indentation
        -- Add other modules as needed
      })
    end,
  },
}
