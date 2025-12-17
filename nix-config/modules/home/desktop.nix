{ config, pkgs, ... }:

{
  # Desktop environment packages and configs
  # Only import this on systems with a GUI
  
  # Desktop environment - only universal GUI utilities
  # Window managers and work-specific apps moved to host configs
  home.packages = with pkgs; [
    # Screenshot utilities (used on both systems)
    scrot
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
