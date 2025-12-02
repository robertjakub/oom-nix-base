{ lib, ... }:
let
  fn = import ../lib/internal.nix { inherit lib; };
  appsList = fn.makeOptionTypeList (toString ./apps);
in
{
  imports = (fn.scanPaths ./apps);

  options.modules.apps = {
    apps = lib.mkOption {
      type = lib.types.listOf (lib.types.enum appsList);
      default = [ ];
    };
  };
}
