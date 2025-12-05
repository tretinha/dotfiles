local M = {}
function M.build(target)
    vim.notify(target, vim.log.levels.ERROR)
    local build_command = "make"
    if target == "sb" then
        build_command = "make app=sp-sandbox-eks-1"
    elseif target == "ci" then
        build_command = "make app=eks-ci"
    elseif target == "2" then
        build_command = "make app=sp-gdf2-k8s"
    elseif target == "w1" then
        build_command = "make app=sp-wayside-prd-1"
    else
        vim.notify("Invalid build target. Use \"sb\" or \"ci\".", vim.log.levels.ERROR)
        return
    end
    vim.cmd("botright new")
    vim.cmd("resize 25")
    vim.cmd("terminal " .. build_command)
end
return M
