{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
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

 containers.syncthing = {
   autoStart = true;
   config = { config, pkgs, ... }: {
     services.syncthing.enable = true;
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
