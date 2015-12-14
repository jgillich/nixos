{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  containers.mailserver = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      services.postfix = {
        enable = true;
        domain = "mail.gillich.me";
        # relayHost = "";
        # sslCACert
        # sslCert
        # sslKey
      };


      services.dovecot2 = {
        enable = true;
      };
    };
  };
}
