{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  imports =  [
    ../services/ppp.nix
    ../services/miniupnpd.nix
  ];

  networking = {
    domain = "home";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];

    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "wlp4s0" ];
      allowedTCPPorts = [
        22    # ssh
        80    # http
        443   # https
        2222  # git
      ];
      allowedUDPPorts = [
      ];
    };

    nat = {
      enable = true;
      internalIPs = [ "10.0.1.0/24" "10.0.2.0/24" "10.0.3.0/24" ];
      externalInterface = "ppp0";
    };

    interfaces = {
      wlp4s0 = {
        ipAddress = "10.0.1.1";
        prefixLength = 24;
      };

      enp1s0 = {
        useDHCP = false;
      };

      enp2s0 = {
        ipAddress = "10.0.2.1";
        prefixLength = 24;
      };

      enp3s0 = {
        ipAddress = "10.0.3.1";
        prefixLength = 24;
      };
    };
  };

  services.hostapd = {
    enable = true;
    interface = "wlp4s0";
    ssid = secrets.hostapd.ssid;
    hwMode = "g";
    channel = 10;
    wpaPassphrase = secrets.hostapd.wpaPassphrase;
  };

  services.dhcpd = {
    enable = true;
    interfaces = [ "wlp4s0" "enp2s0" "enp3s0" ];
    extraConfig = ''
      authoritative;
      option subnet-mask            255.255.255.0;
      option domain-name-servers    8.8.8.8, 8.8.4.4;

      # lease time 24 hours
      max-lease-time                86400;
      default-lease-time            86400;

      subnet 10.0.1.0 netmask 255.255.255.0 {
        range                       10.0.1.10 10.0.1.254;
        option broadcast-address    10.0.1.255;
        option routers              10.0.1.1;
      }

      subnet 10.0.2.0 netmask 255.255.255.0 {
        range                       10.0.2.10 10.0.2.254;
        option broadcast-address    10.0.2.255;
        option routers              10.0.2.1;
      }

      subnet 10.0.3.0 netmask 255.255.255.0 {
        range                       10.0.3.10 10.0.3.254;
        option broadcast-address    10.0.3.255;
        option routers              10.0.3.1;
      }
    '';
  };

  services.dnsmasq = {
    enable = false;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      no-resolv
    '';
  };

  services.ppp = {
    enable = true;

    config = {
      easybell = {
        interface = "enp1s0";
        username = secrets.easybell.username;
        password = secrets.easybell.password;
        debug = true;
        extraOptions = ''
          noauth
          defaultroute
          persist
          maxfail 0
          holdoff 5
          lcp-echo-interval 15
          lcp-echo-failure 3
        '';
        };
    };
  };

  services.miniupnpd = {
    enable = true;
    externalInterface = "ppp0";
    internalIPs = [ "10.0.1.1/24" "10.0.2.1/24" "10.0.3.1/24" ];
  };
}
