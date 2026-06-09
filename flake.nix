{
  description = "Reproducible Nix build and Docker image for 3x-ui";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:nix-community/gomod2nix";
  };

  outputs = { self, nixpkgs, flake-utils, gomod2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gomod2nix.overlays.default ];
        };
        packages = import ./nix/default.nix {
          inherit pkgs;
          src = self;
        };
      in
      {
        inherit packages;
        defaultPackage = packages.default;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go
            nodejs_22
            gomod2nix
          ];
        };
      });
}
