{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.miniupnpd;
  configFile = pkgs.writeText "miniupnpd.conf" ''
    ext_ifname=${cfg.externalInterface}
    enable_natpmp=${if cfg.natpmp then "yes" else "no"}
    enable_upnp=${if cfg.upnp then "yes" else "no"}

    ${concatMapStrings (range: ''
      listening_ip=${range}
    '') cfg.internalIPs}

    ${cfg.appendConfig}
  '';
in
{
  options = {
    services.miniupnpd = {
      enable = mkOption {
        type        = types.bool;
        default     = false;
        description = "Enable the MiniUPnP daemon.";
      };

      externalInterface = mkOption {
        type = types.str;
        description = ''
          Name of the external interface
        '';
      };

      internalIPs = mkOption {
        type = types.listOf types.str;
        example = [ "192.168.1.0/24" ];
        description =
          ''
            The IP address ranges to listen on.
          '';
      };

      natpmp = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to use to enable NAT-PMP support
        '';
      };

      upnp = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Whether to use to enable UPNP support
        '';
      };

      appendConfig = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Configuration lines appended to the MiniUPnP config.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.miniupnpd = {
      description = "MiniUPnP daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.miniupnpd ];
      serviceConfig = {
        ExecStart = "${pkgs.miniupnpd}/bin/miniupnpd -f ${configFile}";
      };
    };
  };
}
