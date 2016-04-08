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
    rustc rustfmt cargo racerRust
    gnupg pass
    atom lighttable
    gimp inkscape
    pitivi
    gitg gitAndTools.gitAnnex heroku
    parted gnome3.gnome-disk-utility
    sshfsFuse stow
    gnome3.gnome-boxes
    tor torbrowser pybitmessage
    androidsdk idea.android-studio
  ];

  environment.variables = {
    GTK2_RC_FILES = "${pkgs.gnome_themes_standard}/share/themes/Adwaita/gtk-2.0/gtkrc";
  };

  virtualisation.docker = {
    enable = true;
    extraOptions = "--exec-opt native.cgroupdriver=cgroupfs";
    socketActivation = false;
  };
  #virtualisation.rkt.enable = true;
  #virtualisation.libvirtd.enable = true;

  services.syncthing = {
    #enable = true;
    user = "jakob";
    dataDir = "/home/jakob";
  };

  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
    #desktopManager.budgie.enable = true;
    desktopManager.xterm.enable = false;
    synaptics.enable = true;
  };

  services.couchdb = {
    enable = true;
    extraConfig = ''
      [httpd]
      enable_cors = true
      [cors]
      origins = *
      credentials = true
      methods = GET,PUT,POST,HEAD,DELETE
      headers = accept, authorization, content-type, origin
    '';
  };

  services.tarsnap = {
    #enable = true;

    archives.machine.directories = [
      "/etc/nixos"
    ];

    archives.jgillich.directories = [
      "/home/jakob/.dotfiles"
      "/home/jakob/.password-store"
      "/home/jakob/.gnupg2"
      "/home/jakob/.ssh"
    ];
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
