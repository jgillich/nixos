{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.virtualisation.rkt;
in

{
  options.virtualisation.rkt = {
    enable = mkEnableOption "rkt metadata service";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.rkt ];

    systemd.services.rkt = {
      description = "rkt metadata service";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.rkt}/bin/rkt metadata-service";
      };
    };
  };
}
