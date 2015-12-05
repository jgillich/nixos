{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{

  imports =  [
    ../services/ppp.nix
  ];

  networking = {
    nameservers = [ "8.8.8.8" "4.4.4.4" ];
    defaultGateway = "ppp0";
    domain = "home";

    firewall = {

      enable = true;
      allowPing = true;

      allowedTCPPorts = [
        22
        80
        9999
        445
        139
      ];

      allowedUDPPorts = [
        137
        138
        67
        68
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
  networking.wireless.enable = false;
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
        option subnet-mask          255.255.255.0;
        option broadcast-address    10.0.3.255;
        option routers              10.0.3.1;
      }
    '';
  };

  services.dnsmasq = {
    enable = true;
    servers = [ "8.8.8.8" "8.8.4.4" ];
  };

  services.ppp = {
    enable = true;

    config = {
      easybell =
        { interface = "enp1s0";
          username = secrets.easybell.username;
          password = secrets.easybell.password;
          extraOptions = ''
            noauth
            defaultroute
            persist
            maxfail 0
            holdoff 3
            lcp-echo-interval 15
            lcp-echo-failure 3
          '';
        };

    };
  };

}
