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
  terminal = "alacritty";
  menu = "rofi -show drun -show-icons";
  lockscreen = "hyprlock";
in
{
  imports = [
    ../../modules/home/common.nix
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
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
    gnome-tweaks
    pavucontrol
    alacritty
    rofi
    hyprlock
    waybar
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    blueman
  ];

  programs.waybar = {
    enable = true;
    settings = {
      main = {
        layer = "top";
        position = "top";
        height = 26;

        modules-left = [
          "disk"
          "temperature"
          "memory"
          "cpu"
        ];

        modules-center = [
          "niri/workspaces"
        ];

        modules-right = [
          "tray"
          "network"
          "wireplumber"
          "battery"
          "clock"
        ];

        battery = {
          interval = 60;
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          max-length = 25;
        };

        clock = {
          format = " {:%A, %d %b %Y %H:%M}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          calendar-weeks-pos = "right";
          today-format = "<span color='#ff6699'><b><u>{}</u></b></span>";
          format-calendar = "<span color='#ecc6d9'><b>{}</b></span>";
          format-calendar-weeks = "<span color='#99ffdd'><b>W{:%V}</b></span>";
          format-calendar-weekdays = "<span color='#ffcc66'><b>{}</b></span>";
          on-scroll = {
            calendar = 1;
          };
        };

        cpu = {
          interval = 5;
          format = " {usage}%";
          states = {
            warning = 70;
            critical = 90;
          };
        };

        disk = {
          interval = 30;
          format = " {percentage_used}%";
          path = "/";
        };

        memory = {
          interval = 5;
          format = " {}%";
          states = {
            warning = 70;
            critical = 90;
          };
        };

        network = {
          format = "";
          format-ethernet = "󰈀 ";
          format-wifi = "{icon}";
          format-disconnected = "󰲛 ";
          format-icons = [
            "󰤯 "
            "󰤟 "
            "󰤢 "
            "󰤥 "
            "󰤨 "
          ];
          tooltip-format-wifi = "{essid}({signalStrength}%) {ipaddr}";
          tooltip-format-ethernet = "{ifname} {ipaddr}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "nm-connection-editor";
        };

        "niri/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          format-icons = {
            "active" = "";
            "default" = "";
          };
          icon-size = 10;
        };

        temperature = {
          hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          format-critical = " {temperatureC}°C";
          format = " {temperatureC}°C";
          interval = 2;
        };

        tray = {
          icon-size = 16;
          spacing = 16;
        };

        wireplumber = {
          "format" = " {volume}%";
          "max-volume" = 100;
          "scroll-step" = 5;
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
        };

        # my custom modules
        # "custom/power" = {
        #   format = "";
        #   tooltip = false;
        #   on-click = "exec ${./scripts/power-menu.sh}";
        # };
      };
    };
  };

  programs.niri = {
    enable = true;
    settings = {
      prefer-no-csd = true;
      hotkey-overlay = {
        skip-at-startup = true;
      };

      environment = {
        "NIXOS_OZONE_WL" = "1";
      };
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            # variant = "intl";
          };
        };
        # Focus windows and outputs automatically when moving the mouse into them.
        # Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };

      # outputs defined directly per host
      outputs = {};

      layout = {
        gaps = 8;
        default-column-width = {};
        center-focused-column = "never";
        background-color = "transparent";
        preset-column-widths = [
          {proportion = 1. / 3.;}
          {proportion = 1. / 2.;}
          {proportion = 2. / 3.;}
        ];
        default-column-width = {
          proportion = 1. / 2.;
        };
        focus-ring = {
          width = 4;
        };
        # border = {
        #   enable = false;
        # };
        shadow = {
          enable = false;
        };
        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };
      };

      animations = {
        enable = true;
      };

      window-rules = [
        {
          # do not draw solid background when drawing a border this is
          # required for applications with transparent backgrounds
          draw-border-with-background = false;
        }
        {
          # block certain windows from showing up when sharing screen
          matches = [
            {app-id = "1Password";}
          ];
          block-out-from = "screencast";
        }
        {
          # show a border in windows that are currently being shared
          matches = [
            {
              is-window-cast-target = true;
            }
          ];
          focus-ring = {
            active.color = "#f38ba8";
            inactive.color = "#f38ba8";
          };
          border = {
            enable = true;
            inactive.color = "#f38ba8";
          };
          tab-indicator = {
            active.color = "#f38ba8";
            inactive.color = "#7d0d2d";
          };
        }
      ];

      cursor = {
        theme = "default";
        size = 24;
      };

      spawn-at-startup = [
        {argv = ["waybar"];}
        {argv = ["1Password"];}
      ];

      binds = with config.lib.niri.actions; let
        brightnessclt = "${pkgs.brightnessctl}/bin/brightnessctl";
      in {
        # show a list of important hotkeys
        "Mod+Shift+Slash".action = show-hotkey-overlay;

        # main binds
        "Mod+Return" = {
          action = spawn "${terminal}";
          hotkey-overlay.title = "Open a Terminal: ${terminal}";
        };
        "Mod+Shift+E" = {
          action = quit;
          hotkey-overlay.title = "Exit niri";
        };
        "Mod+D" = {
          action = spawn-sh "${menu}";
          hotkey-overlay.title = "Run an Application: rofi";
        };
        "Ctrl+Alt+L" = {
          action = spawn "${lockscreen}";
          hotkey-overlay.title = "Lock the Screen: hyprlock";
        };
        "Mod+Shift+P" = {
          action = power-off-monitors;
          hotkey-overlay.title = "Turn off monitors";
        };

        # window management
        "Mod+O" = {
          repeat = false;
          action = toggle-overview;
        };

        "Mod+Shift+Q" = {
          action = close-window;
          repeat = false;
        };

        # Consume one window from the right to the bottom of the focused column.
        "Mod+Comma".action = consume-window-into-column;
        # Expel the bottom window from the focused column to the right.
        "Mod+Period".action = expel-window-from-column;
        # The following binds move the focused window in and out of a column.
        # If the window is alone, they will consume it into the nearby column to the side.
        # If the window is already in a column, they will expel it out.
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;

        # fullscreen
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+Ctrl+F".action = expand-column-to-available-width;

        # resizing
        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";
        # finer height adjustments when in column with other windows.
        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        # column
        "Mod+C".action = center-column;
        "Mod+Ctrl+C".action = center-visible-columns;

        "Mod+V".action = toggle-window-floating;
        "Mod+W".action = toggle-column-tabbed-display;

        # movement actions
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-or-workspace-down;
        "Mod+K".action = focus-window-or-workspace-up;
        "Mod+L".action = focus-column-right;

        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-window-down-or-to-workspace-down;
        "Mod+Shift+K".action = move-window-up-or-to-workspace-up;
        "Mod+Shift+L".action = move-column-right;

        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+J".action = focus-monitor-down;
        "Mod+Ctrl+K".action = focus-monitor-up;
        "Mod+Ctrl+L".action = focus-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

        "Mod+WheelScrollDown" = {
          action = focus-workspace-down;
          cooldown-ms = 150;
        };
        "Mod+WheelScrollUp" = {
          action = focus-workspace-up;
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollDown" = {
          action = move-column-to-workspace-down;
          cooldown-ms = 150;
        };
        "Mod+Ctrl+WheelScrollUp" = {
          action = move-column-to-workspace-up;
          cooldown-ms = 150;
        };

        # multimedia keys
        "XF86AudioRaiseVolume" = {
          action = spawn-sh "pactl set-volume @DEFAULT_AUDIO_SINK@ 0.1+";
          allow-when-locked = true;
        };
        "XF86AudioLowerVolume" = {
          action = spawn-sh "pactl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          allow-when-locked = true;
        };
        "XF86AudioMute" = {
          action = spawn-sh "pactl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          allow-when-locked = true;
        };
        "XF86AudioMicMute" = {
          action = spawn-sh "pactl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          allow-when-locked = true;
        };
        "XF86MonBrightnessUp" = {
          action = spawn "${brightnessclt}" "--class=backlight" "set" "+10%";
          allow-when-locked = true;
        };
        "XF86MonBrightnessDown" = {
          action = spawn "${brightnessclt}" "--class=backlight" "set" "10%-";
          allow-when-locked = true;
        };

        # screenshot
        "Print".action.screenshot = [];
        "Ctrl+Print".action.screenshot-screen = [];
        "Alt+Print".action.screenshot-window = [];

        # workspaces
        "Mod+1".action = focus-workspace 1;
        "Mod+2".action = focus-workspace 2;
        "Mod+3".action = focus-workspace 3;
        "Mod+4".action = focus-workspace 4;
        "Mod+5".action = focus-workspace 5;
        "Mod+6".action = focus-workspace 6;
        "Mod+7".action = focus-workspace 7;
        "Mod+8".action = focus-workspace 8;
        "Mod+9".action = focus-workspace 9;

        "Mod+Ctrl+1".action = move-column-to-index 1;
        "Mod+Ctrl+2".action = move-column-to-index 2;
        "Mod+Ctrl+3".action = move-column-to-index 3;
        "Mod+Ctrl+4".action = move-column-to-index 4;
        "Mod+Ctrl+5".action = move-column-to-index 5;
        "Mod+Ctrl+6".action = move-column-to-index 6;
        "Mod+Ctrl+7".action = move-column-to-index 7;
        "Mod+Ctrl+8".action = move-column-to-index 8;
        "Mod+Ctrl+9".action = move-column-to-index 9;

        "Mod+Tab".action = focus-workspace-previous;
      };
    };
  };

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
