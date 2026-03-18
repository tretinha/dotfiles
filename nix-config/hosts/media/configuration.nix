{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "media";
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.hosts = {
    "127.0.0.1" = ["localhost"];
    "::1" = ["localhost"];
    "127.0.0.2" = ["media"];
    "192.168.229.186" = ["gaming"];
  };

  users.users = {
    gustavo = {
      isNormalUser = true;
      description = "gustavo";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "render"
        "input"
        "audio"
      ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICN48O4aAcAFwLiVzbULL49081Zt8RSM2oU/3yk+VsQY ggc@Mac"
      ];
    };
  };

  services.openssh.enable = true;
  services.plex = {
    enable = true;
    openFirewall = true;
    dataDir = "/var/lib/plex";
  };
  systemd.services.plex.serviceConfig = {
    ReadWritePaths = [ "/mnt/media" ];
  };
  system.stateVersion = "25.11";
}
