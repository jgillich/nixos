{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ppp;
in
{
  options = {
    services.ppp = {
      enable = mkEnableOption "ppp client service";

      config = mkOption {
        type = types.attrsOf (types.submodule (
          {
            options = {
              username = mkOption {
                type    = types.str;
                default = "";
                description = ''
                    <literal>username</literal> of the ppp connection.
                '';
              };

              password = mkOption {
                type    = types.str;
                default = "";
                description = ''
                    <literal>password</literal> of the ppp connection.
                '';
              };

              interface = mkOption {
                type = types.str;
                description = "Interface which the ppp connection will use.";
              };

              pppoe = mkEnableOption "pppoe plugin";

              debug = mkEnableOption "debug mode";

              extraOptions = mkOption {
                type = types.lines;
                default = "";
                description = "Extra ppp connection options";
              };
            };
          }
        ));

        default = {};

        example = literalExample ''
          {
            velox = {
              interface = "enp1s0";
              pppoe = true;
              username = "0000000000@oi.com.br";
              password = "fulano";
              extraOptions = \'\'
                noauth
                defaultroute
                persist
                maxfail 0
                holdoff 5
                lcp-echo-interval 15
                lcp-echo-failure 3
              \'\';
            };
          }
        '';

        description = ''
          Configuration for a ppp daemon. The daemon can be
          started, stopped, or examined using
          <literal>systemctl</literal>, under the name
          <literal>ppp@foo</literal>.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services."ppp@" = {
      description = "PPP link to '%i'";
      wantedBy = [ "network.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.ppp}/sbin/pppd call %I nodetach nolog";
      };
    };

    systemd.targets."default-ppp" = {
      description = "Target to start all default ppp@ services";
      wants = mapAttrsToList (name: cfg: "ppp@${name}.service") cfg.config;
      wantedBy = [ "multi-user.target" ];
    };

    environment.etc = {
      "ppp/pap-secrets".text = concatStringsSep "\n"
          (mapAttrsToList (name: cfg: "${cfg.username} * ${cfg.password}") cfg.config);
      } //
      mapAttrs' (name: cfg: nameValuePair "ppp/peers/${name}" {
        text = concatStringsSep "\n" [
            (optionalString cfg.pppoe "plugin rp-pppoe.so")
            "${cfg.interface}"
            "user \"${cfg.username}\""
            "${cfg.extraOptions}"
            (optionalString cfg.debug "debug")
          ];
      }) cfg.config;
  };
}
