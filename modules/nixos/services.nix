{ lib, ... }:
let
  inherit (lib) mkOption types;
  fn = import ../lib/internal.nix { inherit lib; };
  appsList = fn.makeOptionTypeList (toString ./services);
in
{
  imports = (fn.scanPaths ./services);

  options.modules.services = {
    services = mkOption {
      type = types.listOf (types.enum appsList);
      default = [ ];
    };
  };
}
