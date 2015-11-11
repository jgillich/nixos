{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.vault;
  configFile = pkgs.writeText "vault.hlc" ''
  '';
in

{
  options = {
    services.vault = {
      enable = mkOption {
        default = false;
        type = with types; bool;
        description = ''
        '';
      };

    };
  };

  config = mkIf cfg.enable {
    systemd.services.vault = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = ''${pkgs.vault}/bin/vault server -config ${configFile}'';
      };
    };

    environment.systemPackages = [ pkgs.vault ];
  };
}
