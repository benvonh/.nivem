{
  description = "An icy config for Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim/nixos-24.11";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    inherit (self) outputs;

    systems = [
      # Linux
      "i686-linux"
      "x86_64-linux"
      "aarch64-linux"
      # Darwin
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    pkgsFor = nixpkgs.legacyPackages;
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in
  {
    packages = forAllSystems (system:
      let pkgs = pkgsFor.${system}; in {
        cheat = pkgs.callPackage ./cheat {};
      });

    devShells = forAllSystems (system:
      let pkgs = pkgsFor.${system}; in {
        default = pkgs.mkShell {
          NIX_CONFIG = "experimental-features = nix-command flakes";
          packages = with pkgs; [ nix git vim home-manager ];
        };
      });

    homeConfigurations = {
      ben = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit inputs outputs; };
        modules = [ ./profile ];
        pkgs = pkgsFor.x86_64-linux;
      };
    };
  };
}
