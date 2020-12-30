{ lib, python39Packages }:

python39Packages.buildPythonApplication rec {
    pname = "key-mapper-git";
    version = "0.4.0";
    
    src = pkgs.fetchFromGitHub {
        owner = "sezanzeb";
        repo = "key-mapper";
        rev = "d457b5efbecd79d1ee6cfe3e1172f392731b829e";
        sha256 = "0732a86523ce22cd0146a58605f2141c17b6cca34b3a5632971f9539089e3e3e";
    };
    
   buildInputs = with python39Packages; [ pydbus pygobject evdev ];

   propagateBuildInputs = with python39Packages; [ pydbus pygobject evdev ];

    meta = with lib; {
        homepage = "https://github.com/sezanzeb/key-mapper";
        description = "Key mapping tool";
        license = licenses.gpl3;
        maintainers = with maintainers; [ Alderaeney ];
    };
}
