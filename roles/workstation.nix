{ config, pkgs, ... }:

{
  imports = [
    ../services/rkt.nix
  ];

  environment.systemPackages = with pkgs; [
    rustc cargo
    go
    firefoxWrapper
    gnupg
    pass
    stow
    atom
    gimp
    inkscape
    transmission
    kde5.kdenlive
    docker
    heroku
    gitg gitAndTools.hub
  ];

  environment.variables =
    { GTK2_RC_FILES = "${pkgs.gnome_themes_standard}/share/themes/Adwaita/gtk-2.0/gtkrc";
    };

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };
  };

  virtualisation.docker.enable = true;
  virtualisation.rkt.enable = true;

  services.syncthing = {
    enable = true;
    user = "jakob";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    displayManager.lightdm.enable = true;
    desktopManager.gnome3.enable = true;
    desktopManager.xterm.enable = false;
    startGnuPGAgent = true;
  };

  hardware.pulseaudio.enable = true;

  security.polkit.enable = true;
  security.polkit.extraConfig =
    ''
      polkit.addRule(function(action, subject) {
        // allow everyone to change brightness
        if (subject.isInGroup('wheel') &&
            action.id == 'org.gnome.settings-daemon.plugins.power.backlight-helper' ||
            action.id == 'org.freedesktop.login1.reboot'
            ) {
          return polkit.Result.YES;
        }
      });
    '';


  containers.ghost = {
    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        (import ../pkgs/dotfiles.nix)
        nodejs
        git
        vim
      ];
    };
  };

}
