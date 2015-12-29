{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  virtualisation.libvirtd.enable = true;

  services.haproxy = {
    enable = true;
    config = ''
      global
        user haproxy
        group haproxy
        daemon
        maxconn 4096
        ssl-default-bind-options no-sslv3 no-tls-tickets force-tlsv12
        ssl-default-bind-ciphers AES128+EECDH:AES128+EDH

      defaults
        log global
        mode http

      frontend http
        bind *:80
        redirect scheme https code 301

      frontend https *:443
        bind *:443 ssl crt TODO_ACME_CERTS
        reqadd X-Forwarded-Proto:\ https
        option forwardfor
        option originalto
        use_backend apu if { ssl_fc_sni apu.xsys.ga }
        use_backend git if { ssl_fc_sni git.xapp.ga }
        use_backend irc if { ssl_fc_sni irc.xapp.ga }
        use_backend music if { ssl_fc_sni music.xapp.ga }

      backend apu
        server apu localhost:8000
      backend git
        server git 127.0.0.1:8010
      backend irc
        server irc 127.0.0.1:8020
      backend music
        server music 127.0.0.1:8030
    '';
  };

  services.munin-cron = {
    enable = true;
    hosts = ''
      [${config.networking.hostName}]
      address localhost
    '';
  };
  services.munin-node.enable = true;

  nfs.server = {
    enable = true;
    exports = ''
      /var/music  127.0.0.1(rw,sync,no_subtree_check)
    '';
  };

  systemd.services.dyndns = {
    description = "Dynamic DNS";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.curl pkgs.bind ];

    # from http://torb.at/cloudflare-dynamic-dns
    script = ''
      DOMAIN=apu.sys.gillich.me
      NEWIP=`dig +short myip.opendns.com @resolver1.opendns.com`
      CURRENTIP=`dig +short $DOMAIN @resolver1.opendns.com`

      if [ "$NEWIP" = "$CURRENTIP" ]
      then
        echo "IP address unchanged"
      else
        curl --cacert /etc/ssl/certs/ca-certificates.crt \
          -X PUT "https://api.cloudflare.com/client/v4/zones/ca0fc28b0ea163a97ed05ad2bef5d99d/dns_records/234d4c0bdeac610bac6eb9bcc6617e9d" \
          -H "X-Auth-Email: ${secrets.cloudflare.login}" \
          -H "X-Auth-Key: ${secrets.cloudflare.apiKey}" \
          -H "Content-Type: application/json" \
          --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$NEWIP\"}"
      fi
    '';

    # every 5 minutes
    startAt = "*:0/5";
  };

  services.gitlab = {
    enable = true;
    port = 8010;
    emailFrom = "gitlab@xapp.ga";
    host = "git.xapp.ga";
    databasePassword = secrets.gitlab.databasePassword;
  };

  services.shout = {
    enable = true;
    port = 8020;
    private = true;
  };

  services.subsonic = {
    enable = true;
    httpsPort = 8030;
  };

  services.syncthing = {
    enable = false;
    user = "jakob";
    dataDir = "/home/jakob";
  };

}
