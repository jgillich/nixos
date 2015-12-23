{ config, pkgs, ... }:

{
  imports = [
    ../services/rkt.nix
  ];

  networking.firewall = {
    enable = true;
    checkReversePath = false; # https://github.com/NixOS/nixpkgs/issues/10101
    allowedTCPPorts = [
      22000 # syncthing
    ];
    allowedUDPPorts = [
      1900 # UPNP
    ];
  };

  environment.systemPackages = with pkgs; [
    rustc cargo
    go
    firefoxWrapper
    gnupg pass
    stow
    atom neovim
    gimp inkscape
    pitivi
    gitg gitAndTools.hub gitAndTools.gitAnnex heroku
    parted gnome3.gnome-disk-utility
    sshfsFuse
    irssi gnome3.polari telepathy_gabble
    virtmanager #gnome3.gnome-boxes
    tor torbrowser notbit
  ];

  environment.variables = {
    GTK2_RC_FILES = "${pkgs.gnome_themes_standard}/share/themes/Adwaita/gtk-2.0/gtkrc";
  };

  environment.gnome3.packageSet = pkgs.gnome3_18;

  nixpkgs.config.packageOverrides = pkgs: with pkgs; {
    firefoxWrapper = wrapFirefox { browser = firefox.override { enableOfficialBranding = true; }; };
  };

  virtualisation.docker.enable = true;
  virtualisation.docker.extraOptions = "--exec-opt native.cgroupdriver=cgroupfs";
  virtualisation.docker.socketActivation = false;
  virtualisation.rkt.enable = true;
  virtualisation.libvirtd.enable = true;

  networking.networkmanager.enable = true;

  services.syncthing = {
    enable = false;
    user = "jakob";
    dataDir = "/home/jakob";
  };

  services.xserver = {
    enable = true;
    layout = "us";
    displayManager.slim.enable = true;
    desktopManager.gnome3.enable = true;
    desktopManager.budgie.enable = true;
    desktopManager.xterm.enable = false;
    startGnuPGAgent = true;
    synaptics.enable = true;
  };

  programs.ssh.startAgent = false;

  services.tor = {
    enable = true;
    client.enable = true;
  };

  services.notbit.enable = true;

  services.nginx = {
    enable = true;
    httpConfig =
      ''
      server {
          listen 8080;
          # vault cors proxy
          # based on http://enable-cors.org/server_nginx.html
          location / {
            if ($request_method = 'OPTIONS') {
              add_header 'Access-Control-Allow-Origin' '*';
              add_header 'Access-Control-Allow-Credentials' 'true';
              add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
              add_header 'Access-Control-Allow-Headers' 'x-vault-token,DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Typ';
              add_header 'Content-Type' 'text/plain charset=UTF-8';
              add_header 'Content-Length' 0;
              return 204;
            }

            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Allow-Credentials' 'true' always;
            add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS' always;
            add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Typ' always;

            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://127.0.0.1:8200;
          }
        }
      '';
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
