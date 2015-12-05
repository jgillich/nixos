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
      internalIPs = [ "192.168.1.0/24" ]; #[ "192.168.1.0/24" "192.168.2.0/24" "192.168.3.0/24" ];
      externalInterface = "ppp0";
    };

    interfaces = {
      #enp4s6f = {
      #  ipAddress = "192.168.1.1";
      #  prefixLength = 24;
      #};

      #enp4s6f1 = {
      #  ipAddress = "192.168.2.1";
      #  prefixLength = 24;
      #};

      wlp2s0 = {
        ipAddress = "192.168.1.1";
        prefixLength = 24;
      };
    };


  };
  networking.wireless.enable = false;
  services.hostapd = {
    enable = true;
    interface = "wlp2s0";
    ssid = secrets.hostapd.ssid;
    hwMode = "g";
    channel = 10;
    wpaPassphrase = secrets.hostapd.wpaPassphrase;
  };

  services.dhcpd = {
    enable = true;
    interfaces = [ "wlp2s0" ]; # "enp4s6f0" "enp4s6f1" ];
    extraConfig = ''
      authoritative;
      option subnet-mask            255.255.255.0;
      option domain-name-servers    8.8.8.8, 8.8.4.4;

      subnet 192.168.1.0 netmask 255.255.255.0 {
        range                       192.168.1.10 192.168.1.254;
        option broadcast-address    192.168.1.255;
        option routers              192.168.1.1;
      }
     '';

      #subnet 192.168.2.0 netmask 255.255.255.0 {
      #  range                       192.168.2.10 192.168.2.254;
       # option broadcast-address    192.168.2.255;
      #  option routers              192.168.2.1;
      #}

      #subnet 192.168.3.0 netmask 255.255.255.0 {
      #  range                       192.168.3.10 192.168.3.254;
      #  option subnet-mask          255.255.255.0;
      #  option broadcast-address    192.168.3.255;
      #  option routers              192.168.3.1;
      #}
    #'';
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
