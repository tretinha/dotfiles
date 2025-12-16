{ config, pkgs, ... }:

{
  # Desktop environment packages and configs
  # Only import this on systems with a GUI
  
  home.packages = with pkgs; [
    # Window manager and desktop
    openbox
    picom
    tint2
    lxqt.lxqt-policykit
    
    # Screenshot and utilities
    xclip
    scrot
    flameshot
    
    # GUI apps
    _1password-gui
  ];

  # Tmux configuration
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    prefix = "C-a";
    
    extraConfig = ''
      set -ga terminal-overrides ",*256col*:Tc"
      
      # Vi mode copy
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -sel clip -i'
      
      # Disable automatic window renaming
      set-option -g allow-rename off
      
      # Status bar styling
      set -g status-position bottom
      set -g status-style "bg=#FFFFEC,fg=#57864E"
    '';
  };
}
