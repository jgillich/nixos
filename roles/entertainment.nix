{ config, pkgs, ... }:
let
  secrets = import ../secrets.nix;
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    steam
    gstreamer
    gst_plugins_good
    gst_plugins_bad
    gst_plugins_ugly
    gst_ffmpeg
    mopidy
    mopidy-mopify
  ];

  hardware = {
    opengl.driSupport = true;
    pulseaudio.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.support32Bit = true;
  };


  services.mopidy = {
    enable = true;
    extensionPackages = [ pkgs.mopidy-moped pkgs.mopidy-gmusic ];
    configuration =
      ''
        [mpd]
        hostname = ::

        [gmusic]
        username = ${secrets.gmusic.username}
        password = ${secrets.gmusic.password}
      '';

  };
}
