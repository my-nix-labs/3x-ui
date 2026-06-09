{ pkgs, src, frontend, version }:

pkgs.buildGoModule {
  pname = "x-ui";
  inherit version;

  src = pkgs.lib.cleanSource src;

  vendorHash = "sha256-wq+y5WFwJPOH7nZID4UMpLSyB4ZmD0JVjL8lJmC1FQc=";

  go = pkgs.go_1_26;

  nativeBuildInputs = [ pkgs.gcc pkgs.pkg-config ];

  prePatch = ''
    substituteInPlace go.mod --replace-fail 'go 1.26.4' 'go 1.26.3'
  '';

  preBuild = ''
    rm -rf web/dist
    mkdir -p web/dist
    cp -r ${frontend}/dist/. web/dist/
  '';

  ldflags = [ "-s" "-w" ];

  subPackages = [ "." ];

  postInstall = ''
    mv $out/bin/3x-ui $out/bin/x-ui
  '';
}
