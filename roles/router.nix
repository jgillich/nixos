{ config, pkgs, ... }:

{

  networking = {

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
      internalIPs = [ "192.168.0.0/24" "192.168.1.0/24" "192.168.2.0/24" ];
      externalInterface = "enp3s0";
    };

    interfaces = {
      enp4s6f0.ipAddress = "192.168.0.1";
      enp4s6f0.prefixLength = 24;
      enp4s6f1.ipAddress = "192.168.1.1";
      enp4s6f1.prefixLength = 24;
      wlp2s0.ipAddress = "192.168.2.1";
      wlp2s0.prefixLength = 24;
    };


  };

  services.hostapd = {
    enable = true;
    interface = "wlp2s0";
    ssid = "zerowifi";
    hwMode = "g";
    channel = 10;
    wpaPassphrase = "zerowifi";
    extraCfg = ''
      ieee80211n=1
      ieee80211ac=1
      wmm_enabled=1
    '';
  };

  services.dhcpd = {
    enable = true;
    interfaces = [ "wlp2s0" "enp4s6f0" "enp4s6f1" ];
    extraConfig = ''
      ddns-update-style none;
      #option subnet-mask         255.255.255.0;
      one-lease-per-client true;

      subnet 192.168.1.0 netmask 255.255.255.0 {
        range 192.168.1.10 192.168.1.254;
        authoritative;

        # Allows clients to request up to a week (although they won't)
        max-lease-time              604800;
        # By default a lease will expire in 24 hours.
        default-lease-time          86400;

        option subnet-mask          255.255.255.0;
        option broadcast-address    192.168.1.255;
        option routers              192.168.1.1;
        option domain-name-servers  8.8.8.8, 8.8.4.4;
      }
      subnet 192.168.2.0 netmask 255.255.255.0 {
        range 192.168.2.10 192.168.2.254;
        authoritative;

        # Allows clients to request up to a week (although they won't)
        max-lease-time              604800;
        # By default a lease will expire in 24 hours.
        default-lease-time          86400;

        option subnet-mask          255.255.255.0;
        option broadcast-address    192.168.2.255;
        option routers              192.168.2.1;
        option domain-name-servers  8.8.8.8, 8.8.4.4;
      }
      subnet 192.168.3.0 netmask 255.255.255.0 {
        range 192.168.3.10 192.168.3.254;
        authoritative;

        # Allows clients to request up to a week (although they won't)
        max-lease-time              604800;
        # By default a lease will expire in 24 hours.
        default-lease-time          86400;

        option subnet-mask          255.255.255.0;
        option broadcast-address    192.168.3.255;
        option routers              192.168.3.1;
        option domain-name-servers  8.8.8.8, 8.8.4.4;
      }
    '';
  };

  #services.dnsmasq = {
  #  enable = true;
  #  extraConfig = ''
  #    log-queries
  #    log-dhcp
  #    #interface=wlp2s0
  #    #interface=enp4*
  #    dhcp-range=192.168.1.2,192.168.1.20,12h
  #    #dhcp-range=192.168.7.10,192.168.7.199,infinite
  #    #dhcp-range=wlp2s0,192.168.7.10,192.168.7.199,infinite
  #    #dhcp-range=enp4*,192.168.7.10,192.168.7.199,infinite
  #  '';
  #};

}
