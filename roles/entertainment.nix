{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    steam
    google-chrome chromium
    zeroad openra
    clementine
    wine
  ];

  nixpkgs.config.chromium.enableWideVine = true; # drm

  hardware = {
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };

  #services.mopidy = {
  #  enable = true;
  #  extensionPackages = with pkgs; [ mopidy-moped mopidy-gmusic mopidy-subsonic mopidy-mopify ];
  #  configuration = ''
  #    [mpd]
  #    hostname = ::

  #    [local]
  #    media_dir = /var/music

  #    [gmusic]
  #    username = ${secrets.gmusic.username}
  #    password = ${secrets.gmusic.password}
  #    deviceid = ${secrets.gmusic.deviceid}
  #    all_access = true

  #    [subsonic]
  #    hostname = music.xapp.ga
  #    port = 8020
  #    ssl = yes
  #    username = ${secrets.subsonic.username}
  #    password = ${secrets.subsonic.password}
  #    context = /
  #  '';
  #};
}
