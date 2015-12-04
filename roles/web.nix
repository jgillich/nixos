{ config, pkgs, ... }:

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

}
