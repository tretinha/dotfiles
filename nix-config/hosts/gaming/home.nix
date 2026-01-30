{ config, pkgs, ... }:

let
  nix_xdg_config = "${config.home.homeDirectory}/dotfiles/nix-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  # Gaming PC configuration (NixOS system)

  imports = [
    ../../modules/home/common.nix
    ../../modules/home/niri.nix
    ../../modules/home/zen-browser.nix
  ];

  # Enable niri via home-manager
  programs.niri.enable = true;

  programs.niri.settings = {
    outputs = {
      "HDMI-A-1" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 120.000;
        };
        scale = 1;
      };
    };
  };

  programs.bash = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "zen";
    };

    shellAliases = {
      apogea = "gamescope -f -W 2560 -H 1440 -w 2560 -h 1440 --force-grab-cursor --backend sdl -- steam steam://rungameid/2796220";
      cs = "gamescope -f -W 2561 -H 1440 -w 2560 -h 1440 --force-grab-cursor --backend sdl -- steam steam://rungameid/730";
    };
  };

  # Fonts
  fonts.fontconfig.enable = true;

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  home.packages = with pkgs; [
    # Fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
    liberation_ttf

    # niri/Wayland dependencies
    alacritty
    rofi
    swayidle
    wl-clipboard
    font-awesome
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka
    nerd-fonts.zed-mono
    pavucontrol
    brightnessctl

    # Networking GUI
    networkmanagerapplet
  ];

  home.sessionVariables = {
    BROWSER = "zen";
  };

  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim/";
      recursive = true;
    };

    "alacritty" = {
      source = create_symlink "${nix_xdg_config}/alacritty";
      recursive = true;
    };
  };
}
