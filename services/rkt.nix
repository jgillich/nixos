{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.rkt;
in

{
  
  options.virtualisation.rkt = {
    enable =
      mkOption {
        type = types.bool;
        default = false;
        description =
          ''
            This option enables the metadata service for the rkt container engine.
          '';
      };
  };

  config = {
    environment.systemPackages = [ pkgs.rkt ];

    systemd.services.rkt = {
      description = "rkt container engine metadata service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.rkt}/bin/rkt metadata-service";
      };

    };
  };
}
