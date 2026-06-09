{ pkgs, src, x-ui, binBundle, version }:

let
  runtimeFiles = pkgs.runCommand "3x-ui-runtime-files" { } ''
    mkdir -p $out/app/web $out/usr/bin
    cp ${src}/DockerEntrypoint.sh $out/app/
    cp ${src}/x-ui.sh $out/usr/bin/x-ui
    cp -r ${src}/web/translation $out/app/web/translation
    chmod +x $out/app/DockerEntrypoint.sh $out/usr/bin/x-ui
  '';
in

pkgs.dockerTools.buildLayeredImage {
  name = "3x-ui-nix-local";
  tag = "nix-${version}";

  contents = [
    pkgs.bash
    pkgs.coreutils
    pkgs.gnugrep
    pkgs.gawk
    pkgs.curl
    pkgs.openssl
    pkgs.cacert
    pkgs.tzdata
    pkgs.fail2ban
    pkgs.iptables
    runtimeFiles
    x-ui
    binBundle
  ];

  config = {
    Env = [
      "XUI_IN_DOCKER=true"
      "XUI_MAIN_FOLDER=/app"
      "XUI_ENABLE_FAIL2BAN=true"
      "XUI_DB_TYPE="
      "XUI_DB_DSN="
      "TZ=Asia/Tehran"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
    ];
    ExposedPorts = {
      "2053/tcp" = { };
    };
    Volumes = {
      "/etc/x-ui" = { };
    };
    WorkingDir = "/app";
    Entrypoint = [ "/app/DockerEntrypoint.sh" ];
    Cmd = [ "./x-ui" ];
  };

  extraCommands = ''
    rm -f etc/fail2ban/jail.d/alpine-ssh.conf 2>/dev/null || true

    if [ -f etc/fail2ban/jail.conf ]; then
      cp etc/fail2ban/jail.conf etc/fail2ban/jail.local
      sed -i "s/^\[ssh\]\$/&\nenabled = false/" etc/fail2ban/jail.local
      sed -i "s/^\[sshd\]\$/&\nenabled = false/" etc/fail2ban/jail.local
    fi

    if [ -f etc/fail2ban/fail2ban.conf ]; then
      sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" etc/fail2ban/fail2ban.conf
    fi

    mkdir -p app/bin app/web
    ln -sf ${x-ui}/bin/x-ui app/x-ui
    for p in ${binBundle}/bin/*; do
      ln -sf "$p" "app/bin/$(basename "$p")"
    done
    ln -sf ${runtimeFiles}/app/DockerEntrypoint.sh app/DockerEntrypoint.sh
    ln -sf ${runtimeFiles}/app/web/translation app/web/translation
    ln -sf ${runtimeFiles}/usr/bin/x-ui usr/bin/x-ui
  '';
}
