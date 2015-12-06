{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  environment.systemPackages = with pkgs; [
    python27Packages.docker_compose
  ];

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  services = {
    nginx = {
      enable = true;
      httpConfig = ''
        server {
          listen 80;
          root /var/www;
        }

        server {
          server_name sync.app.gillich.me;
          listen   80;
          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8384;
          }
        }

        server {
          server_name torrent.app.gillich.me;
          listen   80;
          location / {
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8112;
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
    path = [ pkgs.curl pkgs.bind pkgs.curl ];

    # from http://www.whaleblubber.ca/dynamic-cloudflare/
    script = ''
      # set your user, token, name server and a comma-separated list of A records
      CFUSER=${secrets.cloudflare.login}
      CFTOKEN=${secrets.cloudflare.apiKey}
      CFNS=charles.ns.cloudflare.com
      CFHOSTS=apu.sys.gillich.me

      # get your current external IP address
      CFIP=$(curl -s http://myip.dnsomatic.com/)

      # find out the ip address listed in DNS for the first host in your list
      CFHOSTIP=$(nslookup $(echo $CFHOSTS | cut -d ',' -f1) $CFNS | grep Address | tail -1 | cut -d ' ' -f2)

      # if your external IP is different from DNS do the update
      if [ "$CFIP" != "$CFHOSTIP" ]
      then
        # build the url you need to do the update
        CFURL="https://www.cloudflare.com/api.html?a=DIUP&hosts=$CFHOSTS&u=$CFUSER&tkn=$CFTOKEN&ip=$CFIP"

        # use curl to do the dynamic update
        /usr/bin/curl -s $CFURL
        echo "updated ip"
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
