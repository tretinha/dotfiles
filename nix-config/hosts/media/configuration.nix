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
    "cloudflared-gts" = {
      file = ../../secrets/cloudflared-gts.age;
      owner = "cloudflared";
      group = "cloudflared";
    };
    "gts-metrics-env" = {
      file = ../../secrets/gts-metrics-env.age;
    };
    "gts-metrics-pw" = {
      file = ../../secrets/gts-metrics-pw.age;
      owner = "prometheus";
    };
    "grafana-admin-pw" = {
      file = ../../secrets/grafana-admin-pw.age;
      owner = "grafana";
    };
    "grafana-secret-key" = {
      file = ../../secrets/grafana-secret-key.age;
      owner = "grafana";
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
      # Cloudflare is slow to propagate API-created TXT records. Sleep before
      # asking Let's Encrypt to validate (propagation-wait also skips all
      # DNS propagation checks after the sleep).
      extraLegoFlags = [
        "--dns.propagation-wait"
        "60s"
      ];
    };
  };

  services.cloudflare-dyndns = {
    enable = true;
    apiTokenFile = config.age.secrets.cloudflare-raw.path;
    domains = [
      "plex.tretinha.com"
    ];
  };

  services.gotosocial = {
    enable = true;
    environmentFile = config.age.secrets.gts-metrics-env.path;
    settings = {
      host = "social.tretinha.com";
      protocol = "https";
      bind-address = "127.0.0.1";
      port = 8081;
      trusted-proxies = [ "127.0.0.1/32" ];
      metrics-enabled = true;
    };
  };

  services.prometheus = {
    enable = true;
    exporters.node.enable = true;
    exporters.nginx.enable = true;
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
      }
      {
        job_name = "nginx";
        static_configs = [ { targets = [ "127.0.0.1:9113" ]; } ];
      }
      {
        job_name = "gotosocial";
        metrics_path = "/metrics";
        basic_auth = {
          username = "prometheus";
          password_file = config.age.secrets.gts-metrics-pw.path;
        };
        static_configs = [ { targets = [ "127.0.0.1:8081" ]; } ];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "grafana.tretinha.com";
        root_url = "https://grafana.tretinha.com";
      };
      security.admin_password = "$__file{${config.age.secrets.grafana-admin-pw.path}}";
      security.secret_key = "$__file{${config.age.secrets.grafana-secret-key.path}}";
    };
    provision.datasources.settings.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        url = "http://127.0.0.1:9090";
        isDefault = true;
      }
    ];
  };

  users.users.cloudflared = {
    isSystemUser = true;
    group = "cloudflared";
  };
  users.groups.cloudflared = { };

  services.cloudflared = {
    enable = true;
    tunnels."e75d6b43-0e0b-4e52-95b2-cb771763f6cf" = {
      credentialsFile = config.age.secrets.cloudflared-gts.path;
      default = "http_status:404";
      ingress = {
        "social.tretinha.com" = "http://127.0.0.1:8081";
        "phanpy.tretinha.com" = "http://127.0.0.1:8082";
        "grafana.tretinha.com" = "http://127.0.0.1:3000";
      };
    };
  };

  services.nginx = {
    enable = true;
    statusPage = true;
    virtualHosts = {
      "phanpy.tretinha.com" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8082;
          }
        ];
        root = pkgs.fetchzip {
          url = "https://github.com/cheeaun/phanpy/releases/download/2026.06.23.05dcc55/phanpy-dist.tar.gz";
          sha256 = "10s59yalxv28jggxhn2p6ic3a23jnv7cbv7czvhvfbwgjgvkjpfm";
          stripRoot = false;
        };
        locations."/" = {
          tryFiles = "$uri $uri/ /index.html";
        };
      };
      "plex.tretinha.com" = {
        useACMEHost = "tretinha.com";
        forceSSL = true;

        extraConfig = ''
          send_timeout 100m;

          # Forward real ip and host to Plex
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Host $host;
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
  };

  system.stateVersion = "25.11";
}
