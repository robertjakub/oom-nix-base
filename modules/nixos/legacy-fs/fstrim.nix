{ config
, lib
, ...
}:
let
  inherit (lib) mkIf mkOption types mkDefault;
  cfg = config.modules.fs;
in
{
  options.modules.fs.defaults.fstrim.enable = mkOption {
    type = types.bool;
    default = true;
  };

  config = mkIf (cfg.enable && cfg.defaults.fstrim.enable) {
    services.fstrim = {
      enable = true;
      interval = mkDefault "weekly";
    };
  };
}
