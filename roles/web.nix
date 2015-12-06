{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  environment.systemPackages = with pkgs; [
    python27Packages.docker_compose
    davfs2
  ];

  #fileSystems."/mnt/box" = {
  #  device = "https://dav.box.com/dav";
  #  fsType = "davfs";
  #};

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  services = {
    nginx = {
      enable = true;
      httpConfig = ''
        server {
          listen 80;
          return 301 https://$server_name$request_uri;
        }

        server {
          listen 443 ssl;
          ssl_certificate /root/.lego/certificates/apu.sys.gillich.me.crt;
          ssl_certificate_key /root/.lego/certificates/apu.sys.gillich.me.key;
          root /var/www;
        }

        server {
          listen 443 ssl;
          server_name sync.app.gillich.me;
          ssl_certificate /root/.lego/certificates/sync.app.gillich.me.crt;
          ssl_certificate_key /root/.lego/certificates/sync.app.gillich.me.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8384;
          }
        }

        server {
          listen 443 ssl;
          server_name torrent.app.gillich.me;
          ssl_certificate /root/.lego/certificates/torrent.app.gillich.me.crt;
          ssl_certificate_key /root/.lego/certificates/torrent.app.gillich.me.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8112;
          }

        }

        server {
          listen 443 ssl;
          server_name git.app.gillich.me;
          ssl_certificate /root/.lego/certificates/git.app.gillich.me.crt;
          ssl_certificate_key /root/.lego/certificates/git.app.gillich.me.key;

          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:10080;
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

 containers.syncthing = {
   autoStart = true;
   config = { config, pkgs, ... }: {
     services.syncthing = {
       enable = true;
       user = "jakob";
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

 # currently broken
 #containers.gitlab = {

   #autoStart = true;

   #config = { config, pkgs, ... }: {
     #services.gitlab = {
       #enable = true;
       #databasePassword = secrets.gitlab.databasePassword;
     #};
   #};

 #};

}
