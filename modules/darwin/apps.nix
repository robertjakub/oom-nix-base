{ lib, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  appsList = fn.makeOptionTypeList (toString ./apps);
  apps = fn.lst {
    p = toString ./apps;
    b = true;
  };
in
{
  options.modules.apps.apps = lib.mkOption {
    type = lib.types.listOf (lib.types.enum appsList);
    default = [ ];
  };
  imports = apps;
}
