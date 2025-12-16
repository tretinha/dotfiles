return {
  -- Mason: LSP server installer
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
          }
        }
      })
    end,
  },

  -- Mason-LSPConfig bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          -- Infrastructure/DevOps
          "terraformls",      -- Terraform
          "tflint",           -- Terraform linting
          "yamlls",           -- YAML
          "jsonls",           -- JSON
          "dockerls",         -- Dockerfile
          "bashls",           -- Bash
          
          -- Programming languages
          "lua_ls",           -- Lua (for nvim config)
          "pyright",          -- Python
          "clangd",           -- C/C++ (for glyd codebase)
          "gopls",            -- Go
          
          -- Data/Config formats
          "lemminx",          -- XML
        },
        automatic_installation = true,
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Diagnostic settings
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- LSP on_attach function (keybindings and settings)
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr, noremap = true, silent = true }
        
        -- Navigation
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        
        -- Code actions
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>f", function()
          vim.lsp.buf.format({ async = true })
        end, opts)
        
        -- Diagnostics
        vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
        vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
        vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
        vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, opts)
      end

      -- Default capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Helper function to get root directory patterns
      local function get_root_dir(patterns)
        return function(fname)
          return vim.fs.dirname(vim.fs.find(patterns, { 
            upward = true, 
            path = fname 
          })[1])
        end
      end

      -- Lua LSP (for nvim config)
      vim.lsp.config.lua_ls = {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_dir = get_root_dir({ ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" }),
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }

      -- Python LSP
      vim.lsp.config.pyright = {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_dir = get_root_dir({ "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" }),
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      }

      -- Terraform LSP
      vim.lsp.config.terraformls = {
        cmd = { "terraform-ls", "serve" },
        filetypes = { "terraform", "tf" },
        root_dir = get_root_dir({ ".terraform", ".git" }),
      }

      -- YAML LSP
      vim.lsp.config.yamlls = {
        cmd = { "yaml-language-server", "--stdio" },
        filetypes = { "yaml", "yaml.docker-compose" },
        root_dir = get_root_dir({ ".git" }),
        settings = {
          yaml = {
            schemas = {
              ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
              ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose*.{yml,yaml}",
            },
            format = {
              enable = true,
            },
            validate = true,
          },
        },
      }

      -- JSON LSP
      vim.lsp.config.jsonls = {
        cmd = { "vscode-json-language-server", "--stdio" },
        filetypes = { "json", "jsonc" },
        root_dir = get_root_dir({ "package.json", ".git" }),
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      }

      -- C/C++ LSP (for glyd codebase)
      vim.lsp.config.clangd = {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
          "--query-driver=**",
        },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        root_dir = get_root_dir({ "compile_commands.json", "compile_flags.txt", ".git" }),
        capabilities = vim.tbl_extend("force", capabilities, {
          offsetEncoding = { "utf-16" },
        }),
      }

      -- Go LSP
      vim.lsp.config.gopls = {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = get_root_dir({ "go.work", "go.mod", ".git" }),
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      }

      -- XML LSP
      vim.lsp.config.lemminx = {
        cmd = { "lemminx" },
        filetypes = { "xml", "xsd", "xsl", "xslt", "svg" },
        root_dir = get_root_dir({ ".git" }),
      }

      -- Bash LSP
      vim.lsp.config.bashls = {
        cmd = { "bash-language-server", "start" },
        filetypes = { "sh", "bash" },
        root_dir = get_root_dir({ ".git" }),
      }

      -- Docker LSP
      vim.lsp.config.dockerls = {
        cmd = { "docker-langserver", "--stdio" },
        filetypes = { "dockerfile" },
        root_dir = get_root_dir({ "Dockerfile", ".git" }),
      }

      -- Auto-start LSP servers
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "python", "terraform", "tf", "yaml", "json", "jsonc", "c", "cpp", "go", "xml", "sh", "bash", "dockerfile" },
        callback = function(args)
          local clients = vim.lsp.get_clients({ bufnr = args.buf })
          if #clients > 0 then
            return
          end

          local ft_to_lsp = {
            lua = "lua_ls",
            python = "pyright",
            terraform = "terraformls",
            tf = "terraformls",
            yaml = "yamlls",
            json = "jsonls",
            jsonc = "jsonls",
            c = "clangd",
            cpp = "clangd",
            go = "gopls",
            xml = "lemminx",
            sh = "bashls",
            bash = "bashls",
            dockerfile = "dockerls",
          }

          local lsp_name = ft_to_lsp[vim.bo[args.buf].filetype]
          if lsp_name then
            vim.lsp.enable(lsp_name)
            
            -- Attach keybindings after LSP starts
            vim.api.nvim_create_autocmd("LspAttach", {
              buffer = args.buf,
              once = true,
              callback = function(attach_args)
                on_attach(vim.lsp.get_client_by_id(attach_args.data.client_id), args.buf)
              end,
            })
          end
        end,
      })
    end,
  },

  -- JSON schemas for better JSON/YAML completion
  {
    "b0o/schemastore.nvim",
  },
}
