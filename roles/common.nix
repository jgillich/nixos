{ config, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in
{
  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    (import ../pkgs/dotfiles.nix)
    usbutils pciutils nfs-utils psmisc file gptfdisk
    git gitAndTools.git-crypt gitAndTools.hub
    python ruby bundler nodejs gcc gnumake
    curl wget bind dhcp unzip
    htop tmux picocom stow duplicity
  ];

  environment.variables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
  };

  programs.fish.enable = true;

  nix.gc.automatic = true;
  nix.useChroot = true;

  hardware.enableAllFirmware = true;

  boot.cleanTmpDir = true;

  boot.kernel.sysctl = {
    "vm.swappiness" = 20;
  };

  security = {
    sudo.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.ntp.enable = true;

  users = {
    mutableUsers = false;

    users.root = {
      hashedPassword = secrets.hashedPassword;
      shell = "${pkgs.fish}/bin/fish";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxR6b5+s/Z4sMtSe0p23Vw8o8d7BCQdYy/PUuUloCVArz8A1wx37yOn5Rd1CtS7uGXQYQv1XtEexXv9bSqNHeTcr//ie0R/QVSXilMRlmYH92lXOGwnAaaylgiZ5de8TQ609maiZkAuyMJONRkOhFmGxnKn6VShRS30Dwrsz7zyF5eOyOhMdRPZdrSzPt8MU23OuBfVwhL1gcbAYZP/ujvqgNzv1ba31L+eRnryWaJXpI1D3N21hjVNlZlM3/P5HjpzEDobl+lH0xNtt8bPGQYErNf3jmypRLbzdBiDEa/nNC/22TWCjHeUAlfAqU26ZHPoV3//C08e/5CF9hILok3 jakob@gillich.me"
      ];
    };

    users.jakob = {
      hashedPassword = secrets.hashedPassword;
      isNormalUser = true;
      shell = "${pkgs.fish}/bin/fish";
      uid = 1000;
      description = "Jakob Gillich";
      extraGroups = [ "wheel" "disk" "cdrom" "docker" "audio" ];
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxR6b5+s/Z4sMtSe0p23Vw8o8d7BCQdYy/PUuUloCVArz8A1wx37yOn5Rd1CtS7uGXQYQv1XtEexXv9bSqNHeTcr//ie0R/QVSXilMRlmYH92lXOGwnAaaylgiZ5de8TQ609maiZkAuyMJONRkOhFmGxnKn6VShRS30Dwrsz7zyF5eOyOhMdRPZdrSzPt8MU23OuBfVwhL1gcbAYZP/ujvqgNzv1ba31L+eRnryWaJXpI1D3N21hjVNlZlM3/P5HjpzEDobl+lH0xNtt8bPGQYErNf3jmypRLbzdBiDEa/nNC/22TWCjHeUAlfAqU26ZHPoV3//C08e/5CF9hILok3 jakob@gillich.me"
      ];
    };
  };
}
