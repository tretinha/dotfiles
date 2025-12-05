{ config, pkgs, ... }:

let
  nix_xdg_config = "${config.home.homeDirectory}/nix-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  home.stateVersion = "25.05";

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  programs.git.enable = true;

  programs.bash = {
    enable = true;
  };

  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim/";
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    nixfmt-rfc-style
  ];
}
