{ inputs, ... }:
{
  flake = {
    nixosConfigurations = {
      gaming = inputs.nixpkgs.lib.nixosSystem {
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
	      # Commenting this out because I'm currently not interested in
	      # logging directly to big picture
                # autoStart = true;
                user = "gustavo";
                desktopSession = "plasma";
              };
	      # Commenting this out because I'm currently not interested in
	      # logging directly to big picture
              # steamos = {
              #   useSteamOSConfig = true;
              # };
            };
          }
        ];
      };
    };
  };
}
