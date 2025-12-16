{ inputs, ... }:
{
  flake = {
    # Standalone home-manager configurations (for non-NixOS systems)
    homeConfigurations = {
      "gustavo@work" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = [
          ./hosts/work/home.nix
        ];
      };
    };
  };
}
