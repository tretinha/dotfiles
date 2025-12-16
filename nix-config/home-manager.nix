{ inputs, ... }:
{
  flake = {
    # Standalone home-manager configurations (for non-NixOS systems)
    homeConfigurations = {
      "gustavo@work" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          overlays = [
            (final: prev: {
              lix = inputs.lix.packages.x86_64-linux.default;
            })
          ];
        };
        modules = [
          ./hosts/work/home.nix
        ];
      };
    };
  };
}
