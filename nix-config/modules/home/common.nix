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

      # Vi mode copy
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'wl-copy'

      # Disable automatic window renaming
      # set-option -g allow-rename off

      # Status bar styling
      # set -g status-position bottom
      # set -g status-style "bg=#FFFFEC,fg=#57864E"

      # Status bar: Match Waybar Blue
      # Using black text (fg) for readability against the light blue
      # set -g status-position bottom
      # set -g status-style "bg=#79D9FF,fg=#000000"

      # Pane Borders: Match Niri Window Borders
      # Active pane = Red (#ff5555)
      # Inactive panes = Waybar Blue (#79D9FF)
      # set -g pane-border-style "fg=#79D9FF"
      # set -g pane-active-border-style "fg=#ff5555"

      # Message text (e.g. prefix prompt)
      # set -g message-style "bg=#79D9FF,fg=#000000"

      flexoki_black="#100f0f"
      flexoki_base_950="#1c1b1a"
      flexoki_base_900="#282726"
      flexoki_base_850="#343331"
      flexoki_base_800="#403e3c"
      flexoki_base_700="#575653"
      flexoki_base_600="#6f6e69"
      flexoki_base_500="#878580"
      flexoki_base_300="#b7b5ac"
      flexoki_base_200="#cecdc3"
      flexoki_base_150="#dad8ce"
      flexoki_base_100="#e6e4d9"
      flexoki_base_50="#f2f0e5"
      flexoki_paper="#fffcf0"

      flexoki_red="#d14d41"
      flexoki_orange="#da702c"
      flexoki_yellow="#d0a215"
      flexoki_green="#879a39"
      flexoki_cyan="#3aa99f"
      flexoki_blue="#4385be"
      flexoki_purple="#8b7ec8"
      flexoki_magenta="#ce5d97"

      flexoki_red_2="#af3029"
      flexoki_orange_2="#bc5215"
      flexoki_yellow_2="#ad8301"
      flexoki_green_2="#66800b"
      flexoki_cyan_2="#24837b"
      flexoki_blue_2="#205ea6"
      flexoki_purple_2="#5e409d"
      flexoki_magenta_2="#a02f6f"

      color_tx_1=$flexoki_black
      color_tx_2=$flexoki_base_600
      color_tx_3=$flexoki_base_300
      color_bg_1=$flexoki_paper
      color_bg_2=$flexoki_base_50
      color_ui_1=$flexoki_base_100
      color_ui_2=$flexoki_base_150
      color_ui_3=$flexoki_base_200

      color_red=$flexoki_red
      color_orange=$flexoki_orange
      color_yellow=$flexoki_yellow
      color_green=$flexoki_green
      color_cyan=$flexoki_cyan
      color_blue=$flexoki_blue
      color_purple=$flexoki_purple
      color_magenta=$flexoki_magenta

      # status
      set -g status-position bottom
      set -g status "on"
      set -g status-bg $color_bg_2
      set -g status-justify "left"
      set -g status-left-length "100"
      set -g status-right-length "100"

      # messages
      set -g message-style "fg=$color_tx_1,bg=$color_bg_2,align=centre"
      set -g message-command-style "fg=$color_tx_1,bg=$color_ui_2,align=centre"

      # panes
      set -g pane-border-style fg=$color_ui_2
      set -g pane-active-border-style fg=$color_blue

      # windows
      setw -g window-status-activity-style fg=$color_tx_1,bg=$color_bg_1,none
      setw -g window-status-separator ""
      setw -g window-status-style fg=$color_tx_1,bg=$color_bg_1,none

      # statusline
      set -g status-left "#{?client_prefix,#[fg=#$color_bg_1#,bg=#$color_red],#[fg=#$color_bg_1#,bg=#$color_green]}  #S "
      set -g status-right "#[fg=#$color_bg_1,bg=#$color_orange]  #{b:pane_current_path} #[fg=#$color_bg_1,bg=#$color_purple]  %Y-%m-%d %H:%M "

      # window-status
      setw -g window-status-format "#[bg=#$color_bg_2,fg=#$color_tx_2] #I  #W "
      setw -g window-status-current-format "#[bg=#$color_bg_1,fg=#$color_tx_1] #I  #W "

      # Modes
      setw -g clock-mode-colour $color_blue
      setw -g mode-style fg=$color_orange,bg=$color_tx_1,bold

      # Make the borders stand out more
      set -g pane-border-lines heavy
    '';
  };
}
