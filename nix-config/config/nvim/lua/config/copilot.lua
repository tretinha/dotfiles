local M = {}
function M.prompt()
    local prompt_command = "copilot"
    vim.cmd("botright new")
    vim.cmd("resize 25")
    vim.cmd("terminal " .. prompt_command)
end
return M
