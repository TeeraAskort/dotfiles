with import <nixpkgs> {};

stdenv.mkDerivation {
  name = "django-env";

  nativeBuildInputs = [
    python3

    python38Packages.django
    sqlite
  ];

}
