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
    networkmanager_dmenu
    dejavu_fonts
    liberation_ttf
    hicolor-icon-theme
    librsvg
    xwayland
  ];

  xdg.desktopEntries."4coder" = {
    name = "4coder";
    exec = "${config.home.homeDirectory}/4cc/build/4ed";
    terminal = false;
    categories = [ "Development" "TextEditor" ];
  };

  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Liberation Sans" ];
    serif = [ "Liberation Serif" ];
    monospace = [ "Liberation Mono" ];
  };

  gtk = {
    enable = true;
    theme = {
      name = "OneStepBack";
      package = pkgs.onestepback;
    };
    font = {
      name = "Liberation Sans";
      size = 10;
    };
  };

  xdg.configFile."systemd/user/blueman-manager.service".source =
    "${pkgs.blueman}/share/systemd/user/blueman-manager.service";

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

    "networkmanager-dmenu" = {
      source = create_symlink "${nix_xdg_config}/networkmanager-dmenu";
      recursive = true;
    };
  };
}
