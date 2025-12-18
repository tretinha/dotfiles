{
  config,
  pkgs,
  lib,
  ...
}:

let
  nix_config_path = "${config.home.homeDirectory}/dotfiles/nix-config";
  nix_xdg_config = "${nix_config_path}/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  imports = [
    ../../modules/home/common.nix
  ];

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  home.packages = with pkgs; [
    opencode
    xournalpp
    _1password-gui
    caffeine-ng
    atuin
    wl-clipboard
    
    # labwc window manager and utilities
    labwc
    wlr-randr  # Display configuration tool for wlroots (CLI)
    wdisplays  # Display configuration GUI (like arandr)
    
    # xdg-desktop-portal-wlr for screen sharing (Ubuntu has base portal)
    xdg-desktop-portal-wlr
    
    # Wayland utilities (some may be in Ubuntu, but nix versions won't conflict)
    waybar      # Status bar
    wofi        # Application launcher
    mako        # Notification daemon
    swaybg      # Background setter
    
    # Wayland screenshot tools (replacing flameshot)
    grim        # Screenshot utility
    slurp       # Region selector
    swappy      # Screenshot editor (optional, like flameshot's editor)
  ];

  programs.bash = {
    sessionVariables = {
      EDITOR = "nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$HOME/.cache/glyd/cas/f686e1d39682f5ada2b165e737eb136521f5a519/bin:$PATH";
    };

    shellAliases = {
      infra = "cd ~/glyd/glyd/infra";
    };

    # Append work-specific setup after common config
    initExtra = lib.mkAfter ''
      source /home/gustavo/glyd/glyd/dev/env/login-setup.sh 2>/dev/null || true
      source ${nix_config_path}/config/scripts/gl_k_completion.bash 2>/dev/null || true

      # Atuin
      . "$HOME/.atuin/bin/env" 2>/dev/null || true
      [[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
      eval "$(atuin init bash 2>/dev/null)" || true
    '';
  };

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

    "opencode" = {
      source = create_symlink "${nix_xdg_config}/opencode";
      recursive = true;
    };
    
    "labwc" = {
      source = create_symlink "${nix_xdg_config}/labwc";
      recursive = true;
    };
    
    "waybar" = {
      source = create_symlink "${nix_xdg_config}/waybar";
      recursive = true;
    };
    
    # Portal configuration for screen sharing
    "xdg-desktop-portal/portals.conf".text = ''
      [preferred]
      default=gtk
      org.freedesktop.impl.portal.ScreenCast=wlr
      org.freedesktop.impl.portal.Screenshot=wlr
    '';
  };

  home.file = {
    "Documents/Invoices/invoice.py" = {
      source = ../../config/scripts/invoice.py;
      executable = true;
    };

    "Documents/Invoices/secrets.json" = {
      source = ../../config/scripts/secrets.json;
    };
  };

  systemd.user.services = {
    dotfiles-sync = {
      Unit = {
        Description = "Automated dotfiles git sync";
      };
      Service = {
        Type = "oneshot";
        Environment = [
          "PATH=${config.home.profileDirectory}/bin:/usr/bin:/bin"
          "SSH_AUTH_SOCK=${config.home.homeDirectory}/.1password/agent.sock"
        ];
        ExecStart = "${nix_config_path}/config/scripts/dotfiles_sync";
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
        Environment = "PATH=${config.home.profileDirectory}/bin:/usr/bin:/bin";
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
