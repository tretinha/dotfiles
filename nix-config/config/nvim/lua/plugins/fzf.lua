return {
  {
    "ibhagwan/fzf-lua",
    dependencies = {},
    opts = {
      files = {
        file_icons = false, 
        color_icons = false,
        git_icons = true,
	-- fd_opts = "--exclude '.terraform'"
      },
      buffers = {
        file_icons = false,
        color_icons = false,
      },
      -- fzf_colors = false, 
    },
    keys = {
      { "<leader>ff", function() require("fzf-lua").files() end, desc = "Find Files" },
      { "<leader>fg", function() require("fzf-lua").git_files() end, desc = "Find Files" },
      { "<leader>fb", function() require("fzf-lua").buffers() end, desc = "Find Buffers" },
      { "<leader>fr", function() require("fzf-lua").grep() end, desc = "Grep" },
      { "<leader>fd", function() require("fzf-lua").git_files({cwd=vim.fn.expand("%:p:h")}) end, desc = "Find files in cwd" },
    },
  }
}
