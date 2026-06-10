{ pkgs, src, x-ui, binBundle, version }:

let
  # Docker 精简镜像：仅 x-ui + xray + geo；ACME / x-ui.sh / fail2ban 见下方注释块。
  runtimeFiles = pkgs.runCommand "3x-ui-runtime-files" { } ''
    mkdir -p $out/app/internal/web
    cp -r ${src}/internal/web/translation $out/app/internal/web/translation
    # cp ${src}/DockerEntrypoint.sh $out/app/
    # chmod +x $out/app/DockerEntrypoint.sh
    # mkdir -p $out/usr/bin
    # cp ${src}/x-ui.sh $out/usr/bin/x-ui   # VPS 交互菜单；Docker 内用 /app/x-ui CLI 即可
    # chmod +x $out/usr/bin/x-ui
  '';
in

# runtimeFiles（可选）：恢复 DockerEntrypoint.sh / x-ui.sh 时取消注释上面 runCommand 与下方 extraCommands  symlink
  # contents（可选 acme / fail2ban / x-ui.sh）：
  #   pkgs.bash pkgs.coreutils pkgs.curl pkgs.openssl  — 容器内 acme.sh 或 /usr/bin/x-ui 菜单
  #   pkgs.gnugrep pkgs.gawk pkgs.fail2ban pkgs.iptables — fail2ban IP Limit
  #   pkgs.tzdata + Env TZ=Asia/Tehran

pkgs.dockerTools.buildLayeredImage {
  name = "3x-ui-nix-local";
  tag = "nix-${version}";

  contents = [
    pkgs.busybox
    pkgs.cacert
    # pkgs.bash
    # pkgs.coreutils
    # pkgs.gnugrep
    # pkgs.gawk
    # pkgs.curl
    # pkgs.openssl
    # pkgs.tzdata
    # pkgs.fail2ban
    # pkgs.iptables
    runtimeFiles
    x-ui
    binBundle
  ];

  config = {
    Env = [
      "XUI_IN_DOCKER=true"
      "XUI_MAIN_FOLDER=/app"
      "XUI_ENABLE_FAIL2BAN=false"
      "XUI_DB_TYPE="
      "XUI_DB_DSN="
      # "TZ=Asia/Tehran"
      "SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt"
    ];
    ExposedPorts = {
      "2053/tcp" = { };
    };
    Volumes = {
      "/etc/x-ui" = { };
    };
    WorkingDir = "/app";
    Entrypoint = [ "/app/x-ui" ];
    # Entrypoint = [ "/app/DockerEntrypoint.sh" ];
    # Cmd = [ "./x-ui" ];
  };

  extraCommands = ''
    # fail2ban：启用 IP Limit 时取消注释 fail2ban/iptables、DockerEntrypoint.sh 与下方配置
    # rm -f etc/fail2ban/jail.d/alpine-ssh.conf 2>/dev/null || true
    #
    # if [ -f etc/fail2ban/jail.conf ]; then
    #   cp etc/fail2ban/jail.conf etc/fail2ban/jail.local
    #   sed -i "s/^\[ssh\]\$/&\nenabled = false/" etc/fail2ban/jail.local
    #   sed -i "s/^\[sshd\]\$/&\nenabled = false/" etc/fail2ban/jail.local
    # fi
    #
    # if [ -f etc/fail2ban/fail2ban.conf ]; then
    #   sed -i "s/#allowipv6 = auto/allowipv6 = auto/g" etc/fail2ban/fail2ban.conf
    # fi

    mkdir -p app/bin app/internal/web
    ln -sf ${x-ui}/bin/x-ui app/x-ui
    for p in ${binBundle}/bin/*; do
      ln -sf "$p" "app/bin/$(basename "$p")"
    done
    # ln -sf ${runtimeFiles}/app/DockerEntrypoint.sh app/DockerEntrypoint.sh
    ln -sf ${runtimeFiles}/app/internal/web/translation app/internal/web/translation
    # ln -sf ${runtimeFiles}/usr/bin/x-ui usr/bin/x-ui
  '';
}
