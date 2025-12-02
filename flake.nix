{
  description = "Flake for oom's nix base";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, ... }@inputs:
    let
      systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux" ];
      allSystems = inputs.nixpkgs.lib.systems.flakeExposed;
      forSystems = systems: f: nixpkgs.lib.genAttrs systems (system: f system);
      mkPkgs = nixpkgs: system: import nixpkgs {
        inherit system; overlays = [ self.overlays.pkgs ];
      };
      mkLegacyPackagesFor = nixpkgs: forSystems systems (mkPkgs nixpkgs);
    in
    {
      devShells = forSystems allSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ nixpkgs-fmt ];
          };
        });

      darwinModules = { };
      nixosModules = {
        nixpkgs = { config, lib, pkgs, ... }: import ./modules/nixpkgs.nix {
          inherit config lib pkgs self;
        };
        modules = import ./nixos/all-modules.nix;
        homeManager = import ./modules/homeManager.nix;
        darwin = {
          default = import ./modules/darwin.nix;
          aarch64 = import ./modules/darwin/cpu/aarch64.nix;
          x86-64 = import ./modules/darwin/cpu/x86-64.nix;
        };
        linux = {
          default = import ./modules/nixos.nix;
          legacy-fs = import ./modules/nixos/legacy-fs;
          aarch64 = import ./modules/nixos/cpu/aarch64.nix;
          amd-x86-64 = import ./modules/nixos/cpu/amd-x86-64.nix;
          intel-x86-64 = import ./modules/nixos/cpu/intel-x86-64.nix;
        };
      };

      overlays = { pkgs = import ./overlays/pkgs.nix; };

      legacyPackages = mkLegacyPackagesFor nixpkgs;

      packages = forSystems systems (system: import pkgs/all-packages.nix { inherit system self; });

    };
}
