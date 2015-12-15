{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  imports =  [
    ../services/ppp.nix
    ../services/miniupnpd.nix
    ../services/dnsmasq.nix
  ];

  networking = {
    domain = "home";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];

    firewall = {
      enable = true;
      allowPing = true;
      trustedInterfaces = [ "wlp4s0" "enp2s0" "enp3s0" ];
      checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101
      allowedTCPPorts = [
        22    # ssh
        80    # http
        443   # https
        2222  # git
      ];
      allowedUDPPorts = [ ];
    };

    nat = {
      enable = true;
      internalIPs = [ "192.168.1.0/24" "192.168.2.0/24" "192.168.3.0/24" ];
      externalInterface = "ppp0";
    };

    interfaces = {
      wlp4s0 = {
        ipAddress = "192.168.1.1";
        prefixLength = 24;
      };

      enp1s0 = {
        useDHCP = false;
      };

      enp2s0 = {
        ipAddress = "192.168.2.1";
        prefixLength = 24;
      };

      enp3s0 = {
        ipAddress = "192.168.3.1";
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

      subnet 192.168.1.0 netmask 255.255.255.0 {
        range                       192.168.1.10 192.168.1.254;
        option broadcast-address    192.168.1.255;
        option routers              192.168.1.1;
      }

      subnet 192.168.2.0 netmask 255.255.255.0 {
        range                       192.168.2.10 192.168.2.254;
        option broadcast-address    192.168.2.255;
        option routers              192.168.2.1;
      }
      subnet 192.168.3.0 netmask 255.255.255.0 {
        range                       192.168.3.10 192.168.3.254;
        option broadcast-address    192.168.3.255;
        option routers              192.168.3.1;
      }
    '';
  };

  services.dnsmasq2 = {
    enable = false;
    servers = [ "8.8.8.8" "8.8.4.4" ];
    extraConfig = ''
      domain=home
      interface=wlp4s0
      interface=enp2s0
      interface=enp3s0
      bind-interfaces
      dhcp-range=192.168.1.10,192.168.1.254,24h
      dhcp-range=192.168.2.10,192.168.2.254,24h
      dhcp-range=192.168.3.10,192.168.3.254,24h
    '';
  };

  services.ppp = {
    enable = true;

    config = {
      easybell = {
        interface = "enp1s0";
        username = secrets.easybell.username;
        password = secrets.easybell.password;
        pppoe = true;
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
    enable = false;
    externalInterface = "ppp0";
    natpmp = true;
    internalIPs = [ "wlp4s0" ];
  };
}
