{ config, pkgs, ... }:

let
  nix_xdg_config = "${config.home.homeDirectory}/nix-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  # Gaming PC configuration (NixOS system)
  
  imports = [
    ../../modules/home/common.nix    # Common settings
    ../../modules/home/desktop.nix   # Desktop environment
  ];

  home.username = "gustavo";
  home.homeDirectory = "/home/gustavo";

  # Gaming-specific configs can go here
  
  # Symlink nvim config
  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim/";
      recursive = true;
    };
  };
}
