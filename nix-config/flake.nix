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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" ];
      imports = [
        ./nixos.nix      # NixOS system configurations (gaming PC)
        ./standalone.nix # Standalone home-manager configs (work PC on Ubuntu)
      ];
    };
  # outputs = { self, nixpkgs, home-manager, ... }: {
  #   nixosConfigurations = {
  # 	  gaming = nixpkgs.lib.nixosSystem {
  #       system = "x86_64-linux";
  #       modules = [
  #         ./configuration.nix
  #         home-manager.nixosModules.home-manager
  #         {
  #           home-manager = {
  #             useGlobalPkgs = true;
  #             useUserPackages = true;
  #             users.gustavo = import ./home.nix;
  #             backupFileExtension = "backup";
  #           };
  #         }
  #       ];
  # 	  };
  #   };
  # };
}
