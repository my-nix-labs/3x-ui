{ pkgs, system }:

let
  archMap = {
    x86_64-linux = {
      xray = "64";
      fname = "amd64";
      # mtg = "amd64";
    };
    aarch64-linux = {
      xray = "arm64-v8a";
      fname = "arm64";
      # mtg = "arm64";
    };
  };

  a = archMap.${system} or (throw "Unsupported system for 3x-ui bin bundle: ${system}");

  xrayZip = pkgs.fetchzip {
    url = "https://github.com/XTLS/Xray-core/releases/download/v26.6.1/Xray-linux-${a.xray}.zip";
    stripRoot = false;
    hash =
      if a.fname == "amd64" then
        "sha256-5ZwqIwL6f8TLOgjFxOLuxZbDvtf4czYk9muUVJwE5MA="
      else
        "sha256-XA85eyYFqFPlswiuZIWtLsOVyhHteuD9AjxIDH/bJ50=";
  };

  # MTProto (mtg) omitted — VLESS-only; re-enable if you add MTProto inbounds.
  # mtgSrc = builtins.fetchTarball {
  #   url = "https://github.com/9seconds/mtg/releases/download/v2.2.8/mtg-2.2.8-linux-${a.mtg}.tar.gz";
  #   sha256 =
  #     if a.mtg == "amd64" then
  #       "sha256-1o81pzsZrCY0UdQ1nkg3rbSw6HhZ3UTfuYTFz23BBAk="
  #     else
  #       "sha256-sF6he+PiCQEphOTHZkj2X+Raa1+VNxGWd85XPROOoxg=";
  # };

  geoip = pkgs.fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat";
    hash = "sha256-fA4ONx3erKpBA4lV1Q6oac9PsfPc3/D3HC8NbVn8zOg=";
  };

  geosite = pkgs.fetchurl {
    url = "https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat";
    hash = "sha256-hyixZE98fIkzIvnDQ5YVEdsgSSqTsAm3UILVNvzItSw=";
  };

  # IR/RU geo omitted — only needed for ext:geoip_IR.dat / ext:geosite_RU.dat routing rules.
  # geoipIR = pkgs.fetchurl {
  #   url = "https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geoip.dat";
  #   hash = "sha256-G8N82GJZnQI1AK2DZYrOXmQvP78qdSManY2zRMTihlk=";
  # };
  #
  # geositeIR = pkgs.fetchurl {
  #   url = "https://github.com/chocolate4u/Iran-v2ray-rules/releases/latest/download/geosite.dat";
  #   hash = "sha256-5Qv37VdX9B6ZsK13F/LXJ/oARWac2pJu/gPJbBuTQtU=";
  # };
  #
  # geoipRU = pkgs.fetchurl {
  #   url = "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geoip.dat";
  #   hash = "sha256-whOoQ/3ZXS6H5XPO/INLA7NKnFMKu50XEOoB3ZQ4K74=";
  # };
  #
  # geositeRU = pkgs.fetchurl {
  #   url = "https://github.com/runetfreedom/russia-v2ray-rules-dat/releases/latest/download/geosite.dat";
  #   hash = "sha256-pn/hcCiEW2C+t0YWQZ/MgAuG31fTmr27KjRbofcQtwY=";
  # };

in

# runCommand (mtg): paste after xray chmod, together with mtgSrc + archMap mtg above
  #   cp ${mtgSrc}/mtg $out/bin/mtg-linux-${a.fname}
  #   chmod +x $out/bin/mtg-linux-${a.fname}

  # runCommand (IR/RU geo): paste after geosite, together with geoipIR/geositeIR/geoipRU/geositeRU above
  #   cp ${geoipIR} $out/bin/geoip_IR.dat
  #   cp ${geositeIR} $out/bin/geosite_IR.dat
  #   cp ${geoipRU} $out/bin/geoip_RU.dat
  #   cp ${geositeRU} $out/bin/geosite_RU.dat

pkgs.runCommand "3x-ui-bin" { } ''
  mkdir -p $out/bin

  cp ${xrayZip}/xray $out/bin/xray-linux-${a.fname}
  chmod +x $out/bin/xray-linux-${a.fname}

  cp ${geoip} $out/bin/geoip.dat
  cp ${geosite} $out/bin/geosite.dat
''
