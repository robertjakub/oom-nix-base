{ config
, lib
, ...
}:
let
  inherit (lib) mkIf elem;
  inherit (lib) mkOption types;
  cfg = config.modules.services;
  scrape = config.modules.scrapes;
in
{
  options.modules.scrapes.prometheus = {
    enable = mkOption {
      type = types.bool;
      default = elem "prometheus" cfg.prometheus.scrapes;
    };
    target = mkOption {
      type = types.str;
      default = "${cfg.prometheus.http_addr}:${toString cfg.prometheus.http_port}";
    };
  };

  config = mkIf (cfg.prometheus.enable && scrape.prometheus.enable) {
    services.prometheus.scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "15s";
        scrape_timeout = "5s";
        static_configs = [
          {
            targets = [ "${scrape.prometheus.target}" ];
          }
        ];
      }
    ];
  };
}
