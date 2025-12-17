{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Common settings for ALL systems (NixOS and non-NixOS)

  home.stateVersion = "25.11";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use regular Nix package from nixpkgs
  # (This system already runs Lix 2.94.0, this is just for nix.conf generation)
  nix.package = lib.mkForce pkgs.nix;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://cache.lix.systems"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Common packages for all systems
  home.packages = with pkgs; [
    # Nix tooling
    nixfmt-rfc-style
    home-manager
    statix # Nix linter
    deadnix # Dead code detector for Nix

    htop
    fzf
    ripgrep
    git
    wget
    sops

    neovim
    atuin

    # === Formatters (work everywhere) ===
    # C/C++
    clang-tools # Includes clang-format

    # Python
    ruff # Fast Python linter & formatter
    black # Python formatter (backup/alternative)
    isort # Python import sorter

    # JavaScript/TypeScript/Web
    nodePackages.prettier # JS/TS/JSON/YAML/Markdown formatter
    nodePackages.eslint_d # Fast ESLint daemon for linting

    # Shell
    shfmt # Shell script formatter
    shellcheck # Shell script linter

    # Go
    go # Includes gofmt
    golangci-lint # Go linter

    # Terraform/Infrastructure
    terraform # Includes terraform fmt
    tflint # Terraform linter

    # Bazel/Starlark
    buildifier # Bazel BUILD file formatter

    # YAML
    yamllint # YAML linter

    # Docker
    hadolint # Dockerfile linter

    # CMake
    cmake-format # CMake file formatter

    # Markdown
    marksman # Markdown LSP

    # === Language Servers (LSPs) ===
    # Note: Some are installed via Mason in nvim, these are system fallbacks

    # Bash/Shell LSP
    nodePackages.bash-language-server

    # JSON LSP
    nodePackages.vscode-langservers-extracted # Includes jsonls, html, css

    # YAML LSP
    yaml-language-server

    # Terraform LSP
    terraform-ls

    # Docker LSP
    nodePackages.dockerfile-language-server-nodejs

    # === Additional Development Tools ===
    jq # JSON processor (useful for development)
    yq # YAML processor

    opencode

    # === Mason Dependencies ===
    # Required for Mason to install LSP servers and tools
    nodejs # npm for Node.js-based LSP servers
    unzip # For downloading and extracting binaries
    go # For Go-based LSP servers
  ];

  # Git configuration (common across all systems)
  programs.git = {
    enable = true;
    # Hosts can override these:
    # userName = "Gustavo";
    # userEmail = "your.email@example.com";
  };

  # Bash configuration (common baseline)
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" ];
    historySize = -1;
    historyFileSize = -1;

    shellOptions = [
      "histappend"
      "checkwinsize"
    ];

    shellAliases = {
      # Common aliases
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
    };

    initExtra = lib.mkBefore ''
      # Lesspipe
      [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

      # Bash completion
      if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      fi
    '';
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
