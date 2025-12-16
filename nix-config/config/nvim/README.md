# Neovim LSP + Formatters + Linters Setup

## Overview

This setup provides **universal** formatting and linting for all file types, with **automatic detection** of the glyd repository to use glyd-specific tools when available.

## How It Works

### 🌍 **Global Mode (Everywhere)**

When you open any file outside of `/home/gustavo/glyd/`:

- Uses **system-wide** formatters/linters installed via Nix
- Works consistently across all your projects
- Example: Python files use system `ruff`, C++ uses system `clang-format`

### 🏢 **Glyd Mode (Inside ~/glyd)**

When you open files inside `/home/gustavo/glyd/`:

- **Automatically detects** the glyd repository
- Uses **glyd's own binaries**: `scripts/bin/clang-format`, `scripts/bin/ruff`, etc.
- Matches CI configuration **exactly**
- Respects glyd's exclusion patterns (third_party/, generated/, etc.)

## Supported Languages & Tools

| Language                  | LSP          | Linter                  | Formatter     | Glyd Override                      |
| ------------------------- | ------------ | ----------------------- | ------------- | ---------------------------------- |
| **C/C++**                 | clangd       | clang-tidy (via clangd) | clang-format  | ✅ Uses `scripts/bin/clang-format` |
| **Python**                | pyright      | ruff                    | ruff + isort  | ✅ Uses `scripts/bin/ruff`         |
| **JavaScript/TypeScript** | tsserver     | eslint_d                | prettier      | ❌ Uses system tools               |
| **Shell**                 | bashls       | shellcheck              | shfmt         | ❌ Uses system tools               |
| **Go**                    | gopls        | golangci-lint           | gofmt         | ❌ Uses system tools               |
| **Terraform**             | terraform-ls | tflint                  | terraform fmt | ❌ Uses system tools               |
| **YAML**                  | yamlls       | yamllint                | prettier      | ❌ Uses system tools               |
| **JSON**                  | jsonls       | -                       | prettier      | ❌ Uses system tools               |
| **Bazel**                 | -            | -                       | buildifier    | ✅ Uses `.trunk/tools/buildifier`  |
| **CMake**                 | -            | -                       | cmake-format  | ❌ Uses system tools               |
| **CUE**                   | cuelsp       | -                       | cue fmt       | ❌ Uses system tools               |
| **Nix**                   | nil/rnix     | statix                  | nixfmt        | ❌ Uses system tools               |
| **Markdown**              | marksman     | -                       | prettier      | ❌ Uses system tools               |
| **Docker**                | dockerls     | hadolint                | -             | ❌ Uses system tools               |

## Installation

### 1. Apply Nix Configuration

```bash
cd ~/dotfiles/nix-config
home-manager switch --flake .#gustavo@work
```

This installs all formatters/linters system-wide via Nix.

### 2. Install Neovim Plugins

Plugins auto-install on first `nvim` launch, but you can force it:

```bash
nvim +Lazy
# Press 'I' to install
# Press 'q' to quit
```

### 3. Verify Installation

```bash
# Check formatters are available
which clang-format ruff prettier shfmt shellcheck

# Check LSP servers (some installed via Mason in nvim)
nvim +Mason
# Press 'q' to quit
```

## Usage

### Formatting

**Keybinding:** `<leader>f` (Space + f)

Formats the current buffer using the appropriate formatter.

**Auto-format on save:** Enabled by default.

To disable for a specific buffer:

```vim
:lua vim.b.disable_autoformat = true
```

To disable globally:

```lua
-- Add to init.lua
vim.g.disable_autoformat = true
```

### Linting

Linting happens **automatically**:

- On file save (`:w`)
- When entering a buffer
- When leaving insert mode

**Navigate diagnostics:**

- `]d` - Next diagnostic
- `[d` - Previous diagnostic
- `<leader>e` - Show diagnostic float
- `<leader>q` - Open diagnostic list

### LSP Features

**Navigation:**

- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `gr` - Find references
- `K` - Hover documentation

**Code actions:**

- `<leader>ca` - Code action
- `<leader>rn` - Rename symbol

## Checking What's Active

### See active formatters

```vim
:ConformInfo
```

Shows:

- Available formatters for current filetype
- Which formatter will be used
- Whether it's found on the system

### See active linters

```vim
:lua print(vim.inspect(require('lint').linters_by_ft[vim.bo.filetype]))
```

