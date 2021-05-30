 { stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "materia-kde-theme";
  version = "20210410";

  src = fetchFromGitHub {
    owner = "PapirusDevelopmentTeam";
    repo = "materia-kde";
    rev = version;
    sha256 = "1ng16w0cbz857ps6cg36pm4564f65wn0r23ayv42sp2zm1x86cid";
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
    maintainers = [ ];
    platforms = stdenv.lib.platforms.all;
  };
}
