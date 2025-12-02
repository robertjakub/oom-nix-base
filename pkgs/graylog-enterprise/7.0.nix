{ callPackage
, lib
, ...
}:
let
  buildGraylog = callPackage ./graylog-enterprise.nix { };
in
buildGraylog {
  version = "7.0.0";
  hash = "sha256-Rm2gfrEeyQAbWQ3cdN9MY/VLAN/zRmhuHnd9g9ku00w=";
  maintainers = with lib.maintainers; [ bbenno ];
  license = lib.licenses.sspl;
}
