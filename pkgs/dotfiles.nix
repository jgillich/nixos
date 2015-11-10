with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "1.1";
  name = "dotfiles-${version}";

  src = fetchFromGitHub {
    owner = "jgillich";
    repo = "dotfiles";
    rev = "v${version}";
    sha256 = "0pz2hchp75bmnx5pmkci1i5yqrva66lspl2w644g7shny2r4nwnk";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin
  '';

}
