{ lib, pkgs, buildPythonPackage }:

buildPythonPackage rec {
    pname = "key-mapper-git";
    
    src = pkgs.fetchFromGithub {
        owner = "sezanzeb";
        repo = "key-mapper";
        rev = "d457b5efbecd79d1ee6cfe3e1172f392731b829e";
        sha256 = "0732a86523ce22cd0146a58605f2141c17b6cca34b3a5632971f9539089e3e3e";
    };
    
    meta = with lib; {
        homepage = "https://github.com/sezanzeb/key-mapper";
        description = "Key mapping tool";
        license = licenses.gpl3;
        maintainers = with maintainers; [ Alderaeney ];
    };
}
