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
              sharedModules = [
                inputs.niri.homeModules.niri
                inputs.zen-browser.homeModules.beta
              ];
            };
          }
        ];
      };
      media = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/media/configuration.nix
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.gustavo = import ./hosts/media/home.nix;
              backupFileExtension = "bkp";
            };
          }
        ];
      };
    };
  };
}
