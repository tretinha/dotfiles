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

  # Sway and companion tools; the config itself lives in config/sway and is
  # symlinked out-of-store so it can be edited and reloaded ($mod+Shift+c)
  # without a home-manager rebuild.
  home.packages = with pkgs; [
    sway
    swaybg
    swaylock
    swayidle
    mako
    libnotify # notify-send, used by sway-idle and sway-screenshot
    fuzzel # sircmpwn's launcher ($mod+d)
    grim
    slurp
    wl-clipboard
    playerctl
    brightnessctl
    jq # used by sway-monitor-toggle
    networkmanagerapplet
    dejavu_fonts # sircmpwn's font (sway, swaybar, mako)
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
  };
}
