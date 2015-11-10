### machine.nix

    { config, lib, pkgs, ... }:

    {
      imports =
        [
          ./machines/aspire.nix
        ];
    }
