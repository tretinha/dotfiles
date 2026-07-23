require("config.lazy")

vim.opt.termguicolors = false
vim.cmd("colorscheme torte")

-- Build configuration to just clean
vim.keymap.set("n", "<leader>jc", function()
    require("config.just_build").build("clean")
end, { desc = "Just clean" })

-- Build configuration to just init
vim.keymap.set("n", "<leader>ji", function()
    require("config.just_build").build("init")
end, { desc = "Just init" })

-- Build configuration to just plan
vim.keymap.set("n", "<leader>jp", function()
    require("config.just_build").build("plan")
end, { desc = "Just plan" })

-- Build configuration to just apply
vim.keymap.set("n", "<leader>ja", function()
    require("config.just_build").build("apply")
end, { desc = "Just apply" })

-- Snippet to add my // NOTE(gustavo) comments, usually in cuelang files
local function expand_note()
  local body = "// NOTE(gustavo): $0"
  vim.snippet.expand(body)
end

-- Using <C-n> (Control + n) as the trigger for my notes
vim.keymap.set("i", "<C-n>", expand_note, {
  desc = "Expand // NOTE(gustavo): snippet",
  noremap = true, 
  silent = true 
})

local function expand_copyright_banner()
    local body = "/*\n * Copyright © 2026 Glydways, Inc.\n * https://glydways.com/\n */\n"
    vim.snippet.expand(body)
end

-- Using <C-g> (Control + g) as the trigger for Glydways copyright
vim.keymap.set("i", "<C-g>", expand_copyright_banner, {
  desc = "Expand multi-line snippet",
  noremap = true, 
  silent = true 
})

-- Snippet to add the multi-line #... header ...# comment
local function expand_header_banner()
  local hash_line = string.rep("#", 80)
  local body = hash_line .. "\n# $0\n" .. hash_line
  
  vim.snippet.expand(body)
end

-- Using <C-b> (Control + b) as the trigger for TFComment
vim.keymap.set("i", "<C-b>", expand_header_banner, {
  desc = "Expand multi-line # Header # snippet",
  noremap = true,
  silent = true
})

-- TERMINAL mode use ESC to go back to NORMAL
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Disable swap
vim.opt.swapfile = false

-- Fix for Nix-managed symlinked files
-- Without this, vim tries to rename over symlinks and fails with E13
vim.opt.backupcopy = "yes"
