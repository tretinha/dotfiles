{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  # Required for home-manager xdg portals with useUserPackages
  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
    "/share/wayland-sessions"
  ];

  # XDG portals for Wayland (screen sharing, file dialogs, etc.)
  xdg.portal = {
    enable = true;
    wlr.enable = true; # For wlroots-based compositors like niri
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config.common.default = "*";
  };

  # Use latest kernel for best RDNA3 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Kernel parameters for competitive gaming (CS2 + 5800X3D + RX 7900 XTX)
  boot.kernelParams = [
    # AMD GPU - enable all power management features
    "amdgpu.ppfeaturemask=0xffffffff"
    # Disable mitigations for maximum CPU performance
    "mitigations=off"
    # Split lock detection causes stuttering
    "split_lock_detect=off"
    # Disable watchdog for lower latency
    "nowatchdog"
    # AMD CPU - limit C-states to prevent latency spikes
    "processor.max_cstate=1"
    "amd_pstate=active"
    # Prefer performance over power
    "workqueue.power_efficient=0"
    # Disable kernel page table isolation (performance vs security tradeoff)
    "nopti"
    # Transparent hugepages - good for gaming memory access patterns
    "transparent_hugepage=always"
  ];

  # Enable kernel modules for AMD GPU
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "gaming";

  # NetworkManager - ensure WiFi works on boot
  networking.networkmanager = {
    enable = true;
    wifi.powersave = false; # Disable power saving for better latency
  };

  # Ensure NetworkManager starts early and WiFi adapter is up
  systemd.services.NetworkManager-wait-online.enable = false; # Don't wait, speeds up boot

  # Greetd login manager with tuigreet
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # Prevent greetd from showing errors on TTY1
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };

  # AMD GPU - RADV only (best for CS2 on RDNA3)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      # Video acceleration for streaming/recording
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # AMD 5800X3D optimizations
  hardware.cpu.amd.updateMicrocode = true;

  # Enable firmware (important for WiFi adapters!)
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  # AMD P-State driver with performance governor
  powerManagement.cpuFreqGovernor = "performance";

  # CS2/Competitive gaming environment variables
  environment.sessionVariables = {
    # RADV is faster than AMDVLK for CS2 on RDNA3
    AMD_VULKAN_ICD = "RADV";

    # RADV optimizations
    RADV_PERFTEST = "gpl"; # GPL for faster shader compilation
    MESA_SHADER_CACHE_MAX_SIZE = "10G";

    # Disable all vsync/frame limiting at driver level
    vblank_mode = "0";
    __GL_SYNC_TO_VBLANK = "0";

    # SDL - prefer X11 for CS2 (lower latency than Wayland currently)
    SDL_VIDEODRIVER = "x11";

    # Disable compositing hints (game runs exclusive)
    __GL_YIELD = "NOTHING";
  };

  # System fonts - MUST include nerd fonts here for system-wide availability
  fonts = {
    packages = with pkgs; [
      # Nerd fonts for terminal/waybar icons
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.iosevka
      # Standard fonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
      dejavu_fonts
      ubuntu_font_family
      font-awesome
      # Fallback
      freefont_ttf
      roboto
    ];
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "DejaVu Sans Mono"
        ];
        sansSerif = [
          "Noto Sans"
          "DejaVu Sans"
        ];
        serif = [
          "Noto Serif"
          "DejaVu Serif"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Vulkan
    vulkan-tools
    vulkan-loader

    # Monitoring
    mangohud
    radeontop

    # GPU control
    lact
    corectrl

    # Gaming utilities
    gamescope
    protonup-qt

    # Networking
    networkmanagerapplet

    # Wayland/niri essentials (system-level so greetd can find them)
    waybar
    alacritty
    foot
    rofi-wayland
    swayidle
    wl-clipboard
    brightnessctl
    pavucontrol

    # Niri itself at system level
    niri
  ];

  # GameMode - CS2 automatically uses it via Steam integration
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        ioprio = 0;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # Steam - optimized for competitive, no VRR
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    gamescopeSession = {
      enable = true;
      args = [
        "--rt"
        "--expose-wayland"
        "--force-grab-cursor"
        # NO --adaptive-sync (VRR adds latency)
        # NO --hdr-enabled (HDR processing adds latency)
      ];
    };
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  programs.corectrl = {
    enable = true;
  };

  # AMD GPU overdrive (overclocking)
  hardware.amdgpu.overdrive.enable = true;

  # LACT daemon for GPU control
  systemd.services.lactd = {
    description = "LACT GPU control daemon";
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.lact}/bin/lact daemon";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # Increase file limits
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "1048576";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];

  # Polkit for authentication dialogs
  security.polkit.enable = true;

  # Enable gnome-keyring for credential storage
  services.gnome.gnome-keyring.enable = true;

  security.rtkit.enable = true;

  # PipeWire - low latency for footsteps/audio cues
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 32;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 32;
      };
    };
  };
  services.pulseaudio.enable = false;

  # Zram for memory management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.printing.enable = true;

  # D-Bus (required for many services)
  services.dbus.enable = true;

  users.users = {
    gustavo = {
      isNormalUser = true;
      description = "gustavo";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "render"
        "gamemode"
        "input"
        "audio"
      ];
      packages = with pkgs; [
        kdePackages.kate
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN48O4aAcAFwLiVzbULL49081Zt8RSM2oU/3yk+VsQY ggc@Mac"
      ];
    };
  };

  programs.firefox.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "25.11";
}
