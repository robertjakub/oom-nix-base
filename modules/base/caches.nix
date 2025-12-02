{ config, lib, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  localDir = "${config.modules.defaults.configRoot}/defaults/caches";
  cachesDefaultList = fn.makeOptionTypeList (toString ./caches);
  cachesLocalList =
    if builtins.pathExists "${localDir}"
    then fn.makeOptionTypeList (toString "${localDir}") else [ ];
in
{
  imports = (fn.scanPaths ./caches);

  options.modules.caches = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (cachesDefaultList ++ cachesLocalList));
    default = [ ];
  };
}
