{ lib, python3Packages, fetchFromGitHub
, gobject-introspection
, python3
, wrapGAppsHook
, pango
, gdk-pixbuf
, atk
, coreutils
, xmodmap }:

let 

binPath = lib.makeBinPath [
    coreutils
    xmodmap
];

in python3Packages.buildPythonApplication rec {
    pname = "key-mapper-git";
    version = "0.4.0";
    
    src = fetchFromGitHub {
        owner = "sezanzeb";
        repo = "key-mapper";
        rev = version;
        sha256 = "1ssgfp7rh4q8bbkxhsp2l63fvwhn2bhfkd2hxfvgnibbfp8r5vk7";
    };

    nativeBuildInputs = [ gobject-introspection wrapGAppsHook pango gdk-pixbuf atk ];
    
    buildInputs = [
      (python3.withPackages (ps: with ps; [ pydbus pygobject3 evdev setuptools ]))
      gobject-introspection
      pango
      gdk-pixbuf
      atk
    ];

    propagateBuildInputs = with python3Packages; [ pydbus pygobject3 evdev setuptools ];

    doCheck = false;

    dontWrapGApps = true;
    makeWrapperArgs = [
        "--prefix PATH : ${binPath}"
        ''''${gappsWrapperArgs[@]}''
    ];
    
    strictDeps = false;

    postInstall = ''
      mv $out/lib/python*/site-packages/usr/bin $out
    '';

    meta = with lib; {
        homepage = "https://github.com/sezanzeb/key-mapper";
        description = "Key mapping tool";
        license = licenses.gpl3Only;
        maintainers = with maintainers; [ Alderaeney ];
    };
}