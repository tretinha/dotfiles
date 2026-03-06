{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Common settings for ALL systems (NixOS and non-NixOS)
  home.stateVersion = "25.11";
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

  home.packages = with pkgs; [
    nixfmt
    home-manager
    htop
    fzf
    ripgrep
    git
    git-lfs
    wget
    sops
    neovim
    go
    terraform
    jq
    yq
    nodejs
    unzip
    tree
    btop
  ];

  programs.git = {
    enable = true;
  };

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

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    prefix = "C-a";

    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"

      # Vi mode copy
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      # Disable automatic window renaming
      set-option -g allow-rename off

      # Status bar styling
      # set -g status-position bottom
      # set -g status-style "bg=#FFFFEC,fg=#57864E"

      # Status bar: Match Waybar Blue
      # Using black text (fg) for readability against the light blue
      set -g status-position bottom
      set -g status-style "bg=#79D9FF,fg=#000000"

      # Pane Borders: Match Niri Window Borders
      # Active pane = Red (#ff5555)
      # Inactive panes = Waybar Blue (#79D9FF)
      set -g pane-border-lines heavy
      set -g pane-border-style "fg=#79D9FF"
      set -g pane-active-border-style "fg=#ff5555"

      # Message text (e.g. prefix prompt)
      set -g message-style "bg=#79D9FF,fg=#000000"
    '';
  };
}
