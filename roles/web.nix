{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
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


 containers.gitlab = {

   autoStart = true;

   config = { config, pkgs, ... }: {
     services.gitlab = {
       enable = true;
       databasePassword = secrets.gitlab.databasePassword;
     };
   };

 };

}
