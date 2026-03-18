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
    "127.0.0.1" = [ "localhost" ];
    "::1" = [ "localhost" ];
    "127.0.0.2" = [ "media" ];
    "192.168.229.186" = [ "gaming" ];
  };

  networking.firewall.allowedTCPPorts = [ 443 ];

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
    nginx = {
      extraGroups = [
        "acme"
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

  age.secrets = {
    "cloudflare" = {
      file = ../../secrets/cloudflare.age;
      owner = "acme";
      group = "nginx";
    };
    "cloudflare-raw" = {
      file = ../../secrets/cloudflare-raw.age;
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "gustavo@tretinha.com";
    certs."tretinha.com" = {
      domain = "tretinha.com";
      extraDomainNames = [ "*.tretinha.com" ];
      dnsProvider = "cloudflare";
      environmentFile = config.age.secrets.cloudflare.path;
      group = "nginx";
      # Cloudflare's authoritative NS caches NXDOMAIN for 1800s, causing lego's
      # propagation check to fail. Skip the authoritative NS check and let
      # Let's Encrypt validate directly.
      extraLegoFlags = [ "--dns.propagation-disable-ans" ];
    };
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-raw.path;
    domains = [ "plex.tretinha.com" ];
  };

  services.nginx = {
    enable = true;
    virtualHosts."plex.tretinha.com" = {
      useACMEHost = "tretinha.com";
      forceSSL = true;

      extraConfig = ''
        send_timeout 100m;

        # Forward real ip and host to Plex
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $host; # Changed to $host
        proxy_set_header Referer $server_addr;
        proxy_set_header Origin $server_addr;

        # Plex has A LOT of javascript, xml and html.
        gzip on;
        gzip_vary on;
        gzip_min_length 1000;
        gzip_proxied any;
        gzip_types text/plain text/css text/xml application/xml text/javascript application/x-javascript image/svg+xml;
        gzip_disable "MSIE [1-6]\.";

        # Fix for large uploads
        client_max_body_size 100M;

        # Plex headers
        proxy_set_header X-Plex-Client-Identifier $http_x_plex_client_identifier;
        proxy_set_header X-Plex-Device $http_x_plex_device;
        proxy_set_header X-Plex-Device-Name $http_x_plex_device_name;
        proxy_set_header X-Plex-Platform $http_x_plex_platform;
        proxy_set_header X-Plex-Platform-Version $http_x_plex_platform_version;
        proxy_set_header X-Plex-Product $http_x_plex_product;
        proxy_set_header X-Plex-Token $http_x_plex_token;
        proxy_set_header X-Plex-Version $http_x_plex_version;
        proxy_set_header X-Plex-Nocache $http_x_plex_nocache;
        proxy_set_header X-Plex-Provides $http_x_plex_provides;
        proxy_set_header X-Plex-Device-Vendor $http_x_plex_device_vendor;
        proxy_set_header X-Plex-Model $http_x_plex_model;

        # Websockets
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Buffering off
        proxy_redirect off;
        proxy_buffering off;
      '';
      locations."/" = {
        proxyPass = "http://localhost:32400/";
      };
    };
  };

  system.stateVersion = "25.11";
}
