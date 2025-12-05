{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      gaming = inputs.nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/gaming/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.gustavo = import ./hosts/gaming/home.nix;
              backupFileExtension = "bkp";
            };
          }
          inputs.jovian.nixosModules.default
          {
            jovian = {
              hardware = {
                has.amd.gpu = true;
                amd.gpu.enableBacklightControl = false;
              };
              steam = {
                updater.splash = "vendor";
                enable = true;
                autoStart = true;
                user = "gustavo";
                desktopSession = "plasma";
              };
              steamos = {
                useSteamOSConfig = true;
              };
            };
          }
        ];
      };
    };
  };
}
