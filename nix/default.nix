{ pkgs, src }:

let
  version = pkgs.lib.removeSuffix "\n" (builtins.readFile (src + "/internal/config/version"));

  frontend = pkgs.callPackage ./frontend.nix { inherit src version; };

  x-ui = pkgs.callPackage ./x-ui.nix { inherit src frontend version; };

  binBundle = pkgs.callPackage ./bin-bundle.nix { system = pkgs.stdenv.hostPlatform.system; };

  dockerImage = pkgs.callPackage ./docker.nix { inherit src x-ui binBundle version; };
in
{
  inherit frontend x-ui binBundle;

  dockerImage = dockerImage;

  default = dockerImage;
}
