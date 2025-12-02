{ config, lib, ... }:
let
  inherit (lib) mkOption types mkIf;
in
{
  options.modules.defaults.garbage = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf config.modules.defaults.garbage {
    nix.optimise.dates = [ "03:45" ];
    nix.optimise.automatic = true;
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
}
