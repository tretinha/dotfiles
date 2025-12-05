local M = {}
function M.build(target)
    vim.notify(target, vim.log.levels.ERROR)
    local file_dir = vim.fn.expand('%:p:h')
    local build_command = "just"
    if target == "init" then
        build_command = "cd " .. file_dir .. " && just init"
    elseif target == "clean" then
        build_command = "cd " .. file_dir .. " && just clean && just init"
    elseif target == "plan" then
        build_command = "cd " .. file_dir .. " && just plan"
    elseif target == "apply" then
        build_command = "cd " .. file_dir .. " && just apply"
    else
        vim.notify("Invalid build target. Use \"init\", \"plan\" or \"clean\".", vim.log.levels.ERROR)
        return
    end
    vim.cmd("botright new")
    vim.cmd("resize 45")
    vim.cmd("terminal " .. build_command)
end
return M
