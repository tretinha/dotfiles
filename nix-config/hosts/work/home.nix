{
  config,
  pkgs,
  lib,
  inputs,
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
    ../../modules/home/niri.nix
    ./zen-browser.nix
  ];

  # Enable niri via home-manager (standalone, not NixOS)
  programs.niri.enable = true;

  # Work laptop monitor configuration
  programs.niri.settings.outputs = {
    "DP-1" = {
      # Dell U2724DE external monitor
      mode = {
        width = 2560;
        height = 1440;
        refresh = 120.0;
      };
      position = {
        x = 0;
        y = 0;
      };
    };
    "eDP-1" = {
      # Built-in laptop display
      mode = {
        width = 1920;
        height = 1080;
        refresh = 60.002;
      };
      scale = 1.25;
      position = {
        x = 0;
        y = 0;
      };
    };
  };

  # Auto-toggle laptop screen based on external monitor
  programs.niri.settings.spawn-at-startup = [
    { argv = [ "${nix_config_path}/config/scripts/niri-monitor-toggle" ]; }
    { argv = [ "blueman-applet" ]; }
    { argv = [ "1password" ]; }
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };

  # XDG portals for Wayland screen sharing
  # Note: xdg-desktop-portal-wlr is installed via apt for proper systemd integration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gtk" ];
      };
      niri = {
        default = [
          "gnome"
          "gtk"
        ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      };
    };
  };

  fonts.fontconfig.enable = true;
  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  home.packages = with pkgs; [
    opencode
    xournalpp
    _1password-gui
    caffeine-ng
    atuin
    wl-clipboard
    wdisplays
    gnome-tweaks
    pavucontrol
    alacritty
    rofi
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    blueman
    slack
    swayidle
    obsidian
    zoom-us
  ];

  home.sessionVariables = {
    BROWSER = "zen";
    # Wayland environment variables
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    OZONE_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  programs.bash = {
    sessionVariables = {
      EDITOR = "nvim";
      PATH = "$HOME/bin:$HOME/.local/bin:$HOME/.cache/glyd/cas/f686e1d39682f5ada2b165e737eb136521f5a519/bin:$PATH";
      BROWSER = "zen";
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

    "alacritty" = {
      source = create_symlink "${nix_xdg_config}/alacritty";
      recursive = true;
    };
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
