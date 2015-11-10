with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "0.7.1";
  name = "Ghost-${version}";

  src = fetchFromGitHub {
    owner = "TryGhost";
    repo = "Ghost";
    rev = "${version}";
    sha256 = "0pz2hchp75bmnx5pmkci1i5yqrva66lspl2w644g7shny2r4nwnk";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin
  '';

}
