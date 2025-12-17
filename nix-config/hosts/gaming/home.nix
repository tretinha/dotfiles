{ config, pkgs, ... }:

let
  nix_xdg_config = "${config.home.homeDirectory}/dotfiles/nix-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  # Gaming PC configuration (NixOS system)

  imports = [
    ../../modules/home/common.nix
  ];

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  home.packages = with pkgs; [
    discord
  ];

  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim/";
      recursive = true;
    };
  };
}
