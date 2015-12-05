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

   munin-node.enable = true;
   munin-cron = {
     enable = true;
     hosts = ''
      [home]
       address localhost
     '';
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
