{ lib, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  rolesList = fn.makeOptionTypeList (toString ./roles);
in
{
  imports = (fn.scanPaths ./roles);
  options.modules.defaults.roles = lib.mkOption {
    type = lib.types.listOf (lib.types.enum rolesList);
    default = [ ];
  };
}
