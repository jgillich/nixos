{ config, pkgs, ... }:

{
  networking.firewall = {
    enable = true;
    checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101

    allowedTCPPorts = [
      24800 # synergy
    ];
  };

  environment.systemPackages = with pkgs; [
    firefox
    rustc cargo go
    gnupg pass
    atom
    gimp inkscape
    pitivi
    gitg gitAndTools.hub gitAndTools.gitAnnex heroku
    parted gnome3.gnome-disk-utility
    sshfsFuse stow
    virtmanager
    tor torbrowser pybitmessage
  ];

  nixpkgs.config.firefox.enableOfficialBranding = true;

  environment.variables = {
    GTK2_RC_FILES = "${pkgs.gnome_themes_standard}/share/themes/Adwaita/gtk-2.0/gtkrc";
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--exec-opt native.cgroupdriver=cgroupfs";
  virtualisation.docker.socketActivation = false;
  virtualisation.rkt.enable = true;
  virtualisation.libvirtd.enable = true;

  services.syncthing = {
    enable = false;
    user = "jakob";
    dataDir = "/home/jakob";
  };

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
    #desktopManager.budgie.enable = true;
    desktopManager.xterm.enable = false;
    startGnuPGAgent = true;
    synaptics.enable = true;
  };

  services.synergy.server = {
    enable = true;
  };

  programs.ssh.startAgent = false;

  services.tor = {
    enable = true;
    client.enable = true;
  };

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (subject.isInGroup('wheel')) {
          return polkit.Result.YES;
        }
      });
    '';
  };

}
