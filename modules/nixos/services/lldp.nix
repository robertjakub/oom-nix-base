{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem mkOption types;
  cfg = config.modules.services;
in
{
  options.modules.services.lldp = {
    enable = mkOption {
      type = types.bool;
      default = elem "lldp" cfg.services;
    };
    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };
  };
  config = mkIf (cfg.lldp.enable) {
    services.lldpd.enable = true;
    services.lldpd.extraArgs = cfg.lldp.args;
  };
}
