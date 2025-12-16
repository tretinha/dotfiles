{ config, pkgs, lib, ... }:

let
  nix_config_path = "${config.home.homeDirectory}/dotfiles/nix-config";
  nix_xdg_config = "${nix_config_path}/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  # Work-specific configuration for Ubuntu PC
  
  imports = [
    ../../modules/home/common.nix    # Common settings
    ../../modules/home/desktop.nix   # Desktop environment
  ];

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  # Additional work-specific packages
  home.packages = with pkgs; [
    atuin
  ];

  # Work-specific bash config
  programs.bash = {
    sessionVariables = {
      EDITOR = "/home/gustavo/neovim/nvim-linux-x86_64/bin/nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$HOME/.opencode/bin:$HOME/.cache/glyd/cas/f686e1d39682f5ada2b165e737eb136521f5a519/bin:$PATH";
    };
    
    shellAliases = {
      nvim = "~/neovim/nvim-linux-x86_64/bin/nvim";
      infra = "cd ~/glyd/glyd/infra";
    };
    
    # Append work-specific setup after common config
    initExtra = lib.mkAfter ''
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
      
      # Work-specific setup
      source /home/gustavo/glyd/glyd/dev/env/login-setup.sh 2>/dev/null || true
      source ~/gl_k_completion.bash 2>/dev/null || true
      
      # Atuin
      . "$HOME/.atuin/bin/env" 2>/dev/null || true
      [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
      eval "$(atuin init bash 2>/dev/null)" || true
    '';
  };

  # Atuin configuration
  programs.atuin = {
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
    
    "Documents/Invoices/invoice.py" = {
      source = ../../config/scripts/invoice.py;
      executable = true;
    };
    
    "Documents/Invoices/secrets.json" = {
      source = ../../config/scripts/secrets.json;
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
    
    invoice-generator = {
      Unit = {
        Description = "Monthly Invoice Generator";
        Requires = "invoice-generator.timer";
      };
      Service = {
        Type = "oneshot";
        WorkingDirectory = "${config.home.homeDirectory}/Documents/Invoices";
        ExecStart = "/usr/bin/env python3 ${config.home.homeDirectory}/Documents/Invoices/invoice.py";
        StandardOutput = "journal";
        StandardError = "journal";
      };
      Install = {
        WantedBy = [ "timers.target" ];
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
    
    invoice-generator = {
      Unit = {
        Description = "Runs invoice-generator on the last day of the month";
      };
      Timer = {
        OnCalendar = "*-*-* 09:51:00";
        AccuracySec = "1min";
        Unit = "invoice-generator.service";
      };
      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
