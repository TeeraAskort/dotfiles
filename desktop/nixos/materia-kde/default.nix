 { stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "materia-kde-theme";
  version = "20210410";

  src = fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "materia-kde";
    rev = version;
    sha256 = "0wli16k9my7m8a9561545vjwfifmxm4w606z1h0j08msvlky40xw";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  # Make this a fixed-output derivation
  outputHashMode = "recursive";
  outputHashAlgo = "sha256";
  ouputHash = "2c2def57092a399aa1c450699cbb8639f47d751157b18db17";

  meta = {
    description = "A port of the materia theme for Plasma";
    homepage = "https://git.io/materia-kde";
    license = stdenv.lib.licenses.gpl3;
    maintainers = [ Alderaeney ];
    platforms = stdenv.lib.platforms.all;
  };
}
