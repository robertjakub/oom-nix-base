{ lib, ... }:
let fn = import ../modules/lib/internal.nix { inherit lib; };
in { imports = (fn.scanPaths ./modules); }
