{ config, pkgs, ... }:

let
  nix_config_path = "${config.home.homeDirectory}/dotfiles/nix-config";
  nix_xdg_config = "${nix_config_path}/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  home.stateVersion = "25.05";

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  # Packages to install
  home.packages = with pkgs; [
    # Nix tooling
    nixfmt-rfc-style
    home-manager
    
    # System utilities
    htop
    fzf
    ripgrep
    atuin
    
    # Window manager and desktop environment
    openbox
    picom
    tint2
    lxqt.lxqt-policykit
    xclip
    scrot
    flameshot
    
    # Terminal and shell
    tmux
    
    # Development tools
    git
    
    # Misc
    _1password-gui
  ];

  # Git configuration
  programs.git = {
    enable = true;
    # Add your git configuration here
    # userName = "Your Name";
    # userEmail = "your.email@example.com";
  };

  # Bash configuration
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" ];
    historySize = -1;
    historyFileSize = -1;
    
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];
    
    sessionVariables = {
      EDITOR = "/home/gustavo/neovim/nvim-linux-x86_64/bin/nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.cache/glyd/cas/f686e1d39682f5ada2b165e737eb136521f5a519/bin:$PATH";
    };
    
    shellAliases = {
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      nvim = "~/neovim/nvim-linux-x86_64/bin/nvim";
      infra = "cd ~/glyd/glyd/infra";
    };
    
    initExtra = ''
      # Lesspipe
      [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
      
      # Colored prompt
      if [ "$TERM" = "xterm-color" ] || [ "$TERM" = "*-256color" ]; then
          PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      else
          PS1='\u@\h:\w\$ '
      fi
      
      # Xterm title
      case "$TERM" in
      xterm*|rxvt*)
          PS1="\[\e]0;\u@\h: \w\a\]$PS1"
          ;;
      esac
      
      # Bash completion
      if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      fi
      
      # Work-specific setup
      source /home/gustavo/glyd/glyd/dev/env/login-setup.sh 2>/dev/null || true
      source ~/gl_k_completion.bash 2>/dev/null || true
      
      # FZF
      [ -f ~/.fzf.bash ] && source ~/.fzf.bash
      
      # Atuin
      . "$HOME/.atuin/bin/env" 2>/dev/null || true
      [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
      eval "$(atuin init bash 2>/dev/null)" || true
    '';
  };

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    prefix = "C-a";
    
    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      
      # Vi mode copy
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -sel clip -i'
      
      # Disable automatic window renaming
      set-option -g allow-rename off
      
      # Status bar styling
      set -g status-position bottom
      set -g status-style "bg=#FFFFEC,fg=#57864E"
    '';
  };

  # Atuin configuration
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  # FZF configuration
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Symlink configurations
  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim";
      recursive = true;
    };
    
    "openbox" = {
      source = create_symlink "${nix_xdg_config}/openbox";
      recursive = true;
    };
    
    "tint2" = {
      source = create_symlink "${nix_xdg_config}/tint2";
      recursive = true;
    };
  };

  # Home files
  home.file = {
    ".themes/rio/openbox-3/themerc" = {
      source = create_symlink "${nix_xdg_config}/themes/rio/openbox-3/themerc";
    };
    
    "gl_k_completion.bash" = {
      source = ../../config/scripts/gl_k_completion.bash;
    };
    
    "dotfiles_sync" = {
      source = ../../config/scripts/dotfiles_sync;
      executable = true;
    };
  };

  # Systemd user services
  systemd.user.services = {
    dotfiles-sync = {
      Unit = {
        Description = "Automated dotfiles git sync";
      };
      Service = {
        Type = "oneshot";
        Environment = "PATH=/usr/bin:${config.home.homeDirectory}";
        ExecStart = "${config.home.homeDirectory}/dotfiles_sync";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };

  systemd.user.timers = {
    dotfiles-sync = {
      Unit = {
        Description = "Timer for automated dotfiles sync";
      };
      Timer = {
        OnCalendar = "hourly";
        Persistent = true;
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix package and settings
  nix.package = pkgs.lix;
  
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
