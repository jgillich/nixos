with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "1.2";
  name = "dotfiles-${version}";

  src = fetchFromGitHub {
    owner = "jgillich";
    repo = "dotfiles";
    rev = "v${version}";
    sha256 = "1p8n5cja1y5w37qw6bzs0yv3wps7l15yl14d3sssi1bnbqna2gfl";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin
  '';

}
