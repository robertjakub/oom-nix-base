{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types mkDefault;
  cfg = config.modules.services;
in
{
  options.modules.services.zram = {
    enable = mkOption {
      type = types.bool;
      default = elem "zram" cfg.services;
      description = "enable zram";
    };
  };
  config = mkIf (cfg.zram.enable) {
    zramSwap = {
      enable = true;
      memoryPercent = mkDefault 50;
      algorithm = mkDefault "zstd";
    };
  };
}
