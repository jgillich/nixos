{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
  ports = {
    subsonic = 8001;
    shout = 8003;
    gitlab = 8004;
  };
in
{
  virtualisation.libvirtd.enable = true;

  services.nginx = {
    enable = true;
    httpConfig = ''
      server {
        listen 80;
        server_name _;
        location /.well-known/acme-challenge {
          root /var/www/challenges;
        }
        location / {
          return 301 https://$host$request_uri;
        }
      }

      server {
        listen 443 ssl;
        ssl_certificate /var/lib/acme/gillich.me/fullchain.pem;
        ssl_certificate_key /var/lib/acme/gillich.me/key.pem;
        root /var/www;
      }

      server {
        listen 443 ssl;
        server_name music.gillich.me;
        ssl_certificate /var/lib/acme/gillich.me/fullchain.pem;
        ssl_certificate_key /var/lib/acme/gillich.me/key.pem;

        location / {
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass http://127.0.0.1:${toString ports.subsonic};
        }
      }

      server {
        listen 443 ssl;
        server_name git.gillich.me;
        ssl_certificate /var/lib/acme/gillich.me/fullchain.pem;
        ssl_certificate_key /var/lib/acme/gillich.me/key.pem;

        location / {
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass http://127.0.0.1:${toString ports.gitlab};
        }
      }

      server {
        listen 443 ssl;
        server_name irc.gillich.me;
        ssl_certificate /var/lib/acme/gillich.me/fullchain.pem;
        ssl_certificate_key /var/lib/acme/gillich.me/key.pem;

        location / {
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_pass http://127.0.0.1:${toString ports.shout};
        }
      }
    '';
  };

  security.acme.certs."gillich.me" = {
    webroot = "/var/www/challenges";
    email = "jakob@gillich.me";
    extraDomains = {
      "www.gillich.me" = null;
      "music.gillich.me" = null;
      "git.gillich.me" = null;
      "sync.gillich.me" = null;
      "jakob.gillich.me" = null;
      "apu.gillich.me" = null;
    };
  };

  services.munin-cron = {
    enable = true;
    hosts = ''
      [${config.networking.hostName}]
      address localhost
    '';
  };
  services.munin-node.enable = true;

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
    port = ports.gitlab;
    emailFrom = "gitlab@xapp.ga";
    host = "git.xapp.ga";
    databasePassword = secrets.gitlab.databasePassword;
  };

  services.shout = {
    enable = true;
    port = ports.shout;
    private = true;
  };

  services.subsonic = {
    enable = true;
    httpsPort = ports.subsonic;
  };

}
