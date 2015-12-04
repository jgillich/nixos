{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    #steam
    gstreamer
    gst_plugins_good
    gst_plugins_bad
    gst_plugins_ugly
    gst_ffmpeg
    mopidy
    mopidy-mopify
  ];

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  services.mopidy = {
    enable = true;
    extensionPackages = [ pkgs.mopidy-mopify ];
    configuration =
      ''
        [mpd]
        hostname = ::

        [spotify]
        username = alice
        password = mysecret
      '';

  };
}
