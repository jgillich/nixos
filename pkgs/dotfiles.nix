with import <nixpkgs> {};

stdenv.mkDerivation rec {
  version = "1.4";
  name = "dotfiles-${version}";

  src = fetchFromGitHub {
    owner = "jgillich";
    repo = "dotfiles";
    rev = "v${version}";
    sha256 = "034ii83rjaxncdnaay2scfsjyxcz8fkchjzmf6mxxjkiicv9j442";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp dotfiles-update $out/bin
  '';

}
