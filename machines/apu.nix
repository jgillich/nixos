{ config, lib, pkgs, ... }:

{
  imports = [
    ../roles/common.nix
    ../roles/router.nix
  ];

  networking.hostName = "apu";

  system.stateVersion = "15.09";

  # ...

}
