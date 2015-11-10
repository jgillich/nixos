{ config, pkgs, ... }:

{
 environment.variables = {
   EDITOR = "vim";
 };

 environment.sessionVariables = {
 };

 time.timeZone = "Europe/Berlin";
 i18n = {
   consoleFont = "Lat2-Terminus16";
   consoleKeyMap = "us";
   defaultLocale = "en_US.UTF-8";
 };

 environment.systemPackages = with pkgs; [
   (import ../pkgs/dotfiles.nix)
   git
   htop
   tmux
   vim
   curl
   unzip
   sudo
   fish
 ];

 networking.networkmanager.enable = true;

 programs.ssh.startAgent = false;
 programs.bash.enableCompletion = true;

 services.openssh.enable = true;
 services.openssh.passwordAuthentication = false;

 services.printing = {
   enable = true;
 };

 users.extraUsers.jakob = {
   isNormalUser = true;
   uid = 1000;
   createHome = true;
   home = "/home/jakob";
   description = "Jakob Gillich";
   shell = "/run/current-system/sw/bin/fish";
   extraGroups = [ "wheel" "disk" "cdrom" "docker" "audio" ];
   openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxR6b5+s/Z4sMtSe0p23Vw8o8d7BCQdYy/PUuUloCVArz8A1wx37yOn5Rd1CtS7uGXQYQv1XtEexXv9bSqNHeTcr//ie0R/QVSXilMRlmYH92lXOGwnAaaylgiZ5de8TQ609maiZkAuyMJONRkOhFmGxnKn6VShRS30Dwrsz7zyF5eOyOhMdRPZdrSzPt8MU23OuBfVwhL1gcbAYZP/ujvqgNzv1ba31L+eRnryWaJXpI1D3N21hjVNlZlM3/P5HjpzEDobl+lH0xNtt8bPGQYErNf3jmypRLbzdBiDEa/nNC/22TWCjHeUAlfAqU26ZHPoV3//C08e/5CF9hILok3 jakob@gillich.me"
   ];
 };

  users.defaultUserShell = "/run/current-system/sw/bin/fish";

}
