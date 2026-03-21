{ config, pkgs, inputs, ... }:

let
  nix_xdg_config = "${config.home.homeDirectory}/dotfiles/nix-config/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
in
{
  imports = [
    ../../modules/home/common.nix
  ];

  programs.bash = {
    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "zen";
    };
  };

  home.username = "gustavo";
  home.homeDirectory = "/Users/gustavo";
  home.packages = with pkgs; [
    alacritty
    whatsapp-for-mac
  ];

  # Symlink configurations
  xdg.configFile = {
    "nvim" = {
      source = create_symlink "${nix_xdg_config}/nvim";
      recursive = true;
    };

    "alacritty" = {
      source = create_symlink "${nix_xdg_config}/alacritty";
      recursive = true;
    };
  };

  programs.git = {
    settings = {
      user = {
        name  = "tretinha";
        email = "gustavo@tretinha.com";
      };
    };
  };
}
