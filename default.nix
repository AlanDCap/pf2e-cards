{ stdenv, texlive, lib, ... }:

stdenv.mkDerivation {
    name = "pf2e-cards";
    src = lib.cleanSourceWith {
      src = ./.;
      filter = path: _type:
        lib.hasInfix "cards" path ||
        lib.hasInfix "fonts" path ||
        lib.hasSuffix ".tex" path ||
        lib.hasSuffix ".cls" path;
    };
    nativeBuildInputs = [ (texlive.combine { inherit (texlive) scheme-small latexmk; }) ];
    buildPhase = ''
      max_print_line=1000 latexmk -synctex=1 -interaction=nonstopmode -halt-on-error -file-line-error -xelatex cards.tex a4print.tex
      # strip /nix/<...> from cards.log to remove artifical dependency
      sed -i 's|/nix/store/.\{32\}|/installation|g' cards.log
    '';
    installPhase = ''
        mkdir -p $out
        cp cards.pdf a4print.pdf metadata.txt cards.log $out
    '';
}
