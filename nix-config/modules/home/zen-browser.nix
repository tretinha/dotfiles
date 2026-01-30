{
  config,
  pkgs,
  ...
}:
{
  programs.zen-browser = {
    enable = true;
    profiles."default" = {
      containersForce = true;
      containers = {
        "Work" = {
          color = "green";
          icon = "briefcase";
          id = 2;
        };
      };
      spaces =
        let
          containers = config.programs.zen-browser.profiles."default".containers;
        in
        {
          "Work" = {
            id = "61890944-4b85-438a-a4fc-c044f71bc9e7";
            container = containers."Work".id;
            position = 2000;
          };
        };
      # extensions.packages = [
      #   pkgs.firefox-addons.ublock-origin
      #   pkgs.firefox-addons.onepassword-password-manager
      #   # glean extension had to be manually installed since apparently it's
      #   # not available in the nur repo
      # ];
    };
  };
}
