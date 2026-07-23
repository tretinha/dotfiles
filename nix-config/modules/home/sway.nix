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
  home.packages = with pkgs; [
    sway
    swaybg
    foot
    atkinson-hyperlegible-mono
    swaylock
    swayidle
    mako
    libnotify
    fuzzel
    grim
    slurp
    wl-clipboard
    playerctl
    brightnessctl
    jq
    networkmanagerapplet
    dejavu_fonts
    hicolor-icon-theme
    librsvg
    xwayland
  ];

  xdg.configFile = {
    "sway" = {
      source = create_symlink "${nix_xdg_config}/sway";
      recursive = true;
    };

    "mako" = {
      source = create_symlink "${nix_xdg_config}/mako";
      recursive = true;
    };

    "fuzzel" = {
      source = create_symlink "${nix_xdg_config}/fuzzel";
      recursive = true;
    };

    "foot" = {
      source = create_symlink "${nix_xdg_config}/foot";
      recursive = true;
    };
  };
}
