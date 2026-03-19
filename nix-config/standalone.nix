{ inputs, ... }:
{
  flake = {
    # Standalone home-manager configurations (for non-NixOS systems)
    homeConfigurations = {
      "gustavo@work" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
          };
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = with inputs; [
          niri.homeModules.niri
          zen-browser.homeModules.beta
          ./hosts/work/home.nix
        ];
      };
      
      "gustavo@lila" = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import inputs.nixpkgs {
          system = "aarch64-darwin";
          config = {
            allowUnfree = true;
          };
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = with inputs; [
          zen-browser.homeModules.beta
          ./hosts/lila/home.nix
        ];
      };
    };
  };
}
