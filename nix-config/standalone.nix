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
          overlays = [
            # Pin libinput to 1.29.2 (pre plugin-system rewrite) for the sway
            # stack only; mutter and other packages require libinput >= 1.30.
            # See the nixpkgs-libinput input comment.
            (
              final: prev:
              let
                libinput-pinned =
                  (import inputs.nixpkgs-libinput {
                    system = "x86_64-linux";
                  }).libinput;
              in
              {
                sway-unwrapped = prev.sway-unwrapped.override {
                  libinput = libinput-pinned;
                  wlroots_0_20 = prev.wlroots_0_20.override {
                    libinput = libinput-pinned;
                  };
                };
              }
            )
          ];
        };
        extraSpecialArgs = {
          inherit inputs;
        };
        modules = with inputs; [
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
