{
  description = "Nix package for Ratspeak, a Reticulum and LXMF desktop client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        ratspeak = pkgs.callPackage ./package.nix { };
        default = ratspeak;
      });

      overlays.default = final: prev: {
        ratspeak = final.callPackage ./package.nix { };
      };

      apps = forAllSystems (
        pkgs:
        let
          program = nixpkgs.lib.getExe (pkgs.callPackage ./package.nix { });
        in
        rec {
          ratspeak = {
            type = "app";
            inherit program;
          };
          default = ratspeak;
        }
      );

      checks = forAllSystems (pkgs: {
        build = pkgs.callPackage ./package.nix { };
      });

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    };
}
