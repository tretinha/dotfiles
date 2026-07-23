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

    # Fall back to building from source if a substituter is missing a path.
    fallback = true;

    # Binary caches for faster builds
    substituters = [
      "https://cache.nixos.org"
      "https://cache.lix.systems"
      "https://nix-community.cachix.org"
      "https://niri.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964="
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
      set -ga terminal-overrides ",foot:RGB"

      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      set -g status-position top
      set -g status-style bg=#111111,fg=#f0f0f0
      set -g status-left ""
      set -g status-right ""
      set -g status-justify left

      setw -g window-status-separator ""
      setw -g window-status-format " #I #W "
      setw -g window-status-current-format " #I #W "
      setw -g window-status-style fg=#888888
      setw -g window-status-current-style bg=#2C4B91,fg=#ffffff
      setw -g window-status-activity-style fg=#e6c547

      set -g pane-border-style fg=#383838
      set -g pane-active-border-style fg=#2C4B91
      set -g message-style bg=#2C4B91,fg=#ffffff
      set -g message-command-style bg=#2C4B91,fg=#ffffff
      setw -g mode-style bg=#2C4B91,fg=#ffffff
      setw -g clock-mode-colour "#2C4B91"
    '';
  };
}