### See LSP status

```vim
:LspInfo
```

Shows:

- Active LSP clients
- Client capabilities
- Root directory

## Examples

### Python File (Global)

```bash
nvim ~/my-project/script.py
```

- LSP: pyright (type checking)
- Linter: ruff (system)
- Formatter: ruff + isort (system)
- `<leader>f` formats with system ruff

### Python File (Glyd)

```bash
nvim ~/glyd/glyd/etl/extract/some_script.py
```

- LSP: pyright (type checking)
- Linter: ruff (glyd's `scripts/bin/ruff`)
- Formatter: ruff + isort (glyd's version)
- `<leader>f` formats with glyd's ruff
- Respects `.ruff.toml` config

### C++ File (Global)

```bash
nvim ~/my-cpp-project/main.cc
```

- LSP: clangd (if compile_commands.json exists)
- Linter: clang-tidy (via clangd)
- Formatter: clang-format (system)

### C++ File (Glyd)

```bash
nvim ~/glyd/glyd/base/time/time.cc
```

- LSP: clangd (uses glyd's compile_commands.json)
- Linter: clang-tidy (via clangd, uses `.clang-tidy`)
- Formatter: clang-format (glyd's `scripts/bin/clang-format`)
- Uses `.clang-format` config (4-space indent, etc.)

### Shell Script (Anywhere)

```bash
nvim ~/scripts/backup.sh
```

- LSP: bashls
- Linter: shellcheck (respects `.shellcheckrc` if present)
- Formatter: shfmt (-i 2 -ci -s)

## Glyd-Specific Features

### Automatic Detection

The config automatically detects when you're in the glyd repo by:

1. Checking if `cwd` contains `/glyd`
2. Extracting the glyd root path
3. Looking for glyd-specific binaries

### Glyd Exclusions

These paths are **never** formatted/linted in glyd:

- `third_party/`
- `generated/`, `gen/`
- `env.sh` (symlink)
- `glyd/dev/linters/test_data/`
- `glyd/experimental/`
- `glyd/infra/kustomize/`, `glyd/infra/release/`
- `cue.mod/gen/`
- `bazel-*` (bazel output directories)
- `.backup` files
- `glyd/asil/**/*.py` (excluded from Python formatters)

### Glyd-Specific Binaries Used

When in glyd, these override system tools:

1. **clang-format**: `~/glyd/scripts/bin/clang-format`
   - Uses bazel-downloaded clang-format-16
   - Respects `~/.clang-format`

2. **ruff**: `~/glyd/scripts/bin/ruff`
   - Wrapper around trunk's ruff
   - Respects `~/.ruff.toml`

3. **buildifier**: `~/glyd/.trunk/tools/buildifier`
   - Glyd's specific buildifier version
   - Respects `.buildifier.json`

## Troubleshooting

### "Formatter not found"

**Check if installed:**

```bash
which clang-format ruff prettier
```

**If missing, reinstall:**

```bash
cd ~/dotfiles/nix-config
home-manager switch --flake .#gustavo@work
```

### "LSP not attaching"

**Check LSP status:**

```vim
:LspInfo
```

**Common issues:**

- **C++**: No `compile_commands.json` → Run `./scripts/bin/generate_compile_commands.sh` in glyd
- **Python**: Wrong Python version → Check `:lua print(vim.fn.exepath('python3'))`
- **Node-based LSPs**: Missing node → `which node`

**Restart LSP:**

```vim
:LspRestart
```

### "Glyd tools not being used"

**Verify path detection:**

```vim
:lua print(vim.fn.getcwd())
```

Should show `/home/gustavo/glyd` when in glyd.

**Check if glyd binary exists:**

```bash
ls ~/glyd/scripts/bin/clang-format
ls ~/glyd/scripts/bin/ruff
```

### "Format-on-save too slow"

Increase timeout in `~/.config/nvim/lua/plugins/formatting.lua`:

```lua
format_on_save = function(bufnr)
  return {
    timeout_ms = 1000,  -- Increase from 500
    lsp_fallback = true,
  }
end,
```

### "Wrong formatter being used"

**Check active formatter:**

```vim
:ConformInfo
```

**Force a specific formatter:**

```vim
:lua require('conform').format({ formatters = { 'prettier' } })
```

## Command-Line Usage

All formatters are available in your shell too:

```bash
# Format Python
ruff format file.py
isort file.py

# Format C++
clang-format -i file.cc

# Format JavaScript/JSON/YAML
prettier --write file.js

# Format Shell
shfmt -i 2 -ci -s -w script.sh

# Lint Python
ruff check file.py

# Lint Shell
shellcheck script.sh

# Lint Terraform
tflint

# Lint YAML
yamllint file.yaml
```

### Glyd Repository

When in `~/glyd`, use the repo's scripts:

```bash
# Use glyd's lint script (runs trunk)
./lint.sh

# Use glyd's trunk directly
./scripts/bin/trunk check

# Format specific file with glyd tools
./scripts/bin/ruff format glyd/etl/extract/script.py
./scripts/bin/clang-format -i glyd/base/time/time.cc
```

## Configuration Files

### Neovim Config Location

```
~/dotfiles/nix-config/config/nvim/
├── init.lua                          # Main config
├── lua/
│   ├── plugins/
│   │   ├── lsp.lua                   # LSP configuration
│   │   ├── formatting.lua            # ⭐ Formatters & linters
│   │   ├── nvim-treesitter.lua       # Syntax highlighting
│   │   └── ...
│   └── config/
│       └── lazy.lua                  # Plugin manager
```

### Nix Config Location

```
~/dotfiles/nix-config/
├── flake.nix                         # Flake definition
├── hosts/
│   └── work/
│       └── home.nix                  # ⭐ Work packages & config
└── modules/
    └── home/
        └── common.nix                # Common packages
```

### Glyd Config Files (Auto-detected)

```
~/glyd/
├── .clang-format                     # C++ formatting rules
├── .clang-tidy                       # C++ linting rules
├── .ruff.toml                        # Python linting rules
├── .prettierrc.js                    # JS/TS/YAML formatting
├── .shellcheckrc                     # Shell linting rules
├── .editorconfig                     # Editor config (tab sizes)
├── .trunk/trunk.yaml                 # Trunk configuration
└── scripts/bin/
    ├── clang-format                  # Glyd's clang-format wrapper
    └── ruff                          # Glyd's ruff wrapper
```

## Tips & Tricks

### Quick Format Current File

```vim
<leader>f
```

### Format on Save Toggle

```vim
:lua vim.g.disable_autoformat = not vim.g.disable_autoformat
```

### Format Selection (Visual Mode)

```vim
# Select lines in visual mode (V)
<leader>f
```

### Run Glyd's CI Linters Locally

```bash
cd ~/glyd
./lint.sh                      # Lint changed files
./lint.sh --all                # Lint entire repo
./lint.sh path/to/file.cc      # Lint specific file
```

### See All Available Formatters

```vim
:lua print(vim.inspect(require('conform').list_all_formatters()))
```

### Mason Package Manager

```vim
:Mason                         # Open Mason UI
```

Install additional LSPs/formatters/linters through Mason if needed.

## Comparison: Neovim vs VSCode (Glyd)

| Feature                   | VSCode           | Neovim (This Setup)     |
| ------------------------- | ---------------- | ----------------------- |
| **Default formatter**     | Trunk extension  | conform.nvim            |
| **C++ formatting**        | clangd           | clangd + clang-format   |
| **C++ linting**           | clang-tidy       | clang-tidy (via clangd) |
| **Python formatting**     | Trunk (ruff)     | ruff + isort            |
| **Python linting**        | Trunk (ruff)     | ruff                    |
| **JS/TS formatting**      | Trunk (prettier) | prettier                |
| **Shell formatting**      | Trunk (shfmt)    | shfmt                   |
| **Format on save**        | ✅               | ✅                      |
| **Uses glyd binaries**    | ✅               | ✅                      |
| **Respects glyd configs** | ✅               | ✅                      |
| **Works outside glyd**    | Limited          | ✅ Full support         |
| **Inline diagnostics**    | ✅               | ✅                      |
| **Auto-fix**              | ✅ (on save)     | ✅ (on save)            |

## Summary

✅ **Works everywhere**: LSP + formatters + linters for all file types  
✅ **Glyd-aware**: Automatically uses glyd's tools when in `/home/gustavo/glyd/`  
✅ **Matches CI**: Uses same configs and binaries as glyd's CI  
✅ **Declarative**: All tools installed via Nix  
✅ **Fast**: Async formatting, cached linting  
✅ **Smart exclusions**: Respects global and glyd-specific patterns

This nvim setup now matches VSCode functionality while being portable and working universally!
