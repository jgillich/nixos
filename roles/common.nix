{ config, pkgs, ... }:

{
  time.timeZone = "Europe/Berlin";

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  environment.systemPackages = with pkgs; [
    (import ../pkgs/dotfiles.nix)
    usbutils pciutils nfs-utils psmisc file gptfdisk
    git python ruby bundler nodejs gcc gnumake
    vim curl wget bind unzip fish
    htop tmux
    dhcp
    duplicity
    stow
    picocom
  ];

  environment.variables = {
   EDITOR = "vim";
  };

  nix.gc.automatic = true;
  nix.useChroot = true;

  hardware.enableAllFirmware = true;

  boot.cleanTmpDir = true;

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
    extraUsers.root = {
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxR6b5+s/Z4sMtSe0p23Vw8o8d7BCQdYy/PUuUloCVArz8A1wx37yOn5Rd1CtS7uGXQYQv1XtEexXv9bSqNHeTcr//ie0R/QVSXilMRlmYH92lXOGwnAaaylgiZ5de8TQ609maiZkAuyMJONRkOhFmGxnKn6VShRS30Dwrsz7zyF5eOyOhMdRPZdrSzPt8MU23OuBfVwhL1gcbAYZP/ujvqgNzv1ba31L+eRnryWaJXpI1D3N21hjVNlZlM3/P5HjpzEDobl+lH0xNtt8bPGQYErNf3jmypRLbzdBiDEa/nNC/22TWCjHeUAlfAqU26ZHPoV3//C08e/5CF9hILok3 jakob@gillich.me"
      ];
    };

  extraUsers.jakob = {
    isNormalUser = true;
    uid = 1000;
    description = "Jakob Gillich";
    extraGroups = [ "wheel" "disk" "cdrom" "docker" "audio" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxR6b5+s/Z4sMtSe0p23Vw8o8d7BCQdYy/PUuUloCVArz8A1wx37yOn5Rd1CtS7uGXQYQv1XtEexXv9bSqNHeTcr//ie0R/QVSXilMRlmYH92lXOGwnAaaylgiZ5de8TQ609maiZkAuyMJONRkOhFmGxnKn6VShRS30Dwrsz7zyF5eOyOhMdRPZdrSzPt8MU23OuBfVwhL1gcbAYZP/ujvqgNzv1ba31L+eRnryWaJXpI1D3N21hjVNlZlM3/P5HjpzEDobl+lH0xNtt8bPGQYErNf3jmypRLbzdBiDEa/nNC/22TWCjHeUAlfAqU26ZHPoV3//C08e/5CF9hILok3 jakob@gillich.me"
    ];
  };
};
}
