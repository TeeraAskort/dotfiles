{ stdenv }:

stdenv.mkDerivation {
  version = "1.0";
  name = "fake-ibus";
  
  installPhase = ''
    mkdir -p $out/usr/share
    touch $out/usr/share/libibus-1.0.so
  '';
}
