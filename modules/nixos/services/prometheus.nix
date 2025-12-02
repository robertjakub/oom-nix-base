{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem mkDefault;
  inherit (lib) mkOption types;
  fn = import ../../lib/internal.nix { inherit lib; };

  scrapeList = fn.makeOptionTypeList (toString ./prometheus.scrape);
  scrape = fn.lst {
    p = toString ./prometheus.scrape;
    b = true;
  };
  cfg = config.modules.services;
in
{
  options.modules.services.prometheus = {
    enable = mkOption {
      type = types.bool;
      default = elem "prometheus" cfg.services;
      description = "enable prometheus";
    };
    http_addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "prometheus: default addr";
    };
    http_port = mkOption {
      type = types.int;
      default = 9040;
      description = "prometheus: default port";
    };
    retentionTime = mkOption {
      type = types.str;
      default = "365d";
      description = "prometheus: retentionTime";
    };
    scrapes = mkOption {
      type = types.listOf (types.enum scrapeList);
      default = [ ];
    };
  };

  imports = scrape;

  config = mkIf (cfg.prometheus.enable) {
    services.prometheus = {
      enable = true;
      listenAddress = cfg.prometheus.http_addr;
      port = cfg.prometheus.http_port;
      retentionTime = cfg.prometheus.retentionTime;
      extraFlags = mkDefault [ "--web.enable-admin-api" ];
    };
  };
}
