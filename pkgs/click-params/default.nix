{
  lib,
  pythonPackages,
  fetchPypi,
  pkgs,
  ...
}: let
  pname = "click_params";
  version = "0.5.0";
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-X+l7lFl4GjtDuE/k7ABlGT4bDVz23HeJf+IMMfR41/8=";
  };
  name = "${pname}-${version}";
in
  pythonPackages.buildPythonPackage rec {
    inherit pname name version src;

    pyproject = true;
    # doCheck = false;

    propagatedBuildInputs = with pythonPackages; [click poetry-core deprecated validators];

    patches = [
      ./validators-deps.patch
    ];

    meta = with lib; {
      homepage = "https://github.com/click-contrib/click_params/";
      description = "A bunch of useful click parameter types.";
      license = licenses.asl20;
      maintainers = with maintainers; [];
    };
  }
