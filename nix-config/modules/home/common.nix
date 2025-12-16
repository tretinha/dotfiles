{ config, pkgs, lib, ... }:

{
  # Common settings for ALL systems (NixOS and non-NixOS)
  
  home.stateVersion = "25.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Nix package and settings
  nix.package = pkgs.lix;
  
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Common packages for all systems
  home.packages = with pkgs; [
    # Nix tooling
    nixfmt-rfc-style
    home-manager
    
    # Core utilities
    htop
    fzf
    ripgrep
    git
    wget
    sops
  ];

  # Git configuration (common across all systems)
  programs.git = {
    enable = true;
    # Hosts can override these:
    # userName = "Gustavo";
    # userEmail = "your.email@example.com";
  };

  # Bash configuration (common baseline)
  programs.bash = {
    enable = true;
    historyControl = [ "ignoreboth" ];
    historySize = -1;
    historyFileSize = -1;
    
    shellOptions = [
      "histappend"
      "checkwinsize"
    ];
    
    shellAliases = {
      # Common aliases
      ll = "ls -alF";
      la = "ls -A";
      l = "ls -CF";
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
    };
    
    initExtra = lib.mkBefore ''
      # Lesspipe
      [ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
      
      # Bash completion
      if ! shopt -oq posix; then
        if [ -f /usr/share/bash-completion/bash_completion ]; then
          . /usr/share/bash-completion/bash_completion
        elif [ -f /etc/bash_completion ]; then
          . /etc/bash_completion
        fi
      fi
    '';
  };

  # FZF
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
}
