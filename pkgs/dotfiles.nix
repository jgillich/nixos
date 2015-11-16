with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "1.3";
  name = "dotfiles-${version}";

  src = fetchFromGitHub {
    owner = "jgillich";
    repo = "dotfiles";
    rev = "v${version}";
    sha256 = "0vbjnhrlps4ydvscwbiy45avwc2z30c2828j8wgbd8898260rxr4";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin
  '';

}
