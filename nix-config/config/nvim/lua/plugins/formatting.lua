-- Formatting plugin for ALL projects
-- Uses system-wide tools by default
-- Automatically switches to glyd repo tools when inside ~/glyd

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      -- Define formatters per filetype (works everywhere)
      formatters_by_ft = {
        -- C/C++ - clang-format
        c = { "clang_format" },
        cpp = { "clang_format" },
        
        -- Python - ruff (format + fix) + isort
        python = { "ruff_format", "ruff_fix", "isort" },
        
        -- JavaScript/TypeScript - prettier
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        
        -- Shell - shfmt
        sh = { "shfmt" },
        bash = { "shfmt" },
        
        -- YAML - prettier
        yaml = { "prettier" },
        
        -- JSON - prettier
        json = { "prettier" },
        jsonc = { "prettier" },
        
        -- Go - gofmt
        go = { "gofmt" },
        
        -- Bazel/Starlark - buildifier
        bzl = { "buildifier" },
        
        -- Terraform - terraform_fmt
        terraform = { "terraform_fmt" },
        tf = { "terraform_fmt" },
        
        -- CUE - cue_fmt
        cue = { "cue_fmt" },
        
        -- CMake - cmake_format
        cmake = { "cmake_format" },
        
        -- Nix - nixfmt
        nix = { "nixfmt" },
        
        -- Markdown - prettier
        markdown = { "prettier" },
      },
      
      -- Helper function to detect if we're in glyd repo
      formatters = {
        -- clang-format: use glyd's if available, otherwise system
        clang_format = {
          command = function()
            local cwd = vim.fn.getcwd()
            -- Check if we're in glyd repo
            if cwd:match("/glyd") or cwd:match("/glyd$") then
              local glyd_clang_format = cwd:match("^(.-/glyd)") .. "/scripts/bin/clang-format"
              if vim.fn.filereadable(glyd_clang_format) == 1 then
                return glyd_clang_format
              end
            end
            return "clang-format" -- system default
          end,
        },
        
        -- ruff format: use glyd's if available
        ruff_format = {
          command = function()
            local cwd = vim.fn.getcwd()
            if cwd:match("/glyd") or cwd:match("/glyd$") then
              local glyd_ruff = cwd:match("^(.-/glyd)") .. "/scripts/bin/ruff"
              if vim.fn.filereadable(glyd_ruff) == 1 then
                return glyd_ruff
              end
            end
            return "ruff"
          end,
        },
        
        -- ruff fix: use glyd's if available
        ruff_fix = {
          command = function()
            local cwd = vim.fn.getcwd()
            if cwd:match("/glyd") or cwd:match("/glyd$") then
              local glyd_ruff = cwd:match("^(.-/glyd)") .. "/scripts/bin/ruff"
              if vim.fn.filereadable(glyd_ruff) == 1 then
                return glyd_ruff
              end
            end
            return "ruff"
          end,
          args = { "check", "--fix", "--force-exclude", "--stdin-filename", "$FILENAME", "-" },
        },
        
        -- shfmt: use consistent settings everywhere
        shfmt = {
          prepend_args = { "-i", "2", "-ci", "-s" }, -- 2-space indent, case indent, simplify
        },
        
        -- buildifier: use glyd's if available
        buildifier = {
          command = function()
            local cwd = vim.fn.getcwd()
            if cwd:match("/glyd") or cwd:match("/glyd$") then
              local glyd_buildifier = cwd:match("^(.-/glyd)") .. "/.trunk/tools/buildifier"
              if vim.fn.filereadable(glyd_buildifier) == 1 then
                return glyd_buildifier
              end
            end
            return "buildifier"
          end,
        },
      },
      
      -- Format on save (smart exclusions)
      format_on_save = function(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        
        -- Global exclusions (any project)
        local global_exclude_patterns = {
          "/node_modules/",
          "%.min%.js$",
          "%.min%.css$",
          "/vendor/",
          "/%.git/",
        }
        
        for _, pattern in ipairs(global_exclude_patterns) do
          if bufname:match(pattern) then
            return nil
          end
        end
        
        -- Glyd-specific exclusions (only when in glyd repo)
        if bufname:match("/glyd/") then
          local glyd_exclude_patterns = {
            "third_party/",
            "/generated/",
            "/gen/",
            "env%.sh$",
            "glyd/dev/linters/test_data/",
            "glyd/experimental/",
            "glyd/infra/kustomize/",
            "glyd/infra/release/",
            "cue%.mod/gen/",
            "bazel%-",
            "%.backup$",
            "glyd/asil/.*%.py$",
            "glyd/dev/third_party/.*%.py$",
          }
          
          for _, pattern in ipairs(glyd_exclude_patterns) do
            if bufname:match(pattern) then
              return nil
            end
          end
        end
        
        return {
          timeout_ms = 500,
          lsp_fallback = true,
        }
      end,
    },
  },

  -- Linting plugin (works everywhere)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
      
      -- Configure linters per filetype (works everywhere)
      lint.linters_by_ft = {
        -- Python - ruff
        python = { "ruff" },
        
        -- Shell - shellcheck
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        
        -- JavaScript/TypeScript - eslint
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        
        -- Go - golangci-lint
        go = { "golangcilint" },
        
        -- Terraform - tflint
        terraform = { "tflint" },
        tf = { "tflint" },
        
        -- YAML - yamllint
        yaml = { "yamllint" },
        
        -- Dockerfile - hadolint
        dockerfile = { "hadolint" },
        
        -- Nix - nix (statix for now, can add deadnix)
        nix = { "nix" },
      }
      
      -- Customize ruff to use glyd's when available
      local original_ruff_cmd = lint.linters.ruff.cmd
      lint.linters.ruff.cmd = function()
        local cwd = vim.fn.getcwd()
        if cwd:match("/glyd") or cwd:match("/glyd$") then
          local glyd_ruff = cwd:match("^(.-/glyd)") .. "/scripts/bin/ruff"
          if vim.fn.filereadable(glyd_ruff) == 1 then
            return glyd_ruff
          end
        end
        return original_ruff_cmd or "ruff"
      end
      
      -- Auto-lint on save and text change
      local lint_augroup = vim.api.nvim_create_augroup("nvim_lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          local bufname = vim.api.nvim_buf_get_name(0)
          
          -- Global exclusions
          if bufname:match("/node_modules/") or bufname:match("/vendor/") then
            return
          end
          
          -- Glyd-specific exclusions
          if bufname:match("/glyd/") then
            local glyd_exclude_patterns = {
              "third_party/",
              "/generated/",
              "/gen/",
              "env%.sh$",
              "glyd/dev/linters/test_data/",
              "glyd/experimental/",
              "bazel%-",
            }
            
            for _, pattern in ipairs(glyd_exclude_patterns) do
              if bufname:match(pattern) then
                return
              end
            end
          end
          
          lint.try_lint()
        end,
      })
    end,
  },
}
