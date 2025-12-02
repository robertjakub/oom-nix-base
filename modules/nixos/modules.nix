{ lib, ... }:
let fn = import ../lib/internal.nix { inherit lib; };
in {
  imports = (fn.scanPaths ./modules);
}
