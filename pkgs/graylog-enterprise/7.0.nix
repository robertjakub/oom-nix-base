{ callPackage, lib, ... }:
let buildGraylog = callPackage ./graylog-enterprise.nix { };
in
buildGraylog {
  version = "7.0.1";
  hash = "sha256-sXBNY9Tf5sqg3zRgyv7+ErAenyPsIGynMwfg3VoQn00=";
  maintainers = with lib.maintainers; [ bbenno ];
  license = lib.licenses.sspl;
}
