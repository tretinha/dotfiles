{
  description = "flake";

  inputs = {
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    # libinput 1.30+ rewrote button handling (debounce moved into the new
    # plugin system) and causes phantom double clicks / broken drag selection
    # with the Logitech MX Ergo under sway. nixos-25.11 carries the last
    # pre-rewrite release (1.29.2), the same version niri linked against.
    nixpkgs-libinput = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri = {
      url = "github:sodiboo/niri-flake";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
    };
    agenix = {
      url = "github:ryantm/agenix";
    };
    waza = {
      url = "github:tw93/Waza";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      perSystem = { system, ... }: {
        _module.args.pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
        };
      };

      imports = [
        ./nixos.nix # NixOS systems
        ./standalone.nix # Non-NixOS systems
      ];
    };
}
