{ lib, ... }:
let fn = import ./lib/internal.nix { inherit lib; };
in {
  imports = (fn.scanPaths ./homeManager);
  home.stateVersion = "25.11";
}
