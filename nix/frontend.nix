{ pkgs, src, version }:

let
  frontendSrc = pkgs.lib.cleanSource (src + "/frontend");
  npmDeps = pkgs.fetchNpmDeps {
    src = frontendSrc;
    hash = "sha256-uB6VjDLflHu0WNvSJcqKUUCeob0/M+a5p1VVwMbbaQc=";
  };
in

pkgs.stdenv.mkDerivation {
  pname = "3x-ui-frontend";
  inherit version;

  src = pkgs.lib.cleanSource src;

  nativeBuildInputs = [
    pkgs.nodejs_22
    pkgs.npmHooks.npmConfigHook
  ];

  npmRoot = "frontend";
  inherit npmDeps;

  buildPhase = ''
    export X_UI_VERSION="${version}"
    export HOME="$TMPDIR"

    cd frontend
    npm run build
  '';

  installPhase = ''
    mkdir -p "$out/dist"
    cp -r ../internal/web/dist/. "$out/dist/"
  '';
}
