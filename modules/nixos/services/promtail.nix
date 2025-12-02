{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  fn = import ../../lib/internal.nix { inherit lib; };

  ptailList = fn.makeOptionTypeList (toString ./promtail.scrape);
  ptailscrape = fn.lst {
    p = toString ./promtail.scrape;
    b = true;
  };
  cfg = config.modules.services;
in
{
  options.modules.services.promtail = {
    enable = mkOption {
      type = types.bool;
      default = elem "promtail" cfg.services;
      description = "enable promtail";
    };
    loki_url = mkOption {
      type = types.str;
      default = "127.0.0.1:9030";
      description = "promtail: default loki url";
    };
    # http_addr = mkOption { type = types.str; default = "127.0.0.1"; description = "promtail: default addr"; };
    http_port = mkOption {
      type = types.int;
      default = 9031;
      description = "promtail: default port";
    };
    scrapes = mkOption {
      type = types.listOf (types.enum ptailList);
      default = [ ];
    };
  };

  imports = ptailscrape;

  config = mkIf (cfg.promtail.enable) {
    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = cfg.promtail.http_port;
          grpc_listen_port = 0;
        };
        positions = {
          filename = "/tmp/positions.yaml";
        };
        clients = [
          {
            url = "http://${toString cfg.promtail.loki_url}/loki/api/v1/push";
          }
        ];
      };
    };
  };
}
