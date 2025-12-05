require("config.lazy")
require("config.build")

-- plan9 acme style
vim.opt.termguicolors = true
require("colors.acme")

-- Build configuration to make app=sp-sandbox-eks-1
vim.keymap.set("n", "<leader>bs", function()
    require("config.build").build("sb")
end, { desc = "Build Sandbox EKS" })

-- Build configuration to make app=eks-ci
vim.keymap.set("n", "<leader>bc", function()
    require("config.build").build("ci")
end, { desc = "Build CI EKS" })

-- Build configuration to make app=sp-gdf2-k8s
vim.keymap.set("n", "<leader>b2", function()
    require("config.build").build("2")
end, { desc = "Build GDF2 EKS" })

-- Build configuration to make app=sp-wayside-prd-1
vim.keymap.set("n", "<leader>w", function()
    require("config.build").build("w1")
end, { desc = "Build Wayside EKS 1" })

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

-- Runs copilot in interactive mode
vim.keymap.set("n", "<leader>c", function()
    require("config.copilot").prompt()
end, { desc = "Copilot interactive" })

-- TERMINAL mode use ESC to go back to NORMAL
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Disable swap
vim.opt.swapfile = false
