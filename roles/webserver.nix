{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  virtualisation.libvirtd.enable = true;

  services = {
    nginx = {
      enable = true;
      httpConfig = ''
        server {
          listen 80;
          server_name _;
          return 301 https://$host$request_uri;
        }

        server {
          listen 443 ssl;
          ssl_certificate /root/.lego/certificates/apu.sys.gillich.me.crt;
          ssl_certificate_key /root/.lego/certificates/apu.sys.gillich.me.key;
          root /var/www;
        }

        server {
          listen 443 ssl;
          server_name sync.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8384;
          }
        }

        server {
          listen 443 ssl;
          server_name torrent.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8112;
          }

        }

        server {
          listen 443 ssl;
          server_name git.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8080;
          }
        }

        server {
          listen 443 ssl;
          server_name irc.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8010;
          }
        }

        server {
          listen 443 ssl;
          server_name music.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass https://127.0.0.1:8020;
          }
        }

        server {
          listen 443 ssl;
          server_name mail.xapp.ga;
          ssl_certificate /root/.lego/certificates/xapp.ga.crt;
          ssl_certificate_key /root/.lego/certificates/xapp.ga.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:33411;
          }
        }
      '';
    };

    munin-cron = {
      enable = true;
      hosts = ''
        [${config.networking.hostName}]
        address localhost
      '';
    };
    munin-node.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        /var/music  10.0.1.1(rw,sync,no_subtree_check)
      '';
    };
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

  #systemd.services.backup = {
  #  description = "Backup";
  #  serviceConfig.Type = "oneshot";
  #  path = [ pkgs.duplicity ];

  #  script = ''
  #    URL="webdavs://${secrets.box.username}:${secrets.box.password}@dav.box.com/dav/backups"
  #    DUP="duplicity --ssl-cacert-file /etc/ssl/certs/ca-certificates.crt --encrypt-key Jakob\ Gillich"

  #    $DUP /etc/nixos/roles $URL/nixos
  #  '';

  #  startAt = "05:40";
  #};

  containers.shout = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      environment.systemPackages = [ pkgs.shout ];
      services.shout = {
        enable = true;
        port = 8010;
        private = true;
        configFile = ''
          module.exports = {
            public: false,
            host: "0.0.0.0",
            port: 9000,
            bind: undefined,
            theme: "themes/example.css",
            autoload: true,
            prefetch: false,
            prefetchMaxImageSize: 512,
            displayNetwork: true,
            logs: {
              format: "YYYY-MM-DD HH:mm:ss",
              timezone: "UTC+00:00"
            },
            defaults: {
              name: "Freenode",
              host: "irc.freenode.org",
              port: 6697,
              password: "",
              tls: true,
              nick: "shout-user",
              username: "shout-user",
              realname: "Shout User",
              join: "#foo, #shout-irc"
            },
            transports: ["polling", "websocket"],
            https: {
              enable: false,
              key: "",
              certificate: ""
            },
            identd: {
              enable: false,
              port: 113
            }
          };
        '';
      };
    };
  };

  containers.syncthing = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.syncthing = {
        enable = true;
        user = "jakob";
        dataDir = "/home/jakob";
      };
      users.extraUsers.jakob = {
        createHome = true;
        home = "/home/jakob";
      };
    };
  };

  containers.deluge = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.deluge = {
        enable = true;
        web.enable = true;
      };
    };
  };

  containers.subsonic = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      environment.systemPackages = [ pkgs.nfs-utils ];
      fileSystems."/var/music" = {
        device = "10.0.1.1:/var/music";
        fsType = "nfs";
      };
      services.subsonic = {
        enable = true;
        httpsPort = 8020;
      };
    };
  };

  containers.gitlab = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.gitlab = {
        enable = true;
        port = 8030;
        emailFrom = "gitlab@xapp.ga";
        host = "git.xapp.ga";
        databasePassword = secrets.gitlab.databasePassword;
      };
      services.openssh = {
        enable = true;
        ports = [ 2222 ];
      };
    };
  };

  containers.mailpile = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.mailpile = {
        enable = true;
        hostname = "mail.xapp.ga";
      };
    };
  };
}