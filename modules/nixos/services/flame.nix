{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
  defSops = config.modules.defaults.sops.enable;
in
{
  options.modules.services.flame = {
    enable = mkOption {
      type = types.bool;
      default = elem "flame" cfg.services;
      description = "enable flame";
    };
    # http_addr = mkOption { type = types.str; default = "127.0.0.1"; description = "flame: default addr"; };
    http_port = mkOption {
      type = types.int;
      default = 9036;
      description = "flame: default port";
    };
  };
  config = mkIf (cfg.flame.enable) {
    services.flame = {
      enable = true;
      passwordFile = mkIf defSops config.sops.secrets."services/flame/password".path;
      secretFile = mkIf defSops config.sops.secrets."services/flame/secret".path;
      http_port = cfg.flame.http_port;
    };
    sops.secrets."services/flame/password" = mkIf defSops {
      owner = "flame";
      group = "flame";
    };
    sops.secrets."services/flame/secret" = mkIf defSops {
      owner = "flame";
      group = "flame";
    };
  };
}
