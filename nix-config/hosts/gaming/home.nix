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
  ];

  # Enable niri via home-manager
  programs.niri.enable = true;

  # Fonts
  fonts.fontconfig.enable = true;

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  home.packages = with pkgs; [
    discord

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
