{ config
, lib
, ...
}:
let
  inherit (lib) mkOption types mkIf;
in
{
  options.modules.defaults.garbage = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf config.modules.defaults.garbage {
    nix.optimise.interval = [
      {
        Hour = 4;
        Minute = 15;
        Weekday = 7;
      }
    ];
    nix.optimise.automatic = true;
    nix.gc = {
      automatic = true;
      interval = [
        {
          Hour = 3;
          Minute = 15;
          Weekday = 7;
        }
      ];
      options = "--delete-older-than 30d";
    };
  };
}
